//
//  SMNotesDocument.m
//  dox
//
//  Created by Cesare Rocchi on 10/11/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMNotesDocument.h"

@implementation SMNotesDocument

- (id)initWithFileURL:(NSURL *)url {
    if ((self = [super initWithFileURL:url])) {
        
        _entries = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noteChanged)
                                                     name:@"com.studiomagnolia.noteChanged"
                                                   object:nil];
        
    }
    
    return self;
}

//
- (void) noteChanged {
    [self saveToURL:[self fileURL]
   forSaveOperation:UIDocumentSaveForOverwriting
  completionHandler:^(BOOL success) {
      
      if (success) {
          
          NSLog(@"note updated");
          
      }
      
  }];
    
}

//
- (SMNote *)entryAtIndex:(NSUInteger)index{
    
    if (index < _entries.count) {
        
        return [_entries objectAtIndex:index];
        
    } else {
        
        return nil;
        
    }
}

- (NSInteger ) count {
    
    return self.entries.count;
    
}

//
- (void) addNote:(SMNote *) note {
    
    [_entries addObject:note];
    
    [self saveToURL:[self fileURL] forSaveOperation:
     UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
         
         if (success) {
             
             NSLog(@"note added and doc updated");
             [self openWithCompletionHandler:^ (BOOL success) {}];
             
         }
         
     }];
    
}

//
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    
    NSMutableDictionary *wrappers =
    [NSMutableDictionary dictionary];
    
    //
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *arch =
    [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [arch encodeObject:_entries forKey:@"entries"];
    [arch finishEncoding];
    
    NSFileWrapper *entriesWrapper =
    [[NSFileWrapper alloc] initRegularFileWithContents:data];
    
    [wrappers setObject:entriesWrapper forKey:@"notes.dat"];
    // here you could add another wrapper for other resources,
    // like images
    NSFileWrapper *res =
    [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
    
    return res;
    
}

//
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName
                   error:(NSError **)outError {
    
    NSFileWrapper *wrapper = (NSFileWrapper *)contents;
    NSDictionary *children = [wrapper fileWrappers];
    
    NSFileWrapper *entriesWrap =
    [children objectForKey:@"notes.dat"];
    NSData *data = [entriesWrap regularFileContents];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc]
                               initForReadingWithData:data];
    _entries = [arch decodeObjectForKey:@"entries"];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"com.studiomagnolia.notesLoaded"
     object:self];
    
    return YES;
    
}



@end
