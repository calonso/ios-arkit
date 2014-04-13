iOS Augmented Reality Engine
=========

I'm glad to share this engine that I've been developing from time to time with all of you. It's based on the [iPhone ARKit](https://github.com/zac/iphonearkit).

##Core Features:

 * Fully compatible with all versions of iOS from 5.0 onwards.
 * Supports all orientations.
 * Scales and rotates displayed objects based on distance and orientation.
 * Allows user interaction with displayed objects.
 * Displayed objects positions are updated live (According to the user’s position).
 * Supports and distinguishes front looking as well as floor looking .
 * Allows any custom overlay views.
 * Builtin support for radar view.
 * Fully customisable.

##Usage:

First you need to copy and paste the folder ARKit and all its contents into your project. Then implement the ARViewDelegate in any of your classes.

    #import "ARKit.h"

    #pragma mark - ARViewDelegate protocol Methods

    - (ARObjectView *)viewForCoordinate:(ARGeoCoordinate *)coordinate floorLooking:(BOOL)floorLooking {
      ARObjectView *view = nil;
    
      if (floorLooking) {
        // Build the floor looking view
      } else {
        // Build the front looking view
      }
      return view;

    }

    - (void) itemTouchedWithIndex:(NSInteger)index {
       // An item has been touched. React accordingly (if necessary)
    }

    - (void) didChangeLooking:(BOOL)floorLooking {
      if (floorLooking) {
        // The user has began looking at the floor    
      } else {
        // The user has began looking front
      }
    }
 
This class is now ready to provide the information that the engine requires and also to respond to user's interaction. Now, to instantiate the engine and show the augmented reality view:

    // Create the location
    CLLocation *location = [[CLLocation alloc] initWithLatitude:51.500622 longitude:-0.126662];
    ARGeoCoordinate *london = [ARGeoCoordinate coordinateWithLocation:location];
    london.dataObject = @"London";
    
    // Given that self is the ARViewDelegate
    ARKitConfig *config = [ARKitConfig defaultConfigFor:self];
    
    // Instantiate the engine
    ARKitEngine *engine = [[ARKitEngine alloc] initWithConfig:config];
    // Provide coordinates to show
    [engine addCoordinates:@[london]];
    // And fire it up!
    [engine startListening];

At this moment you should be enjoying a fully featured augmented reality view showing the view you provided in your viewForCoordinate implementation when you head your device to London city! And when the sad moment of shutting down the augmented reality view comes, then simply...

    [engine hide];

And that's all!! For more information on how to add custom overlay views, configure the radar position, start the engine in different orientations or better understanding of the front/floor looking feature, please run the provided example project.

## Acknowledgements

 * [Zac White](https://github.com/zac). For his awesome iPhone ARKit that I used as the starting point for this engine.


