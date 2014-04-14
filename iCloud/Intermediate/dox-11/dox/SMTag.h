//
//  SMTag.h
//  dox
//
//  Created by Cesare Rocchi on 10/14/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SMTag : NSManagedObject

@property (nonatomic, retain) NSString * tagContent;
@property (nonatomic, retain) NSSet *notes;
@end

@interface SMTag (CoreDataGeneratedAccessors)

- (void)addNotesObject:(NSManagedObject *)value;
- (void)removeNotesObject:(NSManagedObject *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
