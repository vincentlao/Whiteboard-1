//
//  RealmManager.h
//  Whiteboard
//
//  Created by Brian Sinnicke on 12/31/15.
//  Copyright © 2015 Brian Sinnicke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawingData.h"
#import "PlaybackData.h"
#import "DrawLinesData.h"

@interface RealmManager : NSObject
+ (RealmManager *)sharedInstance;

- (void)savePlayback:(NSData *)imgData andFrame:(NSInteger)frame;
- (NSMutableArray *)getPlaybackArray;

- (void)saveDrawing:(NSData *)imgData withTitle:(NSString *)title andAuthor:(NSString *)author;
- (NSMutableArray *)getSavedDrawingArray;

- (void)saveDrawLine:(NSData *)imgData andFrame:(NSInteger)frame;
- (NSMutableArray *)getDrawLinesArray;
@end
