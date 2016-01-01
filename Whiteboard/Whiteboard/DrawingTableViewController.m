//
//  DrawingTableViewController.m
//  Whiteboard
//
//  Created by Brian Sinnicke on 12/31/15.
//  Copyright © 2015 Brian Sinnicke. All rights reserved.
//

#import "DrawingTableViewController.h"
#import "DrawingData.h"
#import "RealmManager.h"

@import MessageUI;
@import MobileCoreServices;

@interface DrawingTableViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic) NSMutableArray *dataArray;
@end

@implementation DrawingTableViewController

#pragma mark - Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataArray = [NSMutableArray new];
    self.title = @"Drawings";
    [self refreshTableData:[[RealmManager sharedInstance] getSavedDrawingArray]];
    self.navigationController.toolbarHidden = YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.hidesBarsOnTap = NO;
}
-(void)refreshTableData:(NSMutableArray *)data
{
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:data];
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    DrawingData *data = (DrawingData *)[self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = data.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",data.author,data.createdAt];
    cell.imageView.image = [UIImage imageWithData:data.imageData];
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [NSMutableArray new];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        DrawingData *data = (DrawingData *)[self.dataArray objectAtIndex:indexPath.row];
        [[RealmManager sharedInstance] deleteSavedDrawing:data];
        [self.dataArray removeObject:data];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    [array addObject:deleteAction];
    return array;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawingData *data = (DrawingData *)[self.dataArray objectAtIndex:indexPath.row];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:data.title message:data.author preferredStyle:UIAlertControllerStyleActionSheet];
    // TODO
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        
//    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *compose = [MFMailComposeViewController new];
            [compose setMailComposeDelegate:self];
            [compose addAttachmentData:data.imageData mimeType:@"image/png" fileName:@"drawing.png"];
            [compose setSubject:[NSString stringWithFormat:@"Check out %@ by %@ from Brian's Whiteboard app.", data.title, data.author]];
            
            if (compose) [self presentViewController:compose animated:YES completion:^(void) {}];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Unable to compose an email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
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
@end
