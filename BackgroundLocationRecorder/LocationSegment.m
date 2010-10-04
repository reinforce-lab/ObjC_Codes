//
//  LocationSegment.m
//  BackgroundLocationRecorder
//
//  Created by UEHARA AKIHIRO on 10/07/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationSegment.h"

@implementation LocationSegment

#pragma mark properties
-(NSString *)name {
	return name_;
}
-(NSMutableArray *)locations {
	return locations_;
}

#pragma mark constructor
-(void) init
{
	return [self initWithName:@"null"];
}
-(void)initWithName:(NSString *)name
{
	self = [super init];
	if(self) {
		name_ = [name copy];
		locations_ = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) dealloc
{
	[locations_ release];
	[name_ release];
}
@end
