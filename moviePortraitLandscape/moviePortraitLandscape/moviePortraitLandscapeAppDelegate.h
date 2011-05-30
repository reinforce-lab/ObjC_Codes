//
//  moviePortraitLandscapeAppDelegate.h
//  moviePortraitLandscape
//
//  Created by 上原 昭宏 on 11/05/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class moviePortraitLandscapeViewController;

@interface moviePortraitLandscapeAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet moviePortraitLandscapeViewController *viewController;

@end
