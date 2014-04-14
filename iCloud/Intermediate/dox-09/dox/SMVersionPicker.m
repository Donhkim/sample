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
    
    self.oldContentTextView.text = self.oldNoteContentVersion;
    self.newerContentTextView.text = self.newerNoteContentVersion;
    
}

- (IBAction)pickNewerVersion:(id)sender {
    
    self.currentNote.noteContent = self.newerContentTextView.text;
    
    [self.currentNote saveToURL:[self.currentNote fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        
        if (success) {
        
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
    }];
    
}

- (IBAction)pickOldVersion:(id)sender {
    
    self.currentNote.noteContent = self.oldContentTextView.text;
    
    [self.currentNote saveToURL:[self.currentNote fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        
        if (success) {
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
