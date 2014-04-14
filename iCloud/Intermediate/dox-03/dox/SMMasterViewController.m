//
//  SMMasterViewController.m
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMMasterViewController.h"
#import "SMDetailViewController.h"

//
@interface SMMasterViewController () {
    NSMutableArray *_objects;
}

- (void)loadData:(NSMetadataQuery *)query;
- (NSURL *) localNotesURL;
- (NSURL *) ubiquitousNotesURL;
- (void) setNotesUbiquity;

@end

@implementation SMMasterViewController

//
static NSString * const useiCloudKey = @"useiCloud";

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
    
    self.notes = [NSMutableArray array];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDocument)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    
    // Copy this
    _useiCloud = [[NSUserDefaults standardUserDefaults] boolForKey:useiCloudKey];
    
    self.cloudSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(40, 4, 80, 27)];
    self.cloudSwitch.on = _useiCloud;
    
    [self.cloudSwitch addTarget:self
                    action:@selector(enableDisableiCloud:)
          forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *flexSpace1 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil action:NULL];
    
    UIBarButtonItem *iCloudSwitchItem = [[UIBarButtonItem alloc]
                                         initWithCustomView:self.cloudSwitch];
    
    UIBarButtonItem *flexSpace2 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil action:NULL];
    
    self.toolbarItems = @[flexSpace1,iCloudSwitchItem, flexSpace2];
        
}

//
- (void) enableDisableiCloud: (id) sender {
 
    self.useiCloud = [sender isOn];

}

//
- (void) setUseiCloud:(BOOL)val {
    
    if (_useiCloud != val) {
        
        _useiCloud = val;
        [[NSUserDefaults standardUserDefaults] setBool:_useiCloud
                                                forKey:useiCloudKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (!_useiCloud ) {
            
            UIAlertView *iCloudAlert = [[UIAlertView alloc]
                                        initWithTitle:@"Attention"
                                        message:@"This will delete notes from your iCloud account. Are you sure?"
                                        delegate:self
                                        cancelButtonTitle:@"No"
                                        otherButtonTitles:@"Yes", nil];
            
            [iCloudAlert show];
            
        } else {
            
            [self startMigration];
            
        }        
    }    
}


//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [self.cloudSwitch setOn:YES animated:YES];
        _useiCloud = YES;
        
    } else {
        
        [self startMigration];
        
    }
    
}

//
- (void) setNotesUbiquity {
    
    NSURL *baseUrl = [self localNotesURL];
    
    if (_useiCloud)
        baseUrl = [self ubiquitousNotesURL];
    
    for (SMNote *note in self.notes) {
        
        NSURL *destUrl = [baseUrl URLByAppendingPathComponent:
                          [note.fileURL lastPathComponent]];
        NSLog(@"note.fileURL = %@", note.fileURL);
        NSLog(@"destUrl = %@", destUrl);
        
        [[NSFileManager defaultManager] setUbiquitous:_useiCloud
                                            itemAtURL:note.fileURL
                                       destinationURL:destUrl
                                                error:NULL];
        
    }
    
    [self performSelectorOnMainThread:@selector(ubiquityIsSet)
                           withObject:nil
                        waitUntilDone:YES];
    
    
}

//
- (void) ubiquityIsSet {
    
    NSLog(@"notes are now ubiq? %i", _useiCloud);
    
}

//
- (void) startMigration {
    NSOperationQueue *iCloudQueue = [NSOperationQueue new];
    NSInvocationOperation *oper = [[NSInvocationOperation alloc]
                                   initWithTarget:self
                                   selector:@selector(setNotesUbiquity)
                                   object:nil];
    [iCloudQueue addOperation:oper];    
}

//
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
}


- (void) viewDidAppear:(BOOL)animated {

    //NSLog(@"notes are %@", self.notes);
    
}

//
- (NSURL *) localNotesURL {
    
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
    
}

- (NSURL *) ubiquitousNotesURL {
    
    return [[[NSFileManager defaultManager]
             URLForUbiquityContainerIdentifier:nil]
            URLByAppendingPathComponent:@"Documents"];
    
}

//
- (void)loadDocument {
    
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq && _useiCloud) { // iCloud is on (from previous chapter)
        
        self.query = [[NSMetadataQuery alloc] init];
        [self.query setSearchScopes:[NSArray arrayWithObject:
                                     NSMetadataQueryUbiquitousDocumentsScope]];
        NSPredicate *pred = [NSPredicate predicateWithFormat:
                             @"%K like 'Note_*'", NSMetadataItemFSNameKey];
        [self.query setPredicate:pred];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(queryDidFinishGathering:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:self.query];
        
        [self.query startQuery];
        
    } else { // iCloud switch is off or iCloud not available
        
        [self.notes removeAllObjects];
        NSArray *arr = [[NSFileManager defaultManager]
                        contentsOfDirectoryAtURL:[self localNotesURL]
                        includingPropertiesForKeys:nil options:0 error:NULL];
        
        for (NSURL *filePath in arr) {
            
            SMNote *doc = [[SMNote alloc] initWithFileURL:filePath];
            [self.notes addObject:doc];
            [self.tableView reloadData];
            
        }
        
    }
    
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [self loadData:query];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    
    self.query = nil;
    
}


//
- (void)loadData:(NSMetadataQuery *)query {
    
    [self.notes removeAllObjects];
    
    for (NSMetadataItem *item in [query results]) {
        
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        SMNote *doc = [[SMNote alloc] initWithFileURL:url];
        
        [doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                
                [self.notes addObject:doc];
                [self.tableView reloadData];
                
            } else {
                NSLog(@"failed to open from iCloud");
            }
            
        }];
    }
}



//
- (void)insertNewObject:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    NSString *fileName = [NSString stringWithFormat:@"Note_%@",
                          [formatter stringFromDate:[NSDate date]]];
    
    
    NSURL *baseURL = [self localNotesURL];
    if (_useiCloud) {
        baseURL = [self ubiquitousNotesURL]; // <-- iCloud url
    }
    NSURL *noteFileURL = [baseURL
                          URLByAppendingPathComponent:fileName];
    SMNote *doc = [[SMNote alloc] initWithFileURL:noteFileURL];
    
    [doc saveToURL:[doc fileURL] forSaveOperation:
     UIDocumentSaveForCreating completionHandler:^(BOOL success) {
         
         if (success) {
             
             [self.notes addObject:doc];
             [self.tableView reloadData];
             
         }
         
     }];
}

#pragma mark - Table View
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    SMNote * note = self.notes[indexPath.row];
    cell.textLabel.text = note.fileURL.lastPathComponent;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        SMNote *selectedNote = self.notes[indexPath.row];
        self.detailViewController.detailItem = selectedNote;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SMNote *selectedNote = self.notes[indexPath.row];
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
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
