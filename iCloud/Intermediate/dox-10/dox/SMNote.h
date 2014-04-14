//
//  SMNote.h
//  dox
//
//  Created by Cesare Rocchi on 10/14/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SMTag;

@interface SMNote : NSManagedObject

@property (nonatomic, retain) NSString * noteContent;
@property (nonatomic, retain) NSString * noteTitle;
@property (nonatomic, retain) NSSet *tags;
@end

@interface SMNote (CoreDataGeneratedAccessors)

- (void)addTagsObject:(SMTag *)value;
- (void)removeTagsObject:(SMTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
