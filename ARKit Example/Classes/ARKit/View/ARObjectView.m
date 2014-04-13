//
//  ARObjectView.m
//  Santander
//
//  Created by Carlos on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ARObjectView.h"
#import "ARKitEngine.h"

@implementation ARObjectView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.userInteractionEnabled = YES;
        self.opaque = YES;
        _displayed = YES;
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // TODO fix touch on objectviews at half side right
	[_controller viewTouched:self];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}


@end
