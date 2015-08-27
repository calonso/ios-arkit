//
//  LocalizationHelper.m
//  ARModule
//
//  Created by Carlos on 06/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocalizationHelper.h"

static LocalizationHelper *sharedHelper;

@implementation LocalizationHelper

#pragma mark - Singleton Initialization

+ (LocalizationHelper *) sharedHelper {
	@synchronized ([LocalizationHelper class]) {
		if (!sharedHelper) {
			sharedHelper = [[LocalizationHelper alloc] init];
		}
		return sharedHelper;
	}
	return nil;
}

- (id) init {
    if ((self = [super init])) {
        locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
        locationManager.headingFilter = kCLHeadingFilterNone;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		locationManager.distanceFilter = kCLDistanceFilterNone;
	[locationManager requestAlwaysAuthorization];
        
        isHeadingInfoAvailable = [CLLocationManager headingAvailable];
        
        onceRegistered = [[NSMutableArray alloc] init];
        registered = [[NSMutableArray alloc] init];
        
        localizationStatus = kLocalizationUnknown;
    }
    return self;
}

#pragma mark - Clients management 

- (void) registerForUpdates:(id<LocalizationDelegate>)receiver once:(BOOL)once {
    if (localizationStatus == kLocalizationDisabled) {
        [self locationManager:locationManager didFailWithError:nil];
    } else {
        if (once) {
            if (lastLocation) {
                [self locationManager:locationManager didUpdateLocations:@[lastLocation]];
            } else {
                [onceRegistered addObject:receiver];
            }
        } else {
            [registered addObject:receiver];
        }
        if ([registered count] + [onceRegistered count] == 1) {
            [locationManager startUpdatingHeading];
            [locationManager startUpdatingLocation];
        }
    }
}

- (void) deregisterForUpdates:(id<LocalizationDelegate>)receiver {
    if ([registered containsObject:receiver]) {
        [registered removeObject:receiver];
    }
    if ([onceRegistered containsObject:receiver]) {
        [onceRegistered removeObject:receiver];
    }
    
    if (![registered count] && ![onceRegistered count]) {
        [locationManager stopUpdatingHeading];
        [locationManager stopUpdatingLocation];
    }
}

- (BOOL) canReceiveHeadingUpdates {
    return isHeadingInfoAvailable;
}

#pragma mark - CLLocator delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    localizationStatus = kLocalizationEnabled;
    CLLocation *newLocation = [locations lastObject];
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) {
		//Probably a cached result. Restart
		[manager stopUpdatingLocation];
		[manager startUpdatingLocation];
		return; 	
	}
    
	for (id<LocalizationDelegate> delegate in registered) {
        [delegate locationFound:newLocation];
    }
    for (id<LocalizationDelegate> delegate in onceRegistered) {
        [delegate locationFound:newLocation];
    }
    [onceRegistered removeAllObjects];
    if (![registered count]) {
        [manager stopUpdatingLocation];
        [manager stopUpdatingHeading];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	for (id<LocalizationDelegate> delegate in registered) {
        [delegate headingFound:newHeading];
    }
    for (id<LocalizationDelegate> delegate in onceRegistered) {
        [delegate headingFound:newHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {	
	[manager stopUpdatingLocation];
	[loadingView removeFromSuperview];
	localizationStatus = kLocalizationDisabled;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
													message:NSLocalizedString(@"GPS_Unavailable", @"") 
												   delegate:nil 
										  cancelButtonTitle:NSLocalizedString(@"Ok", @"") 
										  otherButtonTitles:nil];
	[alert show];
	[locDelegate locationUnavailable];
}

@end
