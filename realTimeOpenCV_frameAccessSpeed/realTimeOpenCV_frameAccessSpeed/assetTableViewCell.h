//
//  assetRowView.h
//  videoCutout
//
//  Created by 上原 昭宏 on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "assetThumbnailView.h"

#define kAssetTableViewCellID @"com.reinforce-lab.assetTableViewCell"

// 動画のサムネイルを表示するアセット
// 1行の行に 75x75px のサムネイルを 4つまで 4px 間隔で配置。
@interface assetTableViewCell : UITableViewCell {
@private	
	NSObject<assetSelectionDelegate> *delegate_;	
	assetThumbnailView *thumbnails_[4];	
}
@property (nonatomic, assign, setter = setDelegate:, getter = getDelegate ) NSObject<assetSelectionDelegate> *delegate;

-(void)setAssetArray:(NSArray *)assetArray;
@end
