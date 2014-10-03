//
//  LogManager.m
//  visitMonitoringTest
//
//  Created by Akihiro Uehara on 2014/10/03.
//  Copyright (c) 2014年 Akihiro Uehara. All rights reserved.
//

#import "LogManager.h"

@interface LogManager() {
    NSFileHandle *_logFile;
}
@end

#define kLogFileName @"log.txt"

@implementation LogManager
#pragma mark Properties
-(LogManager *)getSharedInstance {
    static dispatch_once_t once;
    static LogManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[LogManager alloc] init];
    });
    return sharedInstance;
}
#pragma mark Constructor
-(id)init {
    self = [super init];
    if(self) {
        // NSLogの出力先をファイルに変更
        NSString *path = [self getLogFilePath];
        freopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
        
        _logFile = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    return self;
}
-(void)dealloc {
    [_logFile closeFile];
    _logFile = nil;
}

#pragma mark Methods
-(NSString *)getLogFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kLogFileName];

    return path;
}

-(void)clear {    
}

-(void)write:(NSString *)msg {
    NSString *log = [NSString stringWithFormat:@"%@\n", msg]; // appending a new line
    [_logFile writeData:[NSData dataWithBytes:log.UTF8String length:[log lengthOfBytesUsingEncoding:NSUTF8StringEncoding]]];
}
@end
