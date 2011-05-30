//
//  assetThumbnailView.m
//  videoCutout
//
//  Created by 上原 昭宏 on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "assetThumbnailView.h"

@interface assetThumbnailView()
-(void)touchUpInside:(id)sender;
@end

@implementation assetThumbnailView
#pragma mark - properties
@synthesize delegate = delegate_;

#pragma mark - constructor
-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self) {	
		assetView_ = [CALayer new];
		assetView_.frame = self.bounds;
		[self.layer addSublayer:assetView_];
		[assetView_ release];
		
		// 時間表示部分を構築
		CGFloat width = self.frame.size.width;
		CGFloat height = self.frame.size.height;
		CGRect subtitleRect = CGRectMake(0, 2 + (height - 17), width, 17);

		UIView *view = [[UIView alloc] initWithFrame:subtitleRect];
		view.backgroundColor = [UIColor blackColor];
		view.alpha = 0.3;
		view.userInteractionEnabled = NO;
		[self addSubview:view];
		[view release];
		
		labelView_ =[[UILabel alloc] initWithFrame:subtitleRect];
		labelView_.backgroundColor = [UIColor clearColor];
		labelView_.textColor = [UIColor whiteColor];
		labelView_.textAlignment = UITextAlignmentRight;
		labelView_.font = [UIFont systemFontOfSize:14];
		labelView_.text = @"00:00";		
		labelView_.userInteractionEnabled = NO;
		[self addSubview:labelView_];
		[labelView_ release];
		
		[self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}
-(void)dealloc
{
	[super dealloc];
}
#pragma mark - event handler
-(void)touchUpInside:(id)sender
{
	[delegate_ assetSelected:asset_];
}
#pragma mark - public methods
-(void)setAsset:(ALAsset *)asset
{
	asset_ = asset;
	if(asset == nil) {
		self.hidden = YES;
	} else {	
		self.hidden = NO;
		// サムネイル画像を更新
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		assetView_.contents = (id)[asset thumbnail];
		[CATransaction commit];

		// 時間を更新
		int seconds =(int)[(NSNumber *) [asset valueForProperty:ALAssetPropertyDuration] doubleValue];
		int sec = seconds % 60;
		int min = seconds / 60;
		labelView_.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
	}
}
@end
