//
//  LogManager.h
//  visitMonitoringTest
//
//  Created by Akihiro Uehara on 2014/10/03.
//  Copyright (c) 2014年 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogManager : NSObject

@property (readonly, getter=getSharedInstance) LogManager *sharedInstance;

@end
