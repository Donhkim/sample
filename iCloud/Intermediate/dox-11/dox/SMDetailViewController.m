//
//  SMDetailViewController.m
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMDetailViewController.h"
#import "SMTag.h"
#import "SMTagPickerViewController.h"

@interface SMDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation SMDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
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
        self.title = self.detailItem.noteTitle;
        
        NSArray *tagsArray = [self.detailItem.tags allObjects];
        NSMutableArray *tagNames =
        [NSMutableArray arrayWithCapacity:tagsArray.count];
        for (SMTag *t in tagsArray) {
            [tagNames addObject:t.tagContent];
        }
        NSString *s = [tagNames componentsJoinedByString:@","];
        self.tagsLabel.text = s;
        [self.noteTextView becomeFirstResponder];
                
    }
}


//
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    NSArray *tagsArray = [self.detailItem.tags allObjects];
    NSMutableArray *tagNames =
    [NSMutableArray arrayWithCapacity:tagsArray.count];
    for (SMTag *t in tagsArray) {
        [tagNames addObject:t.tagContent];
    }
    NSString *s = [tagNames componentsJoinedByString:@","];
    self.tagsLabel.text = s;
    [self.noteTextView becomeFirstResponder];
    
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
    
    
    //NEW
    self.tagsLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(tagsTapped)];
    [self.tagsLabel addGestureRecognizer:tapGesture];
    
    
}

//
- (void) tagsTapped {

    SMTagPickerViewController *tagPicker = nil;

    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPhone) {
        tagPicker = [[SMTagPickerViewController alloc] initWithNibName:
                     @"SMTagPickerViewController_iPhone" bundle:nil];
    } else {
        tagPicker = [[SMTagPickerViewController alloc] initWithNibName:
                     @"SMTagPickerViewController_iPad" bundle:nil];
    }
    
    tagPicker.currentNote = self.detailItem;
    
    [self.navigationController pushViewController:tagPicker
                                         animated:YES];
    
}

//
- (void) saveEdits:(id)sender {

    self.detailItem.noteContent = self.noteTextView.text;
    
    NSError *error = nil;
    if (![self.detailItem.managedObjectContext save:&error]) {
        NSLog(@"Core data error %@, %@", error, [error userInfo]);

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
