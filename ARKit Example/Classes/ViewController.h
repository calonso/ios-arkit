//
//  ViewController.h
//  ARKit Example
//
//  Created by Carlos on 21/10/13.
//
//

#import <UIKit/UIKit.h>
#import "ARKit.h"
#import "DetailView.h"

@interface ViewController : UIViewController<ARViewDelegate>  {
    NSArray *points;
    ARKitEngine *engine;
    
    NSInteger selectedIndex;
    DetailView *currentDetailView;
}

@end
