//
//  assetPickupViewController.m
//  videoCutout
//
//  Created by 上原 昭宏 on 11/05/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "assetTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "assetTableViewCell.h"

#define ASSET_ROW_HEIGHT (75 + 4)

@interface assetTableViewController()
-(void)loadAssetsGroup:(ALAssetsGroup *)assetsGroup;
-(void)finishLoadingAssetsGroup;
-(void)loadAsset:(ALAsset *)asset index:(NSUInteger)index;
-(void)addAssetArrays:(NSArray *)assetVOs;
-(void)selectionCanceled:(id)sender;
@end

@implementation assetTableViewController
#pragma mark - Constructor
-(id)initWithDeleate:(NSObject<assetSelectionDelegate> *)delegate
{
	self = [super init];
	if(self) {		
		delegate_ = [delegate retain];
		// インスタンス確保
		assets_ = [[NSMutableArray array] retain];
		assetArrays_ = [[NSMutableArray array] retain];
		assetArraysCache_ = [[NSMutableArray array] retain];
	}
	return self;
}
- (void)dealloc
{
	[assets_ release];
	[assetArrays_ release];
	[assetArraysCache_ release];

	[delegate_ release];
	
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// テーブル表示
	self.tableView.separatorColor = [UIColor clearColor];
	self.tableView.allowsSelection = NO;
	// ナビゲーションバータイトル
	self.navigationItem.title = @"動画選択";
	// ナビゲーションバーボタン
	UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] 
									   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
									   target:self 
									   action:@selector(selectionCanceled:)];
	[self.navigationItem setRightBarButtonItem:rightBarButton];
	[rightBarButton release];
			
	// 読み込み開始
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library 
	 enumerateGroupsWithTypes:ALAssetsGroupAll
	 usingBlock: ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
		 //処理停止		 
		 if(stopUpdating_) {		
			 *stop = YES;
			 return;
		 }		
		// 数え上げの最後にnilが渡される
		if(assetsGroup) {
			[self loadAssetsGroup:assetsGroup];
		} else {
			// グループ読み出し完了
			[self finishLoadingAssetsGroup];
		}}
	 failureBlock:^(NSError *error) {
		 NSLog(@"No groups");
	 }];	
	[library release];
}
- (void)viewDidUnload
{		
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Private methods
-(void)loadAssetsGroup:(ALAssetsGroup *)assetsGroup
{
	// 動画選択フィルタを設定
	[assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
	NSEnumerationOptions options = 0;
	// アセット読み出し
	[assetsGroup 
	 enumerateAssetsWithOptions:options 
	 usingBlock: ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
		// 処理の中断
		if(stopUpdating_) {
			*stop = YES;
			return;
		}
		// アセットの更新
		if(asset) {
			[self loadAsset:asset index:index];
		}
	}];
}
-(void)finishLoadingAssetsGroup
{
	if([assets_ count] > 0) {
		[assetArraysCache_ addObject:[NSArray arrayWithArray:assets_]];
		[assets_ removeAllObjects];	
	}
	// Row更新
	if([assetArraysCache_ count] > 0) {
		[self performSelectorOnMainThread:@selector(addAssetArrays:) withObject:assetArraysCache_ waitUntilDone:YES];
		[assetArraysCache_ removeAllObjects];
	}	
	// TBDライブラリがないときの処理	
}
-(void)loadAsset:(ALAsset *)asset index:(NSUInteger)index
{
	[assets_ addObject:asset];
	if([assets_ count] == 4) {
		[assetArraysCache_ addObject:[NSArray arrayWithArray:assets_]];
		[assets_ removeAllObjects];
		// 行を追加
		if([assetArraysCache_ count] == 10) {
			[self performSelectorOnMainThread:@selector(addAssetArrays) withObject:assetArraysCache_ waitUntilDone:YES];
			[assetArraysCache_ removeAllObjects];
		}
	}
}
-(void)addAssetArrays:(NSArray *)assetVOs
{
	[self.tableView beginUpdates];

	// インデックス位置を記録
	NSUInteger oldCount = [assetArrays_ count];
	NSUInteger newCount = oldCount + [assetVOs count];

	// 配列を更新
	[assetArrays_ addObjectsFromArray:assetVOs];
	
	// Rowインデックス更新
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[assetVOs count]];
	for(NSUInteger i = oldCount; i < newCount; i++) {
		[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
	}
	[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];

	// 更新終了
	[self.tableView endUpdates];
}
-(void)selectionCanceled:(id)sender
{
	[delegate_ assetSelectionCanceled];
}

#pragma mark - UITableViewDataSource Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [assetArrays_ count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// セルインスタンス取得
	assetTableViewCell *cell = (assetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAssetTableViewCellID];
	if(cell == nil) {
		cell = [[[assetTableViewCell alloc] init] autorelease];
	}
	
	// View更新
	cell.delegate = delegate_;
	[cell setAssetArray:[assetArrays_ objectAtIndex:indexPath.row]];

	return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ASSET_ROW_HEIGHT;
}

@end
