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

@interface DrawingTableViewController ()
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
@end
