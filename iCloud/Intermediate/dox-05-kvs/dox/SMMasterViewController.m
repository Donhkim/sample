//
//  SMMasterViewController.m
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMMasterViewController.h"
#import "SMDetailViewController.h"

#define kFILENAME @"notes.dox"

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

//
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.detailViewController = (SMDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
            
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDocument)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notesLoaded:)
     name:@"com.studiomagnolia.notesLoaded"
     object:nil];
    
    
    NSUbiquitousKeyValueStore* store =
    [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateCurrentNoteIfNeeded:)
     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
     object:store];
    [store synchronize];
    
}


//
- (void)loadDocument {
        
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq) {
        
        NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
        _query = query;
        [query setSearchScopes:[NSArray arrayWithObject:
                                NSMetadataQueryUbiquitousDocumentsScope]];
        NSPredicate *pred = [NSPredicate predicateWithFormat:
                             @"%K == %@", NSMetadataItemFSNameKey, kFILENAME];
        [query setPredicate:pred];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(queryDidFinishGathering:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:query];
        
        [query startQuery];
        
    } else {
        
        NSLog(@"No iCloud access");
        
    }
    
}

//
- (void)queryDidFinishGathering:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [self loadData:query];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    
    _query = nil; 
    
}


//
- (void)loadData:(NSMetadataQuery *)query {
    
    if ([query resultCount] == 1) {
        
        NSMetadataItem *item = [query resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        
        SMNotesDocument *doc =
        [[SMNotesDocument alloc] initWithFileURL:url];
        self.document = doc;
        
        [doc openWithCompletionHandler:^ (BOOL success) {
            if (success) {
                NSLog(@"doc opened from cloud");
                [self.tableView reloadData];
            } else {
                NSLog(@"failed to open");
            }
        }];
        
    } else { // No notes in iCloud
        
        NSURL *ubiqContainer = [[NSFileManager defaultManager]
                                URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiquitousPackage = [[ubiqContainer
                                     URLByAppendingPathComponent:@"Documents"]
                                    URLByAppendingPathComponent:kFILENAME];
        
        SMNotesDocument *doc = [[SMNotesDocument alloc]
                                initWithFileURL:ubiquitousPackage];
        self.document = doc;
        [doc saveToURL:[doc fileURL] forSaveOperation:
         UIDocumentSaveForCreating completionHandler:
         ^(BOOL success) {
             NSLog(@"new document saved to iCloud");
             [doc openWithCompletionHandler:^(BOOL success) {
                 NSLog(@"new document was opened from iCloud");
             }];            
         }];                
    }        
}

//
- (void) notesLoaded:(NSNotification *) notification {
    
    self.document = notification.object;
    [self.tableView reloadData];
    
}

- (void) updateCurrentNoteIfNeeded:(NSNotification *) notification {
    
    NSLog(@"updateCurrent");
    
    NSString *currentNoteId =
    [[NSUbiquitousKeyValueStore defaultStore] stringForKey:
     @"com.studiomagnolia.currentNote"];
    SMNote *note = [self.document noteById:currentNoteId];
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPhone) {
        
        self.detailViewController.detailItem = note;
        
        SMDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SMDetailViewController"];
        [self.navigationController pushViewController:detailViewController animated:YES];
            
    } else {
        
        self.detailViewController.detailItem = note;
        
    }
        
}


//
- (void)insertNewObject:(id)sender
{
    
    SMNote *doc = [[SMNote alloc] init];
    doc.noteContent = @"Test";
    [self.document addNote:doc];
    
}

#pragma mark - Table View
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.document.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SMNote *n = [self.document entryAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] ==
            UIUserInterfaceIdiomPhone) {
            cell.accessoryType =
            UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
    }
    
    cell.textLabel.text = n.noteId;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
        SMNote *selectedNote = [self.document entryAtIndex:indexPath.row];
        self.detailViewController.detailItem = selectedNote;
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SMNote *selectedNote = [self.document entryAtIndex:indexPath.row];
        self.detailViewController.detailItem = selectedNote;
        [[segue destinationViewController] setDetailItem:selectedNote];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
