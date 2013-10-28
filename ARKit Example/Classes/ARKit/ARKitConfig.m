//
//  ARKitConfig.m
//  ARKit Example
//
//  Created by Carlos on 21/10/13.
//
//

#import "ARKitConfig.h"

static const BOOL DEFAULT_SHOWS_FLOOR_IMAGES_CONFIG                 = YES;
static const BOOL DEFAULT_SCALE_VIEWS_BASED_ON_DISTANCE_CONFIG      = YES;
static const CGFloat DEFAULT_MINIMUM_SCALE_FACTOR_CONFIG            = 0.5;
static const BOOL DEFAULT_ROTATE_VIEWS_BASED_ON_PERSPECTIVE_CONFIG  = YES;
static const CGFloat DEFAULT_MAXIMUM_ROTATION_ANGLE_CONFIG          = M_PI / 6.0;
static const CGFloat DEFAULT_UPDATE_FREQUENCY_CONFIG                = 1.0 / 20.0;
static const BOOL DEFAULT_USE_ALTITUDE_CONFIG                       = NO;
static const BOOL DEFAULT_DEBUG_MODE_CONFIG                         = NO;
static const UIInterfaceOrientation DEFAULT_ORIENTATION_CONFIG      = UIInterfaceOrientationPortrait;

@implementation ARKitConfig

+ (ARKitConfig *) defaultConfigFor:(id<ARViewDelegate>) delegate {
    
    ARKitConfig *config = [[ARKitConfig alloc] init];
    config.showsFloorImages = DEFAULT_SHOWS_FLOOR_IMAGES_CONFIG;
    config.scaleViewsBasedOnDistance = DEFAULT_SCALE_VIEWS_BASED_ON_DISTANCE_CONFIG;
    config.minimumScaleFactor = DEFAULT_MINIMUM_SCALE_FACTOR_CONFIG;
    config.rotateViewsBasedOnPerspective = DEFAULT_ROTATE_VIEWS_BASED_ON_PERSPECTIVE_CONFIG;
    config.maximumRotationAngle = DEFAULT_MAXIMUM_ROTATION_ANGLE_CONFIG;
    config.updateFrequency = DEFAULT_UPDATE_FREQUENCY_CONFIG;
    config.useAltitude = DEFAULT_USE_ALTITUDE_CONFIG;
    config.debugMode = DEFAULT_DEBUG_MODE_CONFIG;
    config.orientation = DEFAULT_ORIENTATION_CONFIG;
    config.delegate = delegate;
    config.radarPoint = CGPointZero;
    config.loadingView = nil;
    
    return config;
}

@end
