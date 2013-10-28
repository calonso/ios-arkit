//
//  LocalizationHelper.h
//  ARModule
//
//  Created by Carlos on 06/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocalizationDelegate.h"

typedef enum {
    kLocalizationUnknown,
    kLocalizationDisabled,
    kLocalizationEnabled
} kLocalizationStatus;

@interface LocalizationHelper : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    UIView *loadingView;
    
    kLocalizationStatus localizationStatus;
    BOOL isHeadingInfoAvailable;
    
    NSMutableArray *onceRegistered;
    NSMutableArray *registered;
    
    id<LocalizationDelegate> locDelegate;
    
    CLLocation *lastLocation;
}

+ (LocalizationHelper *) sharedHelper;
- (BOOL) canReceiveHeadingUpdates;
- (void) registerForUpdates:(id<LocalizationDelegate>)receiver once:(BOOL)once;
- (void) deregisterForUpdates:(id<LocalizationDelegate>)receiver;

@end
