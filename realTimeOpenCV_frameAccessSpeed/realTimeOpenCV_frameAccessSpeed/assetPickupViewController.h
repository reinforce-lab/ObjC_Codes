//
//  assetPickupViewController.h
//  videoCutout
//
//  Created by 上原 昭宏 on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "assetTableViewController.h"

@interface assetPickupViewController : UINavigationController {   
}
-initWithDelegate:(NSObject<assetSelectionDelegate> *)delegate;
@end
