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
@property (strong, nonatomic) NSMutableArray *drawingArray;
@property (strong, nonatomic) NSMutableArray *undoArray;
@end

@implementation WhiteboardViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.lineWidth = LINE_WIDTH;
    self.colorRef = [UIColor blackColor].CGColor;
    self.drawingArray = [NSMutableArray new];
    self.undoArray = [NSMutableArray new];
}
#pragma mark - IBActions
- (IBAction)trashAction:(id)sender
{
    if (self.primaryImageView.image != nil)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Clear Drawing" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.primaryImageView.image = nil;
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (IBAction)undoAction:(id)sender
{
    if ([self.drawingArray lastObject] != nil)
    {
        [self.undoArray addObject:[self.drawingArray lastObject]];
        [self.drawingArray removeLastObject];
    }
    if ([self.drawingArray count] > 0)
    {
        self.primaryImageView.image = [self.drawingArray lastObject];
    }
    else
    {
        self.primaryImageView.image = nil;
    }
}
- (IBAction)redoAction:(id)sender
{
    if ([self.undoArray lastObject] != nil)
    {
        [self.drawingArray addObject:[self.undoArray lastObject]];
        [self.undoArray removeLastObject];
    }
    if ([self.drawingArray count] > 0)
    {
        self.primaryImageView.image = [self.drawingArray lastObject];
    }
    else
    {
        self.primaryImageView.image = nil;
    }
}
- (IBAction)emailAction:(id)sender
{
    if (self.primaryImageView.image != nil)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *compose = [MFMailComposeViewController new];
            [compose setMailComposeDelegate:self];
            
            UIImage *image = self.primaryImageView.image;
            NSData *imgData = UIImagePNGRepresentation(image);
            [compose addAttachmentData:imgData mimeType:@"image/png" fileName:@"drawing.png"];
            
            [compose setSubject:@"Hi, take a look at my drawing from Whiteboard app."];
            
            if (compose) [self presentViewController:compose animated:YES completion:^(void) {}];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Unable to compose an email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
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
#pragma mark - Drawing
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
    [self.drawingArray addObject:self.primaryImageView.image];
    self.secondaryImageView.image = nil;
    UIGraphicsEndImageContext();
}
@end
