//
//  SMDetailViewController.m
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMDetailViewController.h"
//
#import "SMVersionPicker.h"

@interface SMDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation SMDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(SMNote *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

//
- (void)configureView
{
    if (self.detailItem) {
        self.noteTextView.text = self.detailItem.noteContent;
        
        if (self.detailItem.documentState == UIDocumentStateSavingError) {
            UIBarButtonItem *reinstateNoteButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"Reinstate"
                                        style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(reinstateNote)];
            self.navigationItem.rightBarButtonItem = reinstateNoteButton;
        }
    }
}

//
- (void) reinstateNote {
    
    // Generate new filename for note based on date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    NSString *fileName = [NSString stringWithFormat:@"Note_%@",
                          [formatter stringFromDate:[NSDate date]]];
    
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    NSURL *ubiquitousPackage =
    [[ubiq URLByAppendingPathComponent:@"Documents"]
     URLByAppendingPathComponent:fileName];
    
    // Create new note and save it
    SMNote *n = [[SMNote alloc] initWithFileURL:ubiquitousPackage];
    n.noteContent = self.noteTextView.text;
    
    [n saveToURL:[n fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
    
        if (success) {
            
            [[NSNotificationCenter defaultCenter]
               postNotificationName:@"com.studiomagnolia.noteReinstated"
               object:self];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                
                self.detailItem = nil;
                self.noteTextView.text = @"";
                
            } else {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            
        } else {
            
            NSLog(@"error in saving reinstated note");
            
        }
    
    }];
    
}

//
- (void) viewWillAppear:(BOOL)animated {

    self.noteTextView.text = self.detailItem.noteContent;
    
    if (self.detailItem.documentState == UIDocumentStateNormal) {
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                    target:self
                                                                                    action:@selector(saveEdits:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        
    }
    
}

//
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    self.noteTextView.backgroundColor = [UIColor lightGrayColor];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(saveEdits:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    if (self.detailItem.documentState == UIDocumentStateSavingError) {
        UIBarButtonItem *reinstateNoteButton = [[UIBarButtonItem alloc]
                                                initWithTitle:@"Reinstate"
                                                style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(reinstateNote)];
        self.navigationItem.rightBarButtonItem = reinstateNoteButton;
    }
    
    //
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(noteHasChanged:)
     name:UIDocumentStateChangedNotification
     object:nil];
    
}

//
- (void)noteHasChanged:(id)sender {
    
    if (!self.detailItem)
        return;
    
    if (self.detailItem.documentState == UIDocumentStateSavingError) {
        self.title = @"Limbo note";
        UIBarButtonItem *reinstateNoteButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Reinstate"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(reinstateNote)];
        
        self.navigationItem.rightBarButtonItem = reinstateNoteButton;        
    }
    
    
    if (self.detailItem.documentState == UIDocumentStateEditingDisabled) {
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        NSLog(@"document state is UIDocumentStateEditingDisabled");
        
    }
    
    if (self.detailItem.documentState == UIDocumentStateNormal) {
        
        self.navigationItem.leftBarButtonItem.enabled = YES;
        NSLog(@"old content is %@", self.noteTextView.text);
        NSLog(@"new content is %@", self.detailItem.noteContent);
        self.noteTextView.text = self.detailItem.noteContent;
        
        if (![self.noteTextView.text
              isEqualToString:self.detailItem.noteContent]) {
            
            UIBarButtonItem * resolveButton = [[UIBarButtonItem alloc]
                                               initWithTitle:@"Resolve"
                                               style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(resolveNote)];
            
            self.navigationItem.rightBarButtonItem = resolveButton;
            
        }
        
    }
    
}

//
- (void) resolveNote {
    
    SMVersionPicker *picker = nil;
 	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
		picker = [[SMVersionPicker alloc]
                  initWithNibName:@"SMVersionPicker_iPad"
                  bundle:nil];
        
	} else {
		
		picker = [[SMVersionPicker alloc]
                  initWithNibName:@"SMVersionPicker_iPhone"
                  bundle:nil];
        
	}
    
    picker.otherDeviceContentVersion = self.detailItem.noteContent;
    picker.thisDeviceContentVersion = self.noteTextView.text;
    picker.currentNote = self.detailItem;
    
    [self.navigationController pushViewController:picker
                                         animated:YES];
    
}

- (void) saveEdits:(id)sender {

    self.detailItem.noteContent = self.noteTextView.text;
    [self.detailItem updateChangeCount:UIDocumentChangeDone];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    
        self.detailItem = nil;
        self.noteTextView.text = @"";
        
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
