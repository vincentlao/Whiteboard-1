//
//  LineView.h
//  Whiteboard
//
//  Created by Brian Sinnicke on 7/24/15.
//  Copyright (c) 2015 Brian Sinnicke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LineViewDelegate <NSObject>

-(void)drawLineForContext:(CGContextRef)context;

@end

@interface LineView : UIView
@property (weak, nonatomic) id <LineViewDelegate> delegate;
@end
