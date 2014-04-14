//
//  SMMasterViewController.m
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMMasterViewController.h"
#import "SMDetailViewController.h"

#define kFILENAME @"mydocument.dox"

@interface SMMasterViewController () {
    NSMutableArray *_objects;
}

- (void)loadData:(NSMetadataQuery *)query;

@end

@implementation SMMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (SMDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self loadDocument];
    
}

- (void)loadDocument {
    
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    _query = query;
    [query setSearchScopes:[NSArray arrayWithObject:
                            NSMetadataQueryUbiquitousDocumentsScope]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:
                         @"%K == %@", NSMetadataItemFSNameKey, kFILENAME];
    [query setPredicate:pred];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(queryDidFinishGathering:)
     name:NSMetadataQueryDidFinishGatheringNotification
     object:query];
    
    [query startQuery];
    
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    
    _query = nil;
    
	[self loadData:query];
    
}

- (void)loadData:(NSMetadataQuery *)query {
    
    if ([query resultCount] == 1) {
        
        NSMetadataItem *item = [query resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        SMNote *doc = [[SMNote alloc] initWithFileURL:url];
        self.doc = doc;
        [self.doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"iCloud document opened");
                [self.tableView reloadData];
                
            } else {
                NSLog(@"failed opening document from iCloud");
            }
        }];
        
	} else {
        
        NSURL *ubiq = [[NSFileManager defaultManager]
                       URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiqPackage = [[ubiq URLByAppendingPathComponent:
                                     @"Documents"] URLByAppendingPathComponent:kFILENAME];
        
        SMNote *doc = [[SMNote alloc] initWithFileURL:ubiqPackage];
        self.doc = doc;
        
        [doc saveToURL:[doc fileURL]
      forSaveOperation:UIDocumentSaveForCreating
     completionHandler:^(BOOL success) {
         if (success) {
             [doc openWithCompletionHandler:^(BOOL success) {
                 NSLog(@"newly created document opened");
                 [self.tableView reloadData];
             }];
         }
     }];
    }
    
    
    
}




- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.doc.noteContent;
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.detailViewController.detailItem = self.doc;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        [[segue destinationViewController] setDetailItem:self.doc];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
