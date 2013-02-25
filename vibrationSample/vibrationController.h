//
//  vibrationController.h
//  vibrationSample
//
//  Created by Akihiro Uehara on 12/01/25.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

// 振動パターン制御クラス
// 振動モータを内蔵していない場合は、何もおきません。(アラート音など代替動作は行いません)
@interface vibrationController : NSObject
-(void)vibrate:(float)period;
-(void)stop;
@end
