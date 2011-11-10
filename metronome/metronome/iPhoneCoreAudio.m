/*
 *  iPhoneCoreAudio.c
 *
 *  Created by nagano on 09/07/20.
 *
 */

#include "iPhoneCoreAudio.h"

AudioStreamBasicDescription AUCanonicalASBD(Float64 sampleRate, 
                                            UInt32 channel){
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate         = sampleRate;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagsAudioUnitCanonical;
    audioFormat.mChannelsPerFrame   = channel;
    audioFormat.mBytesPerPacket     = sizeof(AudioUnitSampleType);
    audioFormat.mBytesPerFrame      = sizeof(AudioUnitSampleType);
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mBitsPerChannel     = 8 * sizeof(AudioUnitSampleType);
    audioFormat.mReserved           = 0;
    return audioFormat;
}


AudioStreamBasicDescription CanonicalASBD(Float64 sampleRate, 
                                          UInt32 channel){
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate         = sampleRate;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagsCanonical;
    audioFormat.mChannelsPerFrame   = channel;
    audioFormat.mBytesPerPacket     = sizeof(AudioSampleType) * audioFormat.mChannelsPerFrame;
    audioFormat.mBytesPerFrame      = sizeof(AudioSampleType) * audioFormat.mChannelsPerFrame;
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mBitsPerChannel     = 8 * sizeof(AudioSampleType);
    audioFormat.mReserved           = 0;
    return audioFormat;
}