//
//  ARViewDelegate.h
//  ARModule
//
//  Created by Carlos on 06/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARObjectView.h"
#import "ARGeoCoordinate.h"

@protocol ARViewDelegate <NSObject>

- (ARObjectView *)viewForCoordinate:(ARGeoCoordinate *)coordinate floorLooking:(BOOL)floorLooking;
- (void) itemTouchedWithIndex:(NSInteger) index;
- (void) didChangeLooking:(BOOL)floorLooking;

@end
