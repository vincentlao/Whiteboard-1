//
//  DrawData.h
//  Whiteboard
//
//  Created by Brian Sinnicke on 12/31/15.
//  Copyright © 2015 Brian Sinnicke. All rights reserved.
//

#import <Realm/Realm.h>

@interface DrawingData : RLMObject
@property (nonatomic, readwrite) NSInteger draw_id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSDate *createdAt;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<DrawData>
RLM_ARRAY_TYPE(DrawData)
