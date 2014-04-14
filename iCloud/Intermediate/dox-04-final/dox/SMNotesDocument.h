//
//  SMNotesDocument.h
//  dox
//
//  Created by Cesare Rocchi on 10/11/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMNote.h"

@interface SMNotesDocument : UIDocument {
    
    NSMutableArray *_entries;
    NSFileWrapper *_fileWrapper;
    
}

@property (nonatomic, strong) NSMutableArray *entries;
@property (nonatomic, strong) NSFileWrapper *fileWrapper;

- (NSInteger ) count;
- (void) addNote:(SMNote *) note;
- (SMNote *)entryAtIndex:(NSUInteger)index;

@end
