//
//  ARKitConfig.h
//  ARKit Example
//
//  Created by Carlos on 21/10/13.
//
//

#import <Foundation/Foundation.h>
#import "ARViewDelegate.h"

@interface ARKitConfig : NSObject

// Do we need to show different images when floor looking?
@property (nonatomic) BOOL showsFloorImages;

// Does the views need to be scaled based on distance?
@property (nonatomic) BOOL scaleViewsBasedOnDistance;

// If so, which is the minimum scale factor?
@property (nonatomic) CGFloat minimumScaleFactor;

// Does the views need to be rotated based on perspective?
@property (nonatomic) BOOL rotateViewsBasedOnPerspective;

// If so, which is the maximum rotation angle?
@property (nonatomic) CGFloat maximumRotationAngle;

// Which is the rendering update frequency?
@property (nonatomic) CGFloat updateFrequency;

// Do you want the engine to consider geopoints altitude?
@property (nonatomic) BOOL useAltitude;

// Do you want to use the debug mode?
@property (nonatomic) BOOL debugMode;

// In which orientation will the rendering be made?
@property (nonatomic) UIInterfaceOrientation orientation;

// The delegate to which notify touches and so
@property (nonatomic, strong) id<ARViewDelegate> delegate;

// Where is the point where you want to place the radar view?
@property (nonatomic) CGPoint radarPoint;

// Do you want to use a custom loading view or the default one? (nil = default)
@property (nonatomic, strong) UIView *loadingView;



+ (ARKitConfig *) defaultConfigFor:(id<ARViewDelegate>) delegate;

@end
