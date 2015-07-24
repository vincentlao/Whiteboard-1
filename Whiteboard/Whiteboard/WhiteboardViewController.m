//
//  ViewController.m
//  Whiteboard
//
//  Created by Brian Sinnicke on 7/24/15.
//  Copyright (c) 2015 Brian Sinnicke. All rights reserved.
//

#import "WhiteboardViewController.h"
#import "LineView.h"

@interface WhiteboardViewController () <LineViewDelegate>
@property (nonatomic) CGPoint startlocation;
@property (nonatomic) CGPoint endlocation;
@end

@implementation WhiteboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    NSLog(@"%@", NSStringFromCGPoint(location));
    
    self.startlocation = location;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    NSLog(@"%@", NSStringFromCGPoint(location));
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    NSLog(@"%@", NSStringFromCGPoint(location));
    self.endlocation = location;
    [self addLineView];
}
#pragma mark - Add Line View
-(void)addLineView
{
    LineView *line = [[LineView alloc] initWithFrame:self.view.frame];
    line.backgroundColor = [UIColor clearColor];
    line.delegate = self;
    [self.view addSubview:line];
}
#pragma mark - LineView Delegate
-(void)drawLineForContext:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(context, 3.0);
    CGContextMoveToPoint(context, self.startlocation.x, self.startlocation.y);
    CGContextAddLineToPoint(context, self.endlocation.x, self.endlocation.y);
    CGContextDrawPath(context, kCGPathStroke);
}
@end
