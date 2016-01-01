//
//  RealmManager.m
//  Whiteboard
//
//  Created by Brian Sinnicke on 12/31/15.
//  Copyright © 2015 Brian Sinnicke. All rights reserved.
//

#import "RealmManager.h"

@implementation RealmManager
+ (RealmManager *)sharedInstance
{
    static RealmManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RealmManager alloc] init];
    });
    return sharedInstance;
}
-(void)savePlayback:(NSData *)imgData andFrame:(NSInteger)frame
{
    PlaybackData *playback = [PlaybackData new];
    playback.playback_id = frame;
    playback.imageData = imgData;
    playback.frame = frame;
    playback.createdAt = [NSDate date];
    [self saveRealmObject:playback];
}
-(NSMutableArray *)getPlaybackArray
{
    RLMResults *results = [PlaybackData allObjects];
    NSMutableArray *array = [NSMutableArray new];
    if (results.count > 0)
    {
        for (PlaybackData *playback in results)
        {
            [array addObject:playback];
        }
    }
    return array;
}
-(void)saveDrawing:(NSData *)imgData withTitle:(NSString *)title andAuthor:(NSString *)author
{
    DrawingData *draw = [DrawingData new];
    NSInteger identifier = 1;
    RLMResults *results = [DrawingData allObjects];
    if (results.count > 0)
    {
        DrawingData *last = (DrawingData *)results.lastObject;
        identifier = (last.draw_id + 1);
    }
    draw.draw_id = identifier;
    draw.imageData = imgData;
    draw.title = title;
    draw.author = author;
    draw.createdAt = [NSDate date];
    [self saveRealmObject:draw];
}
-(NSMutableArray * )getSavedDrawingArray
{
    RLMResults *results = [DrawingData allObjects];
    NSMutableArray *array = [NSMutableArray new];
    if (results.count > 0)
    {
        for (DrawingData *draw in results)
        {
            [array addObject:draw];
        }
    }
    return array;
}
-(void)saveDrawLine:(NSData *)imgData andFrame:(NSInteger)frame
{
    DrawLinesData *drawLine= [DrawLinesData new];
    drawLine.drawLine_id = frame;
    drawLine.imageData = imgData;
    drawLine.frame = frame;
    drawLine.createdAt = [NSDate date];
    [self saveRealmObject:drawLine];
}
-(NSMutableArray *)getDrawLinesArray
{
    RLMResults *results = [DrawLinesData allObjects];
    NSMutableArray *array = [NSMutableArray new];
    if (results.count > 0)
    {
        for (DrawLinesData *drawLine in results)
        {
            [array addObject:drawLine];
        }
    }
    return array;
}
#pragma mark - Private
-(void)saveRealmObject:(RLMObject *)object
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:object];
    [realm commitWriteTransaction];
}
@end
