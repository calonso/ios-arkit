//
//  RadarView.m
//  Santander
//
//  Created by Carlos on 22/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RadarView.h"


@implementation RadarView

@synthesize points, farthest;

- (id)initAtPoint:(CGPoint)middlePoint {
    if ((self = [super initWithFrame:CGRectZero])) {
        // Initialization code
		UIImage *radarImg = [UIImage imageNamed:@"radar.png"];
		UIImageView *background = [[UIImageView alloc] initWithImage: radarImg];
		[self addSubview:background];

		self.frame = CGRectMake(middlePoint.x - radarImg.size.width / 2, middlePoint.y - radarImg.size.height / 2, radarImg.size.width, radarImg.size.height);
		
		dotsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:dotsView];
    }
    return self;
}

- (void) updatePoints:(ARGeoCoordinate *)centerCoord {
	double centerAzimuth = centerCoord.azimuth + M_PI / 2;
	if (centerAzimuth < 0.0) {
		centerAzimuth = 2 * M_PI + centerAzimuth;
	}
	
	UIImage *dot = [UIImage imageNamed:@"radar_dot.png"];
	
	for (UIView *sub in dotsView.subviews) {
		[sub removeFromSuperview];
	}
	
	for (ARGeoCoordinate *coord in points) {
		double coordAzimuth = coord.azimuth - centerAzimuth;
		if (coordAzimuth < 0.0) {
			coordAzimuth = 2 * M_PI + coordAzimuth;
		}
		CGPoint pt;
		
		pt.x = dotsView.center.x + cos(coordAzimuth) * coord.radialDistance * self.frame.size.width / (2 * farthest);
		pt.y = dotsView.center.y + sin(coordAzimuth) * coord.radialDistance * self.frame.size.height / (2 * farthest);
		
		UIImageView *point = [[UIImageView alloc] initWithImage:dot];
		point.center = pt;
		
		[dotsView addSubview:point];
	}
}

@end
