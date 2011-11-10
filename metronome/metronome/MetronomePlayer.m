//
//  MetronomePlayer.m
//  metronome
//
//  Created by 昭宏 上原 on 11/10/21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MetronomePlayer.h"
#import "iPhoneCoreAudio.h"
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#define SAMPLING_RATE 441000

// プライベートなメッセージ(このクラスのみが利用する、外部から呼び出すことがないメッセージ)
// は無名カテゴリに置く。このやりかたにより、ヘッダファイルにプライベートなメッセージが見えない。
@interface MetronomePlayer() 
{
    // CoreAudioを使うのに必要な変数
    AudioUnit audioUnit_;
    // Snd0/1の音(メモリベース)
    AudioUnitSampleType *snd0Buf_;
    AudioUnitSampleType *snd1Buf_;
    UInt32 snd0BufLength_;
    UInt32 snd1BufLength_;

    AudioUnitSampleType *tempoBuf_;
    UInt32 tempoBufLength_;

    int currentBufPosition_; // 出力バッファ位置

    // テンポ管理の変数
    int tempo_; // テンポ
    int maxTempo_; //最大テンポ数
}

//AudioUnitの初期化
- (void)prepareAudioUnit;
// リソースファイルをLPCMとしてメモリに読み込む。確保されたバッファは、ユーザが解放すること
-(AudioUnitSampleType *)loadAudio:(NSString *)resourcePath outTotalFrames:(UInt32 *)totalFrames;
// テンポ変更時の変数設定処理
-(void)updateTempo;
@end

@implementation MetronomePlayer
#pragma mark - Variables

#pragma mark - Properties
@synthesize delegate;
@synthesize isRunning;
@dynamic tempo;
-(int)getTempo
{
    return tempo_;
}
// テンポの値変更で、テンポ再生の変数変更処理をおこなう
-(void)setTempo:(int)tempo
{
    // 音ファイルの再生時間から決まる最大テンポ数以下に押さえる。
    tempo_ = MIN(maxTempo_, tempo);
    // 0やマイナスなどのありえない値を除去する。
    tempo_ = MAX(1, tempo_);
    // テンポの動作に必要な変数の設定変更処理
    [self updateTempo];
}

#pragma mark - static functions
static void checkError(OSStatus err,const char *message)
{
    if(err){
        char property[5];
        *(UInt32 *)property = CFSwapInt32HostToBig(err);
        property[4] = '\0';
        NSLog(@"%s = %-4.4s, %ld",message, property,err);
        exit(1);
    }
}

static OSStatus renderCallback(
                               void*                       inRefCon,
                               AudioUnitRenderActionFlags* ioActionFlags,
                               const AudioTimeStamp*       inTimeStamp,
                               UInt32                      inBusNumber,
                               UInt32                      inNumberFrames,
                               AudioBufferList*            ioData
                               )
{
    MetronomePlayer* def = (__bridge MetronomePlayer *)inRefCon;
    if(!def->isRunning) return noErr;
    
    AudioUnitSampleType *outL = ioData->mBuffers[0].mData;
    AudioUnitSampleType *outR = ioData->mBuffers[1].mData;
        
    @synchronized(def) {
        UInt32 dstPos = 0;
        AudioUnitSampleType *src = def->tempoBuf_;
        UInt32 srcPos  = def->currentBufPosition_;
        UInt32 srcLen = def->tempoBufLength_;
        
        while(dstPos < inNumberFrames) {
            int wrtLen = MIN(inNumberFrames -dstPos, srcLen - srcPos);

            memcpy(&outL[dstPos], &src[srcPos], sizeof(AudioUnitSampleType) * wrtLen);
            memcpy(&outR[dstPos], &src[srcPos], sizeof(AudioUnitSampleType) * wrtLen);

            // UI側への同期コールバック
            // バッファ書き込み経過時間を考慮して遅延時間をかけてメインスレッドにコールバックする。
            // 1024程度のバッファ長なので、これを考慮しなくても+-11.5msecのずれなので、気にならないかもしれないが。
            // オーディオバッファに書きこんでから実際に音として出力されるまで、ロールカットフィルタなどの遅延があるはず。
            // ここではそれらまでは考慮してない。
//            NSLog(@"srcPos %d (srcPos + wrtLen) %d srcLen %d", srcPos, srcPos + wrtLen, srcLen);
            if((srcPos + wrtLen) >= srcLen) {
                double delayInSeconds = (dstPos + (srcLen - srcPos)) / SAMPLING_RATE;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [def.delegate keepTime];
                });
            }
            
            srcPos = (srcPos + wrtLen) % srcLen;
            dstPos += wrtLen;                        
        }        
        def->currentBufPosition_ = srcPos;                
    }   
    
    return noErr;
}

#pragma mark - Constructor
-(id)initWithSounds:(NSString *)snd0 snd1:(NSString *)snd1
{
    self = [super init];
    if(self) {
        tempoBuf_ = malloc(sizeof(AudioUnitSampleType) * 60 * SAMPLING_RATE);
        
        snd0Buf_ = [self loadAudio:snd0 outTotalFrames:&snd0BufLength_];
        snd1Buf_ = [self loadAudio:snd1 outTotalFrames:&snd1BufLength_];
        
        
        int len    = MAX(snd0BufLength_, snd1BufLength_);
        maxTempo_  = 60 * SAMPLING_RATE / (len *4) -1;
        self.tempo = 120;

        [self prepareAudioUnit];
    }
    return self;
}
-(void)dealloc
{
    [self stop];
    
    free(tempoBuf_);    
    free(snd0Buf_);
    free(snd1Buf_);
}
#pragma mark - Public method
-(void)start
{
    if(!self.isRunning){
        self.isRunning = YES;
        AudioOutputUnitStart(audioUnit_);
    }
}

-(void)stop
{
    if(self.isRunning){
        AudioOutputUnitStop(audioUnit_);
        self.isRunning = NO;
    }
}
#pragma mark - Private method
-(AudioUnitSampleType *)loadAudio:(NSString *)resourcePath outTotalFrames:(UInt32 *)totalFrames
{
    OSStatus err;
    ExtAudioFileRef extAudioFile;
    NSString *path = [[NSBundle mainBundle] pathForResource:resourcePath ofType:@"aif"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    //ExAudioFileの作成
    err = ExtAudioFileOpenURL((__bridge CFURLRef)fileURL, &extAudioFile);
    checkError(err,"ExtAudioFileOpenURL");
    
	//ファイルデータフォーマットを取得[1]
    AudioStreamBasicDescription inputFormat;
    UInt32 size = sizeof(AudioStreamBasicDescription);
    err = ExtAudioFileGetProperty(extAudioFile, 
                                  kExtAudioFileProperty_FileDataFormat, 
                                  &size,
                                  &inputFormat);
    checkError(err,"kExtAudioFileProperty_FileDataFormat");
    
    // モノラルとして読み込み
    AudioStreamBasicDescription clientFormat = AUCanonicalASBD(SAMPLING_RATE, 1);
    //読み込むフォーマットをAudio Unit正準形に設定[3]
    err = ExtAudioFileSetProperty(extAudioFile,
                                  kExtAudioFileProperty_ClientDataFormat, 
                                  sizeof(AudioStreamBasicDescription), 
                                  &clientFormat);
    checkError(err,"kExtAudioFileProperty_ClientDataFormat");
    
    //トータルフレーム数を取得しておく
    SInt64 fileLengthFrames;
    size = sizeof(SInt64);
    err = ExtAudioFileGetProperty(extAudioFile, 
                                  kExtAudioFileProperty_FileLengthFrames, 
                                  &size, 
                                  &fileLengthFrames);
    checkError(err,"kExtAudioFileProperty_FileLengthFrames");
    *totalFrames = fileLengthFrames;
    
    //AudioBufferListの作成
    AudioUnitSampleType* playBuffer = malloc(sizeof(AudioUnitSampleType) * fileLengthFrames);

    AudioBufferList *audioBufferList = malloc(sizeof(AudioBufferList));
    audioBufferList->mNumberBuffers = 1;
    audioBufferList->mBuffers[0].mNumberChannels = 1;
    audioBufferList->mBuffers[0].mDataByteSize = sizeof(AudioUnitSampleType) * fileLengthFrames;
    audioBufferList->mBuffers[0].mData = playBuffer;

    
    //位置を0に移動
    ExtAudioFileSeek(extAudioFile, 0);
    
	//全てのフレームをバッファに読み込む
    UInt32 readFrameSize = fileLengthFrames;
    err = ExtAudioFileRead(extAudioFile, &readFrameSize, audioBufferList);
    checkError(err,"ExtAudioFileRead");
    
    free(audioBufferList);

    return  playBuffer;
}
- (void)prepareAudioUnit
{
    AudioComponentDescription cd;
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_RemoteIO;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    
    AudioComponent component = AudioComponentFindNext(NULL, &cd);    
    AudioComponentInstanceNew(component, &audioUnit_);
    
    AudioUnitInitialize(audioUnit_);
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback;
    callbackStruct.inputProcRefCon = (__bridge void*)self;
    
    AudioUnitSetProperty(audioUnit_, 
                         kAudioUnitProperty_SetRenderCallback, 
                         kAudioUnitScope_Input,
                         0,
                         &callbackStruct,
                         sizeof(AURenderCallbackStruct));
    
    //ステレオで出力する
    AudioStreamBasicDescription audioFormat = AUCanonicalASBD(SAMPLING_RATE, 2);    
    AudioUnitSetProperty(audioUnit_,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &audioFormat,
                         sizeof(audioFormat));
}
-(void)updateTempo
{
    // 音再生処理は、UIメインスレッドとは別スレッドで動作している
    // このため値変更は排他処理にする。
    @synchronized(self) {
        currentBufPosition_ = 0;
        tempoBufLength_ = 60 * SAMPLING_RATE / tempo_;

        memset(tempoBuf_, 0, sizeof(AudioUnitSampleType) * tempoBufLength_);

        memcpy(tempoBuf_, snd0Buf_, sizeof(AudioUnitSampleType) * snd0BufLength_);
        int samplePerTempo = tempoBufLength_ / 4;
        for(int i=1; i < 4; i++) {
            AudioUnitSampleType *src = snd1Buf_;
            AudioUnitSampleType *dst = &tempoBuf_[i * samplePerTempo];
            memcpy(dst, src, sizeof(AudioUnitSampleType) * snd1BufLength_);
        }
    }
}
@end
