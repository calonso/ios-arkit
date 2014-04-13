//
//  RadarView.h
//  Santander
//
//  Created by Carlos on 22/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARGeoCoordinate.h"

@interface RadarView : UIView {
	NSMutableArray *points;
	UIView *dotsView;
	double farthest;
}

@property (nonatomic) double farthest;
@property (nonatomic, strong) NSMutableArray *points;

- (id)initAtPoint:(CGPoint)middlePoint;

- (void) updatePoints:(ARGeoCoordinate *)centerCoord;

@end
