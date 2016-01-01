//
//  DrawLinesData.h
//  Whiteboard
//
//  Created by Brian Sinnicke on 12/31/15.
//  Copyright © 2015 Brian Sinnicke. All rights reserved.
//

#import <Realm/Realm.h>

@interface DrawLinesData : RLMObject
@property (nonatomic, readwrite) NSInteger drawLine_id;
@property (nonatomic, readwrite) NSInteger frame;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSDate *createdAt;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<DrawLinesData>
RLM_ARRAY_TYPE(DrawLinesData)
