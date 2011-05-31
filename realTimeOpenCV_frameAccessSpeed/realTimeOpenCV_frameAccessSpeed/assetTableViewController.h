//
//  assetPickupViewController.h
//  videoCutout
//
//  Created by 上原 昭宏 on 11/05/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "assetTableViewCell.h"

@interface assetTableViewController : UITableViewController {
@private	
	NSObject<assetSelectionDelegate> *delegate_;
	
	BOOL stopUpdating_;
	
	NSMutableArray *assets_;
	NSMutableArray *assetArraysCache_;
	NSMutableArray *assetArrays_;
}
-initWithDeleate:(NSObject<assetSelectionDelegate> *)delegate;
@end
