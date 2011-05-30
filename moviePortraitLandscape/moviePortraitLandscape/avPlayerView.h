//
//  playControlView.h
//  videoCutout
//
//  Created by AKIHIRO Uehara on 11/04/26.
//  Copyright 2011 REINFORCE Lab.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class videoComposer;

typedef enum {
	waitingForPlayItem = 0,
	waitingForPlayerReady =1,
	readyToPlay = 2,
	playing     = 3,
	pausing     = 4,	
	playToEnd   = 5,
}avPlayerStateType;

// 再生動作の制御View
// このViewは明示的なデリゲートがありません。再生動作ボタンの情報は、ApplicationDelegateのstateプロパティ変更とそのKVOで伝達します。
@interface avPlayerView : UIView<UIGestureRecognizerDelegate> {   	
	avPlayerStateType state_;
	id timeObserver_;
	
	AVPlayer *player_;
	AVPlayerItem *playerItem_;
	AVPlayerLayer *avPlayerLayer_;
	
	UITapGestureRecognizer *singleTapGestureRecognizer_;
	UITapGestureRecognizer *doubleTapGestureRecognizer_;
		
	UIButton *startPlayingButton_;
	UIButton *stopPlayingButton_;
	UIButton *backwardButton_;
	UIButton *forwardButton_;
	
	UIImageOrientation orientation_;
	bool isPortrait_;
	
	bool isFullScreen_;
	bool isButtonsShown_;
}

// 再生(もしくは一時停止)しているか?
@property (nonatomic, assign, readonly) bool isFullScreen;

// 0 - none, 1 - preferredTransofrm, 2 - layer insruction
-(void)play:(AVAsset *)asset gravity:(NSString *)gravity testMode:(int)testMode;
-(void)pause;

@end
