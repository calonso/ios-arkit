//
//  ARKitEngine.m
//  ARModule
//
//  Created by Carlos on 06/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ARKitEngine.h"
#import "LocalizationHelper.h"
#import <QuartzCore/QuartzCore.h>

CGFloat VIEWPORT_WIDTH_RADIANS = 0.5f;
CGFloat VIEWPORT_HEIGHT_RADIANS = 0.7392f;
CGFloat VIEWPORT_EXTRA_WIDTH_MARGIN = 10 * M_PI / 360; // 10 degrees margin
CGFloat ACCELEROMETER_UPDATE_FREQUENCY = 20; // Hz

@interface ARKitEngine(Internal)

- (void) frontPositioning:(UIView *)theView atCoordinate:(ARGeoCoordinate *)coord;
- (void) resetView:(UIView *)theView value:(CGFloat)scaleValue;
- (void) floorPositioning:(UIView *)theView atCoordinate:(ARGeoCoordinate *)coord;
    
@end


@implementation ARKitEngine

#pragma mark - Engine initialization

- (id) initWithConfig:(ARKitConfig *) conf {
    if ((self = [super init])) {
        ar_coordinates = [[NSMutableArray alloc] init];
        ar_coordinateViews = [[NSMutableArray alloc] init];
        ar_floorCoordinateViews = [[NSMutableArray alloc] init];
        
        showsFloorImages = conf.showsFloorImages;
        scaleViewsBasedOnDistance = conf.scaleViewsBasedOnDistance;
        minimumScaleFactor = conf.minimumScaleFactor;
        NSAssert(minimumScaleFactor >= 0.0 && minimumScaleFactor <= 1.0, @"Minimum Scale Factor must be between 0.0 and 1.0!!");
        if (minimumScaleFactor == 1.0) NSLog(@"WARNING!!! Minimum Scale Factor will make AR points size 0");
        rotateViewsBasedOnPerspective = conf.rotateViewsBasedOnPerspective;
        maximumRotationAngle = conf.maximumRotationAngle;
        updateFrequency = conf.updateFrequency;
        debugMode = conf.debugMode;
        delegate = conf.delegate;
        NSAssert(delegate != nil, @"Nil Delegate provided, cannot start");
        loadingView = conf.loadingView;
        useAltitude = conf.useAltitude;
        
        switch (conf.orientation) {
            case UIInterfaceOrientationPortrait:{
                orientationSupporter.orientation = UIInterfaceOrientationPortrait;
                orientationSupporter.xOffset = 0.0;
                orientationSupporter.rotationAngle = 0.0;
                orientationSupporter.viewSize = [UIScreen mainScreen].bounds.size;
                break;
            }
            case UIInterfaceOrientationLandscapeLeft:{
                orientationSupporter.orientation = UIInterfaceOrientationLandscapeLeft;
                orientationSupporter.xOffset = -80.0;
                orientationSupporter.rotationAngle = -M_PI_2;
                CGSize s = [UIScreen mainScreen].bounds.size;
                orientationSupporter.viewSize = CGSizeMake(s.height, s.width);
                break;
            }
            case UIInterfaceOrientationLandscapeRight:{
                orientationSupporter.orientation = UIInterfaceOrientationLandscapeRight;
                orientationSupporter.xOffset = -80.0;
                orientationSupporter.rotationAngle = M_PI_2;
                CGSize s = [UIScreen mainScreen].bounds.size;
                orientationSupporter.viewSize = CGSizeMake(s.height, s.width);
                break;
            }
            case UIInterfaceOrientationPortraitUpsideDown:{
                orientationSupporter.orientation = UIInterfaceOrientationPortraitUpsideDown;
                orientationSupporter.xOffset = 0.0;
                orientationSupporter.rotationAngle = M_PI;
                orientationSupporter.viewSize = [UIScreen mainScreen].bounds.size;
                break;
            }
        }
        
        cameraController = [[UIImagePickerController alloc] init];
        cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        
        // Device's screen size (ignoring rotation intentionally):
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        // iOS is going to calculate a size which constrains the 4:3 aspect ratio
        // to the screen size. We're basically mimicking that here to determine
        // what size the system will likely display the image at on screen.
        // NOTE: screenSize.width may seem odd in this calculation - but, remember,
        // the devices only take 4:3 images when they are oriented *sideways*.
        float cameraAspectRatio = 4.0 / 3.0;
        float imageWidth = floorf(screenSize.width * cameraAspectRatio);
        float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
        cameraController.cameraViewTransform = CGAffineTransformMake(scale, 0, 0, scale, 0, 80.0);
        
        cameraController.showsCameraControls = NO;
        cameraController.navigationBarHidden = YES;
        
        radar = [[RadarView alloc] initAtPoint:conf.radarPoint];
        radar.points = ar_coordinates;
        
        ar_overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        ar_overlayView.transform = CGAffineTransformMakeRotation(orientationSupporter.rotationAngle);
        ar_overlayView.frame = [UIScreen mainScreen].bounds;
        ar_overlayView.clipsToBounds = YES;
        [self addExtraView:radar];
        
        cameraController.cameraOverlayView = ar_overlayView;
        
        if (debugMode) {
            ar_debugView = [[UILabel alloc] initWithFrame:CGRectZero];
            ar_debugView.backgroundColor = [UIColor whiteColor];
            ar_debugView.textAlignment = NSTextAlignmentCenter;
            ar_debugView.text = @"Waiting...";
            
            [ar_overlayView addSubview:ar_debugView];
        }
    }
    return self;
}

- (void) addExtraView:(UIView *)extra {   
	[ar_overlayView addSubview:extra];
    [ar_overlayView bringSubviewToFront:extra];
    extra.layer.zPosition = 1000;
}

#pragma mark - Coordinates storage management

- (void)addCoordinate:(ARGeoCoordinate *)coordinate {
	[ar_coordinates addObject:coordinate];
    
	if (coordinate.radialDistance > maximumScaleDistance) {
		maximumScaleDistance = coordinate.radialDistance;
	}
	
	//message the delegate.
	ARObjectView * ob = [delegate viewForCoordinate:coordinate floorLooking:NO];
	ob.controller = self;
	[ar_coordinateViews addObject:ob];
	
	if (showsFloorImages) {
		ARObjectView *floor = [delegate viewForCoordinate:coordinate floorLooking:YES];
		floor.controller = self;
		[ar_floorCoordinateViews addObject:floor];
	}
    
    [coordinate calibrateUsingOrigin:centerCoordinate.geoLocation useAltitude:useAltitude];
    if (coordinate.radialDistance > maximumScaleDistance) {
        maximumScaleDistance = coordinate.radialDistance;
        radar.farthest = maximumScaleDistance;
    }
}

- (void)addCoordinates:(NSArray *)newCoordinates {
	for (ARGeoCoordinate *coordinate in newCoordinates) {
		[self addCoordinate:coordinate];
	}
}

- (void)removeCoordinate:(ARGeoCoordinate *)coordinate {
    NSUInteger indexToRemove = [ar_coordinates indexOfObject:coordinate];
    if (indexToRemove != NSNotFound) {
        [ar_coordinates removeObjectAtIndex:indexToRemove];
        UIView *frontView = ar_coordinateViews[indexToRemove];
        UIView *floorView = ar_floorCoordinateViews[indexToRemove];
        [frontView removeFromSuperview];
        [floorView removeFromSuperview];
        [ar_coordinateViews removeObjectAtIndex:indexToRemove];
        [ar_floorCoordinateViews removeObjectAtIndex:indexToRemove];
    }
}

- (void)removeCoordinates:(NSArray *)coordinates {	
	for (ARGeoCoordinate *coordinateToRemove in coordinates) {
		[self removeCoordinate:coordinateToRemove];
	}
}

- (void) removeAllCoordinates {
    [ar_coordinates removeAllObjects];
    for (UIView *v in ar_coordinateViews) {
        [v removeFromSuperview];
    }
    for (UIView *v in ar_floorCoordinateViews) {
        [v removeFromSuperview];
    }
    [ar_coordinateViews removeAllObjects];
    [ar_floorCoordinateViews removeAllObjects];
}

NSComparisonResult LocationSortClosestFirst(ARGeoCoordinate *s1, ARGeoCoordinate *s2, void *ignore) {
    if (s1.radialDistance < s2.radialDistance) {
		return NSOrderedAscending;
	} else if (s1.radialDistance > s2.radialDistance) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

#pragma mark - Simulation Control 

- (BOOL)viewportContainsCoordinate:(ARGeoCoordinate *)coordinate {
	double centerAzimuth = centerCoordinate.azimuth;
	double leftEdgeAzimuth = centerAzimuth - VIEWPORT_WIDTH_RADIANS / 2.0 - VIEWPORT_EXTRA_WIDTH_MARGIN;

	if (leftEdgeAzimuth < 0.0) {
		leftEdgeAzimuth = 2 * M_PI + leftEdgeAzimuth;
	}
	
	double rightEdgeAzimuth = centerAzimuth + VIEWPORT_WIDTH_RADIANS / 2.0 + VIEWPORT_EXTRA_WIDTH_MARGIN;
	
	if (rightEdgeAzimuth > 2 * M_PI) {
		rightEdgeAzimuth = rightEdgeAzimuth - 2 * M_PI;
	}
	
	BOOL result = (coordinate.azimuth > leftEdgeAzimuth && coordinate.azimuth < rightEdgeAzimuth);
	if(leftEdgeAzimuth > rightEdgeAzimuth) {
		result = (coordinate.azimuth < rightEdgeAzimuth || coordinate.azimuth > leftEdgeAzimuth);
	}
	
	double centerInclination = centerCoordinate.inclination;
	double bottomInclination = centerInclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	double topInclination = centerInclination + VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	//check the height.
	result = result && (coordinate.inclination > bottomInclination && coordinate.inclination < topInclination);

	return result;
}

- (void) doStart {
    [loadingView removeFromSuperview];
    
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [topWindow subviews][[[topWindow subviews] count] - 1];	
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        baseViewController = nextResponder;
    } else {
        NSAssert(NO, @"ARModule: Could not find a root view controller.");
    }
    
    [baseViewController presentViewController:cameraController animated:NO completion:nil];
    
    if (debugMode) {
		[ar_debugView sizeToFit];
		[ar_debugView setFrame:CGRectMake(0,
										  orientationSupporter.viewSize.height - ar_debugView.frame.size.height,
										  orientationSupporter.viewSize.width,
										  ar_debugView.frame.size.height)];
	}
    
    if (!_updateTimer) {
		_updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateFrequency
                                                         target:self
                                                       selector:@selector(updateLocations:)
                                                       userInfo:nil
                                                       repeats:YES];
	}
}

- (void)startListening {
	
	//start our heading readings and our accelerometer readings.
    
    [[LocalizationHelper sharedHelper] registerForUpdates:self once:NO];
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = 1.0 / ACCELEROMETER_UPDATE_FREQUENCY;
    motionManager.gyroUpdateInterval = 1.0 / ACCELEROMETER_UPDATE_FREQUENCY;
    
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                        withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
    {
        static CGFloat z0 = 0;
        
        const NSTimeInterval dt = 1.0 / ACCELEROMETER_UPDATE_FREQUENCY;
        const double RC = 0.3;
        const double alpha = dt / (RC + dt);
        
        CGFloat currZ = (alpha * accelerometerData.acceleration.z) + (1.0 - alpha) * z0;
        
        //update the center coordinate inclination.
        centerCoordinate.inclination = currZ * VIEWPORT_HEIGHT_RADIANS;
        
        z0 = currZ;
    }];
    
    if (centerCoordinate) {
        [self doStart];
    } else {
        [loadingView setFrame:cameraController.view.bounds];
        if (!loadingView) {
            loadingView = [[UIView alloc] initWithFrame:cameraController.view.bounds];
            loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [spinner startAnimating];
            [loadingView addSubview:spinner];
            spinner.center = loadingView.center;
            UILabel *loadingText = [[UILabel alloc] initWithFrame:CGRectZero];
            loadingText.textAlignment = NSTextAlignmentCenter;
            loadingText.text = NSLocalizedString(@"Locating", @"");
            loadingText.backgroundColor = [UIColor clearColor];
            loadingText.textColor = [UIColor whiteColor];
            [loadingText sizeToFit];
            [loadingView addSubview:loadingText];
            loadingText.center = CGPointMake(spinner.center.x, spinner.center.y + spinner.frame.size.height * 2);
        }
        [loadingView sizeToFit];
        
        [[UIApplication sharedApplication].keyWindow addSubview:loadingView];
    }
}

- (void) hide {
	[_updateTimer invalidate];
    _updateTimer = nil;
    [[LocalizationHelper sharedHelper] deregisterForUpdates:self];
	[baseViewController dismissViewControllerAnimated:NO completion:nil];
}

- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARGeoCoordinate *)coordinate {
	
	CGPoint point;
	
	//x coordinate.
	
	double pointAzimuth = coordinate.azimuth;
	
	//our x numbers are left based.
	double leftEdgeAzimuth = centerCoordinate.azimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftEdgeAzimuth < 0.0) {
		leftEdgeAzimuth = 2 * M_PI + leftEdgeAzimuth;
	}
    
    if (leftEdgeAzimuth > pointAzimuth) {
        pointAzimuth += 2 * M_PI;
    }
	   
    point.x = ((pointAzimuth - leftEdgeAzimuth) / VIEWPORT_WIDTH_RADIANS) * orientationSupporter.viewSize.width;
	
	//y coordinate.
	double topInclination = centerCoordinate.inclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	point.y = orientationSupporter.viewSize.height - ((coordinate.inclination - topInclination) / VIEWPORT_HEIGHT_RADIANS) * orientationSupporter.viewSize.height;
	
	return point;
}

- (void)updateLocations:(NSTimer *)timer {
    [radar updatePoints:centerCoordinate];
    
	if (!ar_coordinateViews || ar_coordinateViews.count == 0) {
		return;
	}
	
	ar_debugView.text = [centerCoordinate description];
    
	int index = 0;
	CGFloat inclination = radiansToDegrees(centerCoordinate.inclination);
	BOOL floorLooking = inclination < -70.0 && inclination > -130.0;
    
    if (floorLooking && showsFloorImages) {
        if (lookingType == kFrontLookingType) {
            lookingType = kFloorLookingType;
            [delegate didChangeLooking:floorLooking];
        }
    } else {
        if (lookingType == kFloorLookingType) {
            lookingType = kFrontLookingType;
            [delegate didChangeLooking:floorLooking];
        }
    }
    
    NSInteger count = 0;
	for (ARGeoCoordinate *item in ar_coordinates) {
		
		UIView *viewToDraw = nil;
		UIView *otherView = nil;
		if (floorLooking && showsFloorImages) {
			viewToDraw = ar_floorCoordinateViews[index];
			[self floorPositioning:viewToDraw atCoordinate:item];
			otherView = ar_coordinateViews[index];
			[self resetView:otherView value:item.radialDistance];
		} else {
            if (ar_floorCoordinateViews.count > 0) {
                otherView = ar_floorCoordinateViews[index];
                [self resetView:otherView value:item.radialDistance];
            }
			viewToDraw = ar_coordinateViews[index];
			[self frontPositioning:viewToDraw atCoordinate:item];
            viewToDraw.layer.zPosition = -60 * count;
            ++count;
		}
		
		index++;
	}
}


#pragma mark - Views rendering methods

- (void)resetView:(UIView *)theView value:(CGFloat)scaleValue {
	if (theView.superview) {
		CGFloat scaleFactor = 1.0;
        theView.layer.transform = CATransform3DIdentity;
		if (scaleViewsBasedOnDistance && [ar_coordinateViews containsObject:theView]) {
			scaleFactor = 1.0 - minimumScaleFactor * (scaleValue / maximumScaleDistance);
			theView.frame = CGRectMake(theView.frame.origin.x, theView.frame.origin.y, theView.frame.size.width / scaleFactor, theView.frame.size.height/scaleFactor);
            
		}
		[theView removeFromSuperview];
	}
}

- (void) floorPositioning:(ARObjectView *)theView atCoordinate:(ARGeoCoordinate *)coord {
    if (theView.displayed) {
        double centerAzimuth = centerCoordinate.azimuth;
        
        double coordAzimuth = coord.azimuth - centerAzimuth;
        if (coordAzimuth < 0.0) {
            coordAzimuth = 2 * M_PI + coordAzimuth;
        }
        
        CGFloat offset = orientationSupporter.viewSize.height/2;
        
        theView.center = CGPointMake(ar_overlayView.center.x - orientationSupporter.xOffset, offset);
        theView.transform = CGAffineTransformMakeRotation(coordAzimuth);
        
        //if we don't have a superview, set it up.
        if (!(theView.superview)) {
            [ar_overlayView addSubview:theView];
            [ar_overlayView sendSubviewToBack:theView];
        }
    }
}

- (void) frontPositioning:(ARObjectView *)theView atCoordinate:(ARGeoCoordinate *)coord {
	if (theView.displayed && [self viewportContainsCoordinate:coord]) {
		CGPoint loc = [self pointInView:ar_overlayView forCoordinate:coord];
        
		CGFloat scaleFactor = 1.0;
		if (scaleViewsBasedOnDistance) {
			scaleFactor = 1.0 - minimumScaleFactor * (coord.radialDistance / maximumScaleDistance);
		}
		
		float width = theView.bounds.size.width;
		float height = theView.bounds.size.height;
		
		if (!(theView.superview)) {
			width = theView.bounds.size.width * scaleFactor;
			height = theView.bounds.size.height * scaleFactor;
		}
		
		theView.frame = CGRectMake(loc.x - width / 2.0, loc.y - height / 2.0, width, height);
        
		if (rotateViewsBasedOnPerspective) {
            CATransform3D transform = CATransform3DIdentity;
            
			transform.m34 = 1.0 / 300.0;
			// TODO fix rotation angle
			double itemAzimuth = coord.azimuth;
			double centerAzimuth = centerCoordinate.azimuth;
			if (itemAzimuth - centerAzimuth > M_PI) centerAzimuth += 2*M_PI;
			if (itemAzimuth - centerAzimuth < -M_PI) itemAzimuth += 2*M_PI;
			
			double angleDifference = itemAzimuth - centerAzimuth;
			transform = CATransform3DRotate(transform, maximumRotationAngle * angleDifference / (VIEWPORT_WIDTH_RADIANS / 2.0) , 0, 1, 0);
            theView.layer.transform = transform;
		}
		//if we don't have a superview, set it up.
		if (!(theView.superview)) {
			[ar_overlayView addSubview:theView];
			[ar_overlayView sendSubviewToBack:theView];
		}
		
	} else {
		[self resetView:theView value:coord.radialDistance];
	}
}

- (id) dataObjectWithIndex:(NSInteger)index {
    return ((ARGeoCoordinate *)ar_coordinates[index]).dataObject;
}

- (ARObjectView *) frontViewWithIndex:(NSInteger)index {
    return ar_coordinateViews[index];
}

- (ARObjectView *) floorViewWithIndex:(NSInteger)index {
    return ar_floorCoordinateViews[index];
}

#pragma mark - LocalizationDelegate methods

// TODO notify the delegate when invalid data is being received from the sensors.
- (void) locationFound:(CLLocation *)location {
    
    if (location.horizontalAccuracy < 0.0 || location.verticalAccuracy < 0.0) {
        NSLog(@"Invalid location received");
    } else {
        BOOL willStart;
        
        if (!centerCoordinate) {
            // TODO only update if change is significant
            willStart = YES;
            centerCoordinate = [ARGeoCoordinate coordinateWithLocation:location];
        } else {
            willStart = NO;
            centerCoordinate.geoLocation = location;
        }
        
        maximumScaleDistance = 0.0;
        for (ARGeoCoordinate *geoLocation in ar_coordinates) {
            [geoLocation calibrateUsingOrigin:location useAltitude:useAltitude];
            if (geoLocation.radialDistance > maximumScaleDistance) {
                maximumScaleDistance = geoLocation.radialDistance;
            }
        }
        radar.farthest = maximumScaleDistance;
        
        if (willStart) {
            [self doStart];
        }
    }
}


- (void) headingFound:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy == -1.0) {
        NSLog(@"Invalid heading");
    } else {
        double value = newHeading.magneticHeading + radiansToDegrees(orientationSupporter.rotationAngle);
    
        centerCoordinate.azimuth = fmod(value, 360.0) * (2 * (M_PI / 360.0));
    }
}

- (void) locationUnavailable {
    NSLog(@"Location unavailable!");
}

#pragma mark - ARObjectView controller method

- (void) viewTouched:(ARObjectView *) view{
    if (lookingType == kFrontLookingType) {
        [delegate itemTouchedWithIndex:[ar_coordinateViews indexOfObject:view]];
    } else {
        [delegate itemTouchedWithIndex:[ar_floorCoordinateViews indexOfObject:view]];
    }
}


@end
