//
//  ViewController.m
//  ARKit Example
//
//  Created by Carlos on 21/10/13.
//
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidLoad {
    selectedIndex = -1;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:34.052337 longitude:-118.243680];
    ARGeoCoordinate *la = [ARGeoCoordinate coordinateWithLocation:location];
    la.dataObject = @"Los Angeles";
    
    location = [[CLLocation alloc] initWithLatitude:40.71448 longitude:-74.00598];
    ARGeoCoordinate *ny = [ARGeoCoordinate coordinateWithLocation:location];
    ny.dataObject = @"New York";
    
    location = [[CLLocation alloc] initWithLatitude:51.500622 longitude:-0.126662];
    ARGeoCoordinate *london = [ARGeoCoordinate coordinateWithLocation:location];
    london.dataObject = @"London";
    
    location = [[CLLocation alloc] initWithLatitude:39.904459 longitude:116.406847];
    ARGeoCoordinate *pekin = [ARGeoCoordinate coordinateWithLocation:location];
    pekin.dataObject = @"Beijing";
    
    location = [[CLLocation alloc] initWithLatitude:55.756151 longitude:37.61727];
    ARGeoCoordinate *mos = [ARGeoCoordinate coordinateWithLocation:location];
    mos.dataObject = @"Moscow";
    
    points = @[la, ny, london, pekin, mos];
}

- (IBAction)showAR:(id)sender {
    ARKitConfig *config = [ARKitConfig defaultConfigFor:self];
    config.orientation = self.interfaceOrientation;
    
    CGSize s = [UIScreen mainScreen].bounds.size;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        config.radarPoint = CGPointMake(s.width - 50, s.height - 50);
    } else {
        config.radarPoint = CGPointMake(s.height - 50, s.width - 50);
    }
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [closeBtn sizeToFit];
    [closeBtn addTarget:self action:@selector(closeAr) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.center = CGPointMake(50, 50);
    
    engine = [[ARKitEngine alloc] initWithConfig:config];
    [engine addCoordinates:points];
    [engine addExtraView:closeBtn];
    [engine startListening];
}

- (void) closeAr {
    [engine hide];
}

#pragma mark - ARViewDelegate protocol Methods

- (ARObjectView *)viewForCoordinate:(ARGeoCoordinate *)coordinate floorLooking:(BOOL)floorLooking {
    NSString *text = (NSString *)coordinate.dataObject;
    
    ARObjectView *view = nil;
    
    if (floorLooking) {
        UIImage *arrowImg = [UIImage imageNamed:@"arrow.png"];
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowImg];
        view = [[ARObjectView alloc] initWithFrame:arrowView.bounds];
        [view addSubview:arrowView];
        view.displayed = NO;
    } else {
        UIImageView *boxView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box.png"]];
        boxView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(4, 16, boxView.frame.size.width - 8, 20)];
        lbl.font = [UIFont systemFontOfSize:17];
        lbl.minimumFontSize = 2;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = text;
        lbl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        view = [[ARObjectView alloc] initWithFrame:boxView.frame];
        [view addSubview:boxView];
        [view addSubview:lbl];
    }
    
    [view sizeToFit];
    return view;
}

- (void) itemTouchedWithIndex:(NSInteger)index {
    selectedIndex = index;
    NSString *name = (NSString *)[engine dataObjectWithIndex:index];
    currentDetailView = [[NSBundle mainBundle] loadNibNamed:@"DetailView" owner:nil options:nil][0];
    currentDetailView.nameLbl.text = name;
    [engine addExtraView:currentDetailView];
}

- (void) didChangeLooking:(BOOL)floorLooking {
    if (floorLooking) {
        if (selectedIndex != -1) {
            [currentDetailView removeFromSuperview];
            ARObjectView *floorView = [engine floorViewWithIndex:selectedIndex];
            floorView.displayed = YES;
        }
    } else {
        if (selectedIndex != -1) {
            ARObjectView *floorView = [engine floorViewWithIndex:selectedIndex];
            floorView.displayed = NO;
            selectedIndex = -1;
        }
    }
}

@end
