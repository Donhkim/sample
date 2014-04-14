//
//  SMVersionPicker.m
//  dox
//
//  Created by Cesare Rocchi on 10/13/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMVersionPicker.h"

@interface SMVersionPicker ()

@end

@implementation SMVersionPicker


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Pick a version";
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.thisDeviceContentTextView.text = self.thisDeviceContentVersion;
    self.otherDeviceContentTextView.text = self.otherDeviceContentVersion;
    
}

- (IBAction)pickOtherDeviceVersion:(id)sender {
    
    self.currentNote.noteContent = self.otherDeviceContentTextView.text;
    [self cleanConflicts];
    
    [self.currentNote saveToURL:[self.currentNote fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        
        if (success) {
        
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"com.studiomagnolia.conflictResolved"
             object:self];
            
        }
        
    }];
    
}

- (IBAction)pickThisDeviceVersion:(id)sender {
    
    self.currentNote.noteContent = self.thisDeviceContentTextView.text;
    [self cleanConflicts];
    
    [self.currentNote saveToURL:[self.currentNote fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        
        if (success) {
            
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"com.studiomagnolia.conflictResolved"
             object:self];
            
        }
        
    }];
    
}

- (void) cleanConflicts {
    
    NSArray *conflicts =
    [NSFileVersion unresolvedConflictVersionsOfItemAtURL:
     [self.currentNote fileURL]];
    for (NSFileVersion *c in conflicts) {
        c.resolved = YES;
    }
    
    NSError *error = nil;
    BOOL ok = [NSFileVersion removeOtherVersionsOfItemAtURL:
               [self.currentNote fileURL] error:&error];
    
    if (!ok) {
    
        NSLog(@"Can't remove other versions: %@", error);
    
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
