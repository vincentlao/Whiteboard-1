//
//  ViewController.m
//  Whiteboard
//
//  Created by Brian Sinnicke on 7/24/15.
//  Copyright (c) 2015 Brian Sinnicke. All rights reserved.
//

#import "WhiteboardViewController.h"

#define LINE_WIDTH 10.0f

@import MessageUI;

@interface WhiteboardViewController () <MFMailComposeViewControllerDelegate>
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
#pragma mark - IBActions
- (IBAction)trashAction:(id)sender
{
    self.primaryImageView.image = nil;
}
- (IBAction)undoAction:(id)sender
{
    
}
- (IBAction)redoAction:(id)sender
{
    
}
- (IBAction)emailAction:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [MFMailComposeViewController new];
        [controller setMailComposeDelegate:self];
        if (self.primaryImageView.image != nil)
        {
            UIImage *image = self.primaryImageView.image;
            NSData *imgData = UIImagePNGRepresentation(image);
            [controller addAttachmentData:imgData mimeType:@"image/png" fileName:@"drawing.png"];
        }
        NSString *subject = [NSString stringWithFormat:@"Look at my drawing I created at %@", [NSDate date]];
        [controller setSubject:subject];
        if (controller && self.primaryImageView.image != nil) [self presentViewController:controller animated:YES completion:^(void) {}];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Unable to compose an email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}
#pragma mark - MFMailComposeViewDelegate
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
            // user cancelled
            break;
        }
        case MFMailComposeResultSaved:
        {
            // user saved
            break;
        }
        case MFMailComposeResultSent:
        {
            // user sent
            break;
        }
        case MFMailComposeResultFailed:
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            break;
        }
        default:
        {
            break;
        }
    }
    [self dismissViewControllerAnimated:YES completion:^(void) {}];
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
