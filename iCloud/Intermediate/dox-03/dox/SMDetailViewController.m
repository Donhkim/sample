//
//  SMDetailViewController.m
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMDetailViewController.h"

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

- (void)configureView
{
    if (self.detailItem) {
        self.noteTextView.text = self.detailItem.noteContent;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    self.noteTextView.backgroundColor = [UIColor lightGrayColor];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(saveEdits:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
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
