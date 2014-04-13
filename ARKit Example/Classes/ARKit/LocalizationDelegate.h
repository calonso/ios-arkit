//
//  LocalizationDelegate.h
//  ARModule
//
//  Created by Carlos on 06/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocalizationDelegate <NSObject>

- (void) locationFound:(CLLocation *)location;
- (void) headingFound:(CLHeading *)heading;
- (void) locationUnavailable;

@end
