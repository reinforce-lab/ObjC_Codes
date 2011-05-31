//
//  assetRowView.m
//  videoCutout
//
//  Created by 上原 昭宏 on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "assetTableViewCell.h"
#import "assetThumbnailView.h"

#define THUMBNAIL_WIDTH  75
#define THUMBNAIL_HEIGHT 75

@implementation assetTableViewCell
#pragma mark - Properties
@dynamic delegate;
-(void)setDelegate:(NSObject<assetSelectionDelegate> *)delegate
{
	delegate_ = delegate;
	for(int i =0; i < 4; i++) {
		thumbnails_[i].delegate = delegate_;
	}
}
-(NSObject<assetSelectionDelegate> *)getDelegate
{
	return delegate_;
}

#pragma mark - Constructor
-(id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAssetTableViewCellID];
    if (self) {	
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		// サムネイル構築
		for(int i=0; i < 4; i++) {
			CGFloat x = 4 * (i+1) + 75 * i;
			CGRect frame = CGRectMake(x, 2, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT);
			assetThumbnailView *view = [[assetThumbnailView alloc] initWithFrame:frame];
			thumbnails_[i] = view;
			[self.contentView addSubview:view];
			[view release];
		}
    }
    return self;
}
- (void)dealloc
{
    [super dealloc];
}

#pragma mark - public methods
-(void)setAssetArray:(NSArray *)assetArray
{
	int cnt = ([assetArray count] < 4) ? [assetArray count] : 4;
	int i = 0;
	for(i =0; i < cnt; i++) {
		[thumbnails_[i] setAsset:[assetArray objectAtIndex:i]];
	}
	for(; i < 4; i++) {
		[thumbnails_[i] setAsset:nil];
	}
}
@end