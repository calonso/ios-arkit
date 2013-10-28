//
//  ARGeoCoordinate.m
//  ARKitDemo
//
//  Created by Haseman on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import "ARGeoCoordinate.h"


@implementation ARGeoCoordinate

@synthesize geoLocation;

@synthesize radialDistance, inclination, azimuth;

@synthesize dataObject;

- (float)angleFromCoordinate:(CLLocationCoordinate2D)first toCoordinate:(CLLocationCoordinate2D)second {
	float longitudinalDifference = second.longitude - first.longitude;
	float latitudinalDifference = second.latitude - first.latitude;
	float possibleAzimuth = (M_PI * .5f) - atan(latitudinalDifference / longitudinalDifference);
	if (longitudinalDifference > 0) return possibleAzimuth;
	else if (longitudinalDifference < 0) return possibleAzimuth + M_PI;
	else if (latitudinalDifference < 0) return M_PI;
	
	return 0.0f;
}

- (void)calibrateUsingOrigin:(CLLocation *)origin useAltitude:(BOOL) useAltitude {
	
	if (!self.geoLocation) return;
	
	double baseDistance = [origin distanceFromLocation:self.geoLocation];
	
	self.radialDistance = sqrt(pow(origin.altitude - self.geoLocation.altitude, 2) + pow(baseDistance, 2));
		
	float angle = sin(ABS(origin.altitude - self.geoLocation.altitude) / self.radialDistance);
	
    if (!useAltitude) {
        angle = 0;
    }
    
	if (origin.altitude > self.geoLocation.altitude) angle = -angle;
	
	self.inclination = angle;
	self.azimuth = [self angleFromCoordinate:origin.coordinate toCoordinate:self.geoLocation.coordinate];
}

+ (ARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location {
	ARGeoCoordinate *newCoordinate = [[ARGeoCoordinate alloc] init];
	newCoordinate.geoLocation = location;

	return newCoordinate;
}

- (NSUInteger)hash{
	return ([dataObject hash] + (int)(self.radialDistance + self.inclination + self.azimuth));
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToCoordinate:other];
}

- (BOOL)isEqualToCoordinate:(ARGeoCoordinate *)otherCoordinate {
    if (self == otherCoordinate) return YES;
    
	BOOL equal = self.radialDistance == otherCoordinate.radialDistance;
	equal &= self.inclination == otherCoordinate.inclination;
	equal &= self.azimuth == otherCoordinate.azimuth;
	equal &= self.dataObject == otherCoordinate.dataObject;
	
	return equal;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"r: %.3fm φ: %.3f° θ: %.3f°", self.radialDistance, radiansToDegrees(self.azimuth), radiansToDegrees(self.inclination)];
}



@end
