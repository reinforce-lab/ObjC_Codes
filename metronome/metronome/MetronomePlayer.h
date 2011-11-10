//
//  MetronomePlayer.h
//  metronome
//
//  Created by 昭宏 上原 on 11/10/21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MetronomePlayerDelegate
-(void)keepTime;
@end

// メトロノームの音再生。4/4拍子のみ対応。
// 効果音ファイルは、モノラル、を想定。
@interface MetronomePlayer : NSObject

@property (nonatomic, assign, setter = setTempo:, getter = getTempo) int tempo;
@property (atomic, assign) bool isRunning;
@property (nonatomic, retain) id<MetronomePlayerDelegate> delegate;

// リソースファイル名を指定した初期化処理。リソースファイル名(拡張子なし)を指定。拡張子は"aif"を想定。
// 4/4拍子のうち、snd0を1回、snd1を3回繰り返し再生する
-(id)initWithSounds:(NSString *)snd0 snd1:(NSString *)snd1;

// 動作開始
-(void)start;

// 動作停止
-(void)stop;
@end
