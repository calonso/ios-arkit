//
//  ARKitEngine.h
//  ARModule
//
//  Created by Carlos on 06/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "LocalizationDelegate.h"
#import "ARViewDelegate.h"
#import "ARGeoCoordinate.h"
#import "RadarView.h"
#import "ARKitConfig.h"

@class ARObjectView;

typedef struct {
    CGFloat                 xOffset;
    CGFloat                 rotationAngle;
    UIInterfaceOrientation  orientation;
    CGSize                  viewSize;
} ARKitOrientationSupport;

typedef enum {
    kFrontLookingType,
    kFloorLookingType
} ARKitLookingType;

@interface ARKitEngine : NSObject <LocalizationDelegate, UIAccelerometerDelegate> {
    
@private
    NSMutableArray *ar_coordinates;
	NSMutableArray *ar_coordinateViews;
	NSMutableArray *ar_floorCoordinateViews;
    
    id<ARViewDelegate> delegate;
        
    UIImagePickerController *cameraController;
    
    RadarView *radar;
    UIView *ar_overlayView;
    UILabel *ar_debugView;
    
    NSTimer *_updateTimer;
    
    double maximumScaleDistance;
    
    BOOL showsFloorImages;
    BOOL scaleViewsBasedOnDistance;
    CGFloat minimumScaleFactor;
    BOOL rotateViewsBasedOnPerspective;
    CGFloat maximumRotationAngle;
    CGFloat updateFrequency;
    BOOL debugMode;
    BOOL useAltitude;
    ARKitLookingType lookingType;
    
    ARGeoCoordinate *centerCoordinate;
    
    CMMotionManager *motionManager;
    
    UIViewController *baseViewController;
    
    ARKitOrientationSupport orientationSupporter;
    
    UIView *loadingView;
}

- (id) initWithConfig:(ARKitConfig *) conf;

- (void) addCoordinate:(ARGeoCoordinate *)coordinate;
- (void) addCoordinates:(NSArray *)newCoordinates;
- (void) removeCoordinate:(ARGeoCoordinate *)coordinate;
- (void) removeCoordinates:(NSArray *)coordinates;
- (void) removeAllCoordinates;

- (void) addExtraView:(UIView *)extra;

- (void) viewTouched:(ARObjectView *) view;

- (void) startListening;
- (void) hide;

- (id) dataObjectWithIndex:(NSInteger)index;
- (ARObjectView *) frontViewWithIndex:(NSInteger)index;
- (ARObjectView *) floorViewWithIndex:(NSInteger)index;


@end
