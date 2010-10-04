//
//  LocationSegment.h
//  BackgroundLocationRecorder
//
//  Created by UEHARA AKIHIRO on 10/07/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationSegment : NSObject {
@private
	NSString *name_;
	NSMutableArray *locations_;
}

@property (nonatomic, readonly)  name;
@property (nonatomic, readonly) locations;

-(void) initWithName:(NSString *)name;

@end
