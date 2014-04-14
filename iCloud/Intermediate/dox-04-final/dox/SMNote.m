//
//  SMNote.m
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMNote.h"

@implementation SMNote


- (id) init {
    
    if (self = [super init]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
        _noteId = [NSString stringWithFormat:@"Note_%@",
                   [formatter stringFromDate:[NSDate date]]];
    }
    
    return self;
}

#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super init])) {
        _noteId = [aDecoder decodeObjectForKey:@"noteId"];
        _noteContent = [aDecoder decodeObjectForKey:@"noteContent"];
        _createdAt = [aDecoder decodeObjectForKey:@"createdAt"];
        _updatedAt = [aDecoder decodeObjectForKey:@"updatedAt"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.noteId forKey:@"noteId"];
    [aCoder encodeObject:self.noteContent forKey:@"noteContent"];
    [aCoder encodeObject:self.createdAt forKey:@"createdAt"];
    [aCoder encodeObject:self.updatedAt forKey:@"updatedAt"];
    
}

@end
