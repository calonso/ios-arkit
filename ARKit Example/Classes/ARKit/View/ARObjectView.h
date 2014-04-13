//
//  ARObjectView.h
//  Santander
//
//  Created by Carlos on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARKitEngine;

@interface ARObjectView : UIView

@property (nonatomic, weak) ARKitEngine *controller;
@property (nonatomic) BOOL displayed;

@end
