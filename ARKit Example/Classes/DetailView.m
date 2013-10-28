//
//  DetailView.m
//  ARKit Example
//
//  Created by Carlos on 25/10/13.
//
//

#import "DetailView.h"

@implementation DetailView

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            CGSize s = [UIScreen mainScreen].bounds.size;
            self.frame = CGRectMake(0, 0, s.height, s.width);
        } else {
            self.frame = [UIScreen mainScreen].bounds;
        }
    }
    return self;
}

- (IBAction)close {
    [self removeFromSuperview];
}

@end
