//
//  VoiceController.m
//  FaceDetect
//
//  Created by UEHARA AKIHIRO on 10/09/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VoiceController.h"
#include <stdlib.h>

@implementation VoiceController
-(id)init {
	self = [super self];
	if(self) {
		audioFiles_ = [[NSArray arrayWithObjects:
					   @"c_001",
					   @"c_002",
					   @"c_003",
					   @"c_004",
					   @"c_005",
					   @"c_006",
					   @"c_007",
					   @"c_008",
					   @"c_009",
					   @"c_011",
					   @"c_012",
					   @"c_013",
					   @"c_014",
					   @"c_015",
					   @"c_016",
					   @"d_001",
					   @"d_002",
					   @"e_001",
					   @"e_002",
					   @"e_003",
					   @"e_004",
					   @"e_005",
					   @"e_006",
					   @"e_007",
					   @"e_008",
					   @"e_009",
					   @"e_010",
					   @"e_011",
					   @"e_012",
					   @"g_001",
					   @"g_002",
					   @"g_003",
					   @"g_004",
					   @"g_005",
					   @"g_006", 
					   nil] retain];	
	}
	return self;
}
-(void) dealloc {
	[super dealloc];
}

-(void) setFaceRectangles:(NSArray *)rectangles {
	if([rectangles count] <= 0) {
		return;
	}	
	if([player_ isPlaying]) {
		return;
	}
	int index = rand() % (int)[audioFiles_ count];				
	NSString *fileName = [audioFiles_ objectAtIndex:index];	
	CGRect rect = [[rectangles objectAtIndex:0] CGRectValue];
	if( rect.size.width * rect.size.height > 0.4 * 0.4) {
		fileName = @"c_011"; // yukkurisitettene
	} 
		
	// start playing new audio file
	NSError *error = nil;
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
	if(path == nil) 
		return;

	if(([NSDate timeIntervalSinceReferenceDate] - lastPlayedAt_) < 30) {
		return;
	}
	lastPlayedAt_ = [NSDate timeIntervalSinceReferenceDate];
	
	NSURL *fileURL = [NSURL fileURLWithPath:path];
	[player_ release];
	player_ =[[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
	if(error) {
		NSLog(@"Audio player error: %@", error);
		return;
	}
	[player_ play];
}
@end
