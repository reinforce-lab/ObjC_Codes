//
//  assetPickupViewController.m
//  videoCutout
//
//  Created by 上原 昭宏 on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "assetPickupViewController.h"

@implementation assetPickupViewController
-(id)initWithDelegate:(NSObject<assetSelectionDelegate> *)delegate
{
	self = [super init];
	if(self) {
		self.navigationBar.barStyle = UIBarStyleBlack;
		assetTableViewController *ctr = [[assetTableViewController alloc] initWithDeleate:delegate];
		[self pushViewController:ctr animated:NO];
		[ctr release];
	}
	return self;
}
- (void)dealloc
{
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - View lifecycle
@end
