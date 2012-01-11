//
//  RectanglesOverlayView.m
//  FaceDetect
//
//  Created by UEHARA AKIHIRO on 10/09/23.
//  Copyright 2010 Reinforce Lab. All rights reserved.
//

#import "RectanglesOverlayView.h"

@implementation RectanglesOverlayView
-(id)initWithFrame:(CGRect)frame {
	if(self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = FALSE;
	}
	return self;
}
-(int)cnvXtoY:(CGFloat)xval{
	return self.bounds.size.height * xval;
}
-(int)cnvYtoX:(CGFloat)yval{
	return self.bounds.size.width * (yval);
}
-(void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect bounds = self.bounds;
	// clear rectangles	
	CGContextSetRGBFillColor(context, 255.0, 255.0, 255.0, 0);	
	CGContextFillRect(context, bounds);			
	// draw rectangles
	CGContextSetLineWidth(context, 4);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 0.5);	
	for (NSValue *val in rectangles_) {
		CGRect rect = [val CGRectValue];
		CGRect drawRect = CGRectMake([self cnvYtoX:rect.origin.y], [self cnvXtoY:rect.origin.x], 
									 rect.size.height * bounds.size.width, rect.size.width * bounds.size.height);									 
//		NSLog(@"det rect: %1.2f %1.2f %1.2f %1.2f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
//		NSLog(@"drawRect: %1.2f %1.2f %1.2f %1.2f", drawRect.origin.x, drawRect.origin.y, drawRect.size.width, drawRect.size.height);
		CGContextStrokeRect(context, drawRect);
	}
}
-(void)updateRectangles:(NSArray *)rectangles {
	[rectangles_ release];
	rectangles_ = [rectangles retain];
	[self setNeedsDisplay];
}
@end
