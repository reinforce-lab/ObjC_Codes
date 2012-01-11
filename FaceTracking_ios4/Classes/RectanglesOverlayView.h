//
//  RectanglesOverlayView.h
//  FaceDetect
//
//  Created by UEHARA AKIHIRO on 10/09/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RectanglesOverlayView : UIView {
	NSArray *rectangles_;
}

-(void)updateRectangles:(NSArray *)rectangles;
-(int) cnvXtoY:(CGFloat)xval;
-(int) cnvYtoX:(CGFloat)yval;
@end
