//
//  ViewController.m
//  Whiteboard
//
//  Created by Brian Sinnicke on 7/24/15.
//  Copyright (c) 2015 Brian Sinnicke. All rights reserved.
//

#import "WhiteboardViewController.h"

#define THICKNESS 10.0f
#define STOP_TITLE @"Stop"
#define PLAY_TITLE @"Playback"

@import MessageUI;
@import MobileCoreServices;

@interface WhiteboardViewController () <MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *primaryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondaryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UISlider *widthSlider;
@property (nonatomic, assign) BOOL didMoved;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, readwrite) CGPoint lastPoint;
@property (nonatomic, readwrite) CGFloat thickness;
@property (nonatomic, readwrite) CGColorRef colorRef;
@property (nonatomic, readwrite) NSInteger playbackFrame;
@property (nonatomic, readwrite) NSInteger drawLineFrame;
@end

@implementation WhiteboardViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.thickness = THICKNESS;
    [self.widthSlider setValue:THICKNESS animated:YES];
    self.colorRef = [UIColor blackColor].CGColor;
    self.playbackFrame = 1;
    self.drawLineFrame = 1;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
#pragma mark - IBActions
- (IBAction)sliderValueChanged:(UISlider *)sender
{
    self.thickness = sender.value;
}
- (IBAction)trashAction:(id)sender
{
    if (self.primaryImageView.image != nil && self.isPlaying == NO)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Discard Drawing?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            self.primaryImageView.image = nil;
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (IBAction)undoAction:(id)sender
{
    // TODO
}
- (IBAction)redoAction:(id)sender
{
    // TODO
}
- (IBAction)emailAction:(id)sender
{
    if (self.primaryImageView.image != nil && self.isPlaying == NO)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *compose = [MFMailComposeViewController new];
            [compose setMailComposeDelegate:self];
            
            UIImage *image = self.primaryImageView.image;
            NSData *imgData = UIImagePNGRepresentation(image);
            [compose addAttachmentData:imgData mimeType:@"image/png" fileName:@"drawing.png"];
            
            [compose setSubject:@"Check out my drawing from Brian's Whiteboard app."];
            
            if (compose) [self presentViewController:compose animated:YES completion:^(void) {}];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Unable to compose an email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}
- (IBAction)cameraAction:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Upload a photo" message:@"Choose from .." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       
        [alertController dismissViewControllerAnimated:YES completion:nil];
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"On Simulator - Camera is unavailable.");
#else
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
#endif
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = @[(NSString *)kUTTypeImage];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)eraseAction:(id)sender
{
    self.colorRef = self.view.backgroundColor.CGColor;
}
- (IBAction)blackAction:(id)sender
{
    self.colorRef = [UIColor blackColor].CGColor;
}
- (IBAction)darkGrayAction:(id)sender
{
    self.colorRef = [UIColor darkGrayColor].CGColor;
}
- (IBAction)lightGrayAction:(id)sender
{
    self.colorRef = [UIColor lightGrayColor].CGColor;
}
- (IBAction)blueAction:(id)sender
{
    self.colorRef = [UIColor blueColor].CGColor;
}
- (IBAction)redAction:(id)sender
{
    self.colorRef = [UIColor redColor].CGColor;
}
- (IBAction)greenAction:(id)sender
{
    self.colorRef = [UIColor greenColor].CGColor;
}
- (IBAction)orangeAction:(id)sender
{
    self.colorRef = [UIColor orangeColor].CGColor;
}
- (IBAction)yellowAction:(id)sender
{
    self.colorRef = [UIColor yellowColor].CGColor;
}
- (IBAction)purpleAction:(id)sender
{
    self.colorRef = [UIColor purpleColor].CGColor;
}
#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *pickedImage = (UIImage*)[info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImage *drawingImage = self.primaryImageView.image;
        UIGraphicsBeginImageContext(self.view.frame.size);
        [pickedImage drawInRect:self.view.frame];
        [drawingImage drawInRect:self.view.frame];
        UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
        self.primaryImageView.image = mergedImage;
//        [self.drawingArray addObject:mergedImage];
        UIGraphicsEndPDFContext();
    }];
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
            self.primaryImageView.image = nil;
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
    if (self.isPlaying == NO)
    {
        [self drawToPoint:point fromPoint:self.lastPoint WithThickness:self.thickness andColorRef:self.colorRef];
    }
    self.lastPoint = point;
    self.didMoved = YES;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:touch.view];
    if (self.didMoved == NO && self.isPlaying == NO)
    {
        [self drawToPoint:point fromPoint:self.lastPoint WithThickness:self.thickness andColorRef:self.colorRef];
    }
    [self saveImageContextToPrimary];
}
#pragma mark - Drawing
-(void)drawToPoint:(CGPoint)toPoint fromPoint:(CGPoint)fromPoint WithThickness:(CGFloat)thickness andColorRef:(CGColorRef)colorRef
{
    @autoreleasepool {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.secondaryImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), fromPoint.x, fromPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), toPoint.x, toPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), thickness);
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), colorRef);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.secondaryImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imgData = UIImagePNGRepresentation(self.secondaryImageView.image);
//        [[RealmManager sharedInstance] savePlayback:imgData andFrame:self.playbackFrame];
        self.playbackFrame++;
    }
}
-(void)saveImageContextToPrimary
{
    @autoreleasepool {
        UIGraphicsBeginImageContext(self.primaryImageView.frame.size);
        [self.primaryImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
        [self.secondaryImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0f];
        self.primaryImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        NSData *imgData = UIImagePNGRepresentation(self.primaryImageView.image);
//        [[RealmManager sharedInstance] saveDrawLine:imgData andFrame:self.drawLineFrame];
        self.drawLineFrame++;
        self.secondaryImageView.image = nil;
        UIGraphicsEndImageContext();
    }
}
@end
