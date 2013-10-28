//
//  ARGeoCoordinate.h
//  ARKitDemo
//
//  Created by Haseman on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * (180.0/M_PI))

@interface ARGeoCoordinate : NSObject {

}

@property (nonatomic, strong) id dataObject;
@property (nonatomic) double radialDistance;
@property (nonatomic) double inclination;
@property (nonatomic) double azimuth;
@property (nonatomic, strong) CLLocation *geoLocation;

+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location;
- (void)calibrateUsingOrigin:(CLLocation *)origin useAltitude:(BOOL) useAltitude;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToCoordinate:(ARGeoCoordinate *)otherCoordinate;

@end
