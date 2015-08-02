//
//  ViewController.m
//  Whiteboard
//
//  Created by Brian Sinnicke on 7/24/15.
//  Copyright (c) 2015 Brian Sinnicke. All rights reserved.
//

#import "WhiteboardViewController.h"

#define LINE_WIDTH 10.0f

@interface WhiteboardViewController ()
@property (nonatomic) CGPoint lastPoint;
@property (weak, nonatomic) IBOutlet UIImageView *primaryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondaryImageView;
@property (nonatomic, assign) BOOL didMoved;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGColorRef colorRef;
@end

@implementation WhiteboardViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.lineWidth = LINE_WIDTH;
}
#pragma mark - Touch events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:touch.view];
    
    self.lastPoint = point;
    self.colorRef = [UIColor blackColor].CGColor;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:touch.view];
    
    [self drawToPoint:point fromPoint:self.lastPoint WithLineWidth:self.lineWidth andColorRef:self.colorRef];
    
    self.lastPoint = point;
    self.didMoved = YES;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:touch.view];
    
    if (self.didMoved == NO)
    {
        [self drawToPoint:point fromPoint:self.lastPoint WithLineWidth:self.lineWidth andColorRef:self.colorRef];
    }
    [self saveImageContextToPrimary];
}
-(void)drawToPoint:(CGPoint)toPoint fromPoint:(CGPoint)fromPoint WithLineWidth:(CGFloat)width andColorRef:(CGColorRef)colorRef
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.secondaryImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), toPoint.x, toPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), width);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), colorRef);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.secondaryImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
-(void)saveImageContextToPrimary
{
    UIGraphicsBeginImageContext(self.primaryImageView.frame.size);
    [self.primaryImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.secondaryImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
    self.primaryImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.secondaryImageView.image = nil;
    UIGraphicsEndImageContext();
}
@end
