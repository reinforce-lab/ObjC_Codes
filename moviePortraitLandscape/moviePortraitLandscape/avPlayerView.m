//
//  playControlView.m
//  videoCutout
//
//  Created by AKIHIRO Uehara on 11/04/26.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import "avPlayerView.h"

@interface avPlayerView()
@property (nonatomic, assign) bool isFullScreen;
@property (nonatomic, assign) CMTime currentTime;

-(void)initView;
-(void)initAVPlayer;
-(void)setButtonsPosition:(CGRect)frame;
-(void)toggleFullScreen;
-(void)showButtons;
-(void)hideButtons;

-(void)moveForward;
-(void)moveBackward;
-(void)changeState:(avPlayerStateType)newState;

// event handlers
-(void) singleTapped:(id)sender;
-(void) doubleTapped:(id)sender;
-(void) playerReachFinish:(id)sender;
-(void) startPlayingButtonTouched:(id)sender;
-(void) stopPlayingButtonTouched:(id)sender;
-(void) backwardButtonTouched:(id)sender;
-(void) forwardButtonTouched:(id)sender;
//
-(void)playNormal:(AVAsset *)asset;
-(void)playPrefTrans:(AVAsset *)asset;
-(void)playLayerInst:(AVAsset *)asset;
@end

@implementation avPlayerView
#pragma mark - Properties
@synthesize isFullScreen = isFullScreen_;
@synthesize currentTime = currentTime_;

#pragma mark Constructor
-(id)initWithCoder:(NSCoder *)aDecoder	
{
	self = [super initWithCoder:aDecoder];
	if(self) {
		[self initView];		
	}
	return self;
}
-(void)initAVPlayer
{
	// remove observers
	if(player_) {
		[player_ removeObserver:self forKeyPath:@"status"];
		[player_ removeTimeObserver:timeObserver_];

		[[NSNotificationCenter defaultCenter]
		 removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player_ currentItem]];
	}

	player_ = [[[AVPlayer alloc] init] autorelease];
	[player_ addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:player_];
	timeObserver_ = [player_  addPeriodicTimeObserverForInterval:CMTimeMake(1, 5)
	  queue:dispatch_get_main_queue()
	  usingBlock:^(CMTime time) {
		  if( CMTIME_IS_VALID(time) ) {
//			  NSLog(@"Playing at: %f", CMTimeGetSeconds(time));
			  self.currentTime = time;
		  }
	  }];
	//再生終了のNotificationを設定
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(playerReachFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:[player_ currentItem]];
	//プレイヤを設定
	[avPlayerLayer_ setPlayer:player_];
}
-(void)initView
{
	avPlayerLayer_ = (AVPlayerLayer *)[self layer];
	avPlayerLayer_.videoGravity = AVLayerVideoGravityResize;
	
	// add avplayer
	[self initAVPlayer];		
		
	// タップ識別を組み立てる
	singleTapGestureRecognizer_ = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)] autorelease];
	singleTapGestureRecognizer_.numberOfTapsRequired = 1;
	singleTapGestureRecognizer_.delegate = self;
	doubleTapGestureRecognizer_ = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)] autorelease];
	doubleTapGestureRecognizer_.numberOfTapsRequired = 2;	
	doubleTapGestureRecognizer_.delegate = self;
	// ダブルタップ認識失敗で、シングルタップ認識とする
	[singleTapGestureRecognizer_ requireGestureRecognizerToFail:doubleTapGestureRecognizer_];
	// ジェスチャ識別インスタンスの追加
	[self addGestureRecognizer:singleTapGestureRecognizer_];
	[self addGestureRecognizer:doubleTapGestureRecognizer_];
	
	// add buttons
	startPlayingButton_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[startPlayingButton_ setTitle:@"Play" forState:UIControlStateNormal];
	[startPlayingButton_ addTarget:self action:@selector(startPlayingButtonTouched:) forControlEvents:UIControlEventTouchDown];
	startPlayingButton_.alpha = 0;
	[self addSubview:startPlayingButton_];

	stopPlayingButton_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[stopPlayingButton_ setTitle:@"Stop" forState:UIControlStateNormal];
	[stopPlayingButton_ addTarget:self action:@selector(stopPlayingButtonTouched:) forControlEvents:UIControlEventTouchDown];
	stopPlayingButton_.alpha = 0;
	[self addSubview:stopPlayingButton_];

	forwardButton_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[forwardButton_ setTitle:@">>" forState:UIControlStateNormal];
	[forwardButton_ addTarget:self action:@selector(forwardButtonTouched:) forControlEvents:UIControlEventTouchDown];
	forwardButton_.alpha = 0;
	[self addSubview:forwardButton_];
	
	backwardButton_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[backwardButton_ setTitle:@"<<" forState:UIControlStateNormal];
	[backwardButton_ addTarget:self action:@selector(backwardButtonTouched:) forControlEvents:UIControlEventTouchDown];
	backwardButton_.alpha = 0;
	[self addSubview:backwardButton_]; 
	
	// 動画頭のシャドウ表示
	
	[self setButtonsPosition:self.frame];
	[self changeState:waitingForPlayItem];
}
// ボタンの縦位置設定
-(void)setButtonsPosition:(CGRect)frame
{
	CGPoint center = CGPointMake( frame.size.width /2,  frame.size.height /2);
	
	[startPlayingButton_ setFrame:CGRectMake(center.x - 45, center.y -45, 89, 90)];	
	[stopPlayingButton_ setFrame:CGRectMake(center.x - 45,center.y -45, 89, 90)];
	[forwardButton_ setFrame:CGRectMake(center.x +69, center.y -35, 72, 71)];
	[backwardButton_ setFrame:CGRectMake(center.x -141, center.y -35, 72, 71)];		
}

+(Class)layerClass {
	return [AVPlayerLayer class];
}
- (void)dealloc
{
	[player_ release];
	[playerItem_ release];
	
    [super dealloc];
}
#pragma mark - Private methods
// 全画面表示と個別表示の切り替え
-(void)toggleFullScreen
{	bool changeToFullScreen = ! isFullScreen_;
	[UIView 
	 animateWithDuration:0.5 	
	 animations:^{
		 if(changeToFullScreen) { // フルスクリーンに遷移するなら、ステータスバーは即座に消す
			 self.isFullScreen = YES;
		 }
		 CGRect frame = changeToFullScreen ? CGRectMake(0, 0, 320, 460) : CGRectMake(0, 40, 320, 240);
		 [self setFrame:frame];
		 
		 [self setButtonsPosition:frame];
	 }
	 completion:^(BOOL finished) {
		 if(finished && ! changeToFullScreen) {	
			 self.isFullScreen = NO;
		 }
	 }];	
}
-(void)showButtons
{	
	bool showButton     = NO;
	bool showPlayButton = NO;
	switch (state_) {
		case readyToPlay:
			showButton     = YES;
			showPlayButton = YES;
			break;
		case playing: 
			showButton     = YES;
			showPlayButton = NO;
			break;
		case pausing: 
			showButton     = YES;
			showPlayButton = YES;
			break;
		case playToEnd: 
			showButton     = YES;
			showPlayButton = YES;
			break;
		default: break;
	}

	[UIView 
	 animateWithDuration:0.3 
	 animations: ^{	
		 if(showButton) {			 
			 isButtonsShown_ = YES;		 
			 // 再生、停止ボタンの表示
			 if(showPlayButton) {
				startPlayingButton_.alpha = 1;
				stopPlayingButton_.alpha  = 0;				
			 } else {
				 startPlayingButton_.alpha = 0;
				 stopPlayingButton_.alpha  = 1;			
			 }
			 // 先送り、戻りボタンの表示			
			 forwardButton_.alpha  = 1;
			 backwardButton_.alpha = 1;		
		 }
	 }];
}
-(void)hideButtons
{
	[UIView 
	 animateWithDuration:0.1 
	 animations:^{
		isButtonsShown_ = NO;
		 
		startPlayingButton_.alpha = 0;
		stopPlayingButton_.alpha = 0;
		forwardButton_.alpha = 0;
		backwardButton_.alpha = 0;
	 }];
}

-(void)moveForward
{
	CMTime seekToTime = CMTimeAdd( player_.currentItem.currentTime, CMTimeMake(10, 1));
	[player_ seekToTime:seekToTime];
}
-(void)moveBackward
{
	CMTime seekToTime = CMTimeSubtract(player_.currentItem.currentTime, CMTimeMake(10, 1));
	[player_ seekToTime:seekToTime];
}
-(void)changeState:(avPlayerStateType)newState
{
	state_ = newState;	
	switch (state_) {
		case waitingForPlayItem:
			break;
		case waitingForPlayerReady:
			// 2回目以降の再生ではPlayerItemは再生可能状態になっている。このためNotificationに加えて、ここでもステータスチェックして遷移する。
			if(player_.status == AVPlayerItemStatusReadyToPlay) {
				[self changeState:readyToPlay];
			}
			break;
		case readyToPlay:
			[self changeState:playing];
			break;
		case playing:
			[player_ play];
			break;
		case pausing:
			[player_ pause];
			break;
		case playToEnd:
			[self showButtons];
			break;
		default:
			break;
	}

}
#pragma mark - Event handlers
-(void) singleTapped:(id)sender
{
	if(isButtonsShown_)
		[self hideButtons];
	else 
		[self showButtons];
}
-(void) doubleTapped:(id)sender
{
	[self toggleFullScreen];
}
-(void) playerReachFinish:(id)sender
{
	[self changeState:playToEnd];
}
-(void) startPlayingButtonTouched:(id)sender
{
	// 先頭に巻き戻し
	if(state_ == playToEnd) {
		[player_ seekToTime:kCMTimeZero];
	}
	
	[self changeState:playing];
	[self hideButtons];
}
-(void) stopPlayingButtonTouched:(id)sender
{	
	[self changeState:pausing];
	[self hideButtons];
}
-(void) backwardButtonTouched:(id)sender
{
	[self moveBackward];
	[self hideButtons];
}
-(void) forwardButtonTouched:(id)sender
{
	[self moveForward];
	[self hideButtons];
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	// Let the subviews handle their own touches.	
	return ([touch.view isEqual:self]) ? YES : NO;
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == player_ ) {
		if(state_ == waitingForPlayerReady && player_.status == AVPlayerStatusReadyToPlay) {
			[self changeState:readyToPlay];						
		} else 
			if(player_.status == AVPlayerStatusFailed) {
			NSLog(@"%s", __func__);
			NSLog(@"AVPlayer failed. %@", player_.error);
			// new player instance must be prepare
			[self initAVPlayer];
			[self changeState:waitingForPlayItem];
		}
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - Public methods
// 0 - none, 1 - preferredTransofrm, 2 - layer insruction
-(void)play:(AVAsset *)asset gravity:(NSString *)gravity testMode:(int)testMode
{		
	orientation_  = UIImageOrientationUp;
	isPortrait_  = NO;
	
	NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
	if([tracks	count] != 0) {
		AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
		// 動画の向き、変形を設定
		CGAffineTransform t = videoTrack.preferredTransform;
		// Portrait
		if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)  {orientation_ = UIImageOrientationRight; isPortrait_ = YES;}
		// PortraitUpsideDown
		if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {orientation_ =  UIImageOrientationLeft; isPortrait_ = YES;}
		// LandscapeRight
		if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)   {orientation_ =  UIImageOrientationUp;} 
		// LandscapeLeft
		if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {orientation_ = UIImageOrientationDown;}
	}
		
	avPlayerLayer_.videoGravity = gravity;
	
	switch (testMode) {
		case 0:
			[self playNormal:asset];
			break;
		case 1:
			[self playPrefTrans:asset];
			break;
		case 2:
			[self playLayerInst:asset];
			break;
	}
}

-(void)playNormal:(AVAsset *)asset
{	
	AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	AVMutableComposition *composition = [AVMutableComposition composition];
	
	CGSize videoSize = videoTrack.naturalSize;
	
	// サイズを設定
	composition.naturalSize     = videoSize;

	// Trackを構築
 	AVMutableCompositionTrack *compositionVideoTrack;
	compositionVideoTrack = [composition 
							 addMutableTrackWithMediaType:AVMediaTypeVideo 
							 preferredTrackID:kCMPersistentTrackID_Invalid];	
	[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) 
								   ofTrack:videoTrack 	 
									atTime:kCMTimeZero error:nil];
			
	playerItem_ = [[[AVPlayerItem alloc] initWithAsset:composition] autorelease];

	
	[player_ replaceCurrentItemWithPlayerItem:playerItem_];
			
	[self changeState:waitingForPlayerReady];
}
-(void)playPrefTrans:(AVAsset *)asset
{	
	//AVMutableCOmpositionを設定
	//トラックを取得
	AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	AVMutableComposition *composition = [AVMutableComposition composition];
	AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];	

	// サイズを取得。Portraitだと縦横サイズを回転
	CGSize videoSize = videoTrack.naturalSize;
	if(isPortrait_) {
		videoSize = CGSizeMake(videoSize.height, videoSize.width);
	}
	
	// サイズを設定
	composition.naturalSize     = videoSize; // AVPlayerはこのサイズを見ない
	videoComposition.renderSize = videoSize; // AVPlayerはこのサイズを見る。
//	videoComposition.renderSize = videoTrack.naturalSize;

	videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);

#ifdef TARGET_OS_EMBEDDED
	// WWDC2010 サンプルより。プレビュは解像度を落とすことで処理効率を上げる。大抵HD動画なので、サイズはもう見ない
//	videoComposition.renderScale = 0.5;
#endif
	
	// Trackを構築
 	AVMutableCompositionTrack *compositionVideoTrack;
	compositionVideoTrack = [composition 
							 addMutableTrackWithMediaType:AVMediaTypeVideo 
							 preferredTrackID:kCMPersistentTrackID_Invalid];	
	[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) 
	 ofTrack:videoTrack 	 
	 atTime:kCMTimeZero error:nil];
	compositionVideoTrack.preferredTransform = videoTrack.preferredTransform; // ここでtransformを設定する
		
	playerItem_ = [[[AVPlayerItem alloc] initWithAsset:composition] autorelease];
	playerItem_.videoComposition = videoComposition;
		
	[player_ replaceCurrentItemWithPlayerItem:playerItem_];
	
	[self changeState:waitingForPlayerReady];
}
-(void)playLayerInst:(AVAsset *)asset
{
	//AVMutableCOmpositionを設定
	//トラックを取得
	AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	AVMutableComposition *composition = [AVMutableComposition composition];
	AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];	
	
	// サイズを取得。Portraitだと縦横サイズを回転
	CGSize videoSize = videoTrack.naturalSize;
	if(isPortrait_) {
		videoSize = CGSizeMake(videoSize.height, videoSize.width);
	}
	
	// サイズを設定
	composition.naturalSize     = videoSize; // AVPlayerはこのサイズを見ない
	videoComposition.renderSize = videoSize; // AVPlayerはこのサイズを見る。
	//RenderSize に常にnaturalSizeを指定すればAVPlayerは期待したvideoGravityで表示する。
	// しかし動画は一部表示になる欠ける (レンダリングの向きが縦横違うのだから)
	// おそらくAVPlayerがvideoGravityで求めるRectが向きを考慮できない(そりゃそうだろうLayerInstまで見ることはできない)
	// videoComposition.renderSize = videoTrack.naturalSize; // 
	videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
	
#ifdef TARGET_OS_EMBEDDED
	// WWDC2010 サンプルより。プレビュは解像度を落とすことで処理効率を上げる。大抵HD動画なので、サイズはもう見ない
	videoComposition.renderScale = 0.5;
#endif
	
	// Trackを構築
 	AVMutableCompositionTrack *compositionVideoTrack;
	compositionVideoTrack = [composition 
							 addMutableTrackWithMediaType:AVMediaTypeVideo 
							 preferredTrackID:kCMPersistentTrackID_Invalid];	
	[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) 
								   ofTrack:videoTrack 	 
									atTime:kCMTimeZero error:nil];
	
	// レイヤを設定
	AVMutableVideoCompositionLayerInstruction *layerInst;
	layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
	[layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero]; // ココで変形を設定。
	//	[layerInst setOpacityRampFromStartOpacity:0 toEndOpacity:1 timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(2, 1))];
	
	AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
	inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
	inst.layerInstructions = [NSArray arrayWithObject:layerInst];
	
	// LayerInstructionをここで設定
	videoComposition.instructions = [NSArray arrayWithObject:inst];
	
	playerItem_ = [[[AVPlayerItem alloc] initWithAsset:composition] autorelease];
	playerItem_.videoComposition = videoComposition;
	
	[player_ replaceCurrentItemWithPlayerItem:playerItem_];
	
	[self changeState:waitingForPlayerReady];
}
-(void)pause
{	
	[self changeState:pausing];
}


@end
