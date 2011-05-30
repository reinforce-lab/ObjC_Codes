//
//  assetThumbnailView.h
//  videoCutout
//
//  Created by 上原 昭宏 on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol assetSelectionDelegate
-(void)assetSelected:(ALAsset *)asset;
-(void)assetSelectionCanceled;
@end

@interface assetThumbnailView : UIControl { 
@private	
	NSObject<assetSelectionDelegate> *delegate_;

	ALAsset *asset_;
	CALayer *assetView_;	
	UILabel *labelView_;
}

@property (nonatomic, assign) NSObject<assetSelectionDelegate> *delegate;

-(void)setAsset:(ALAsset *)asset;
@end
