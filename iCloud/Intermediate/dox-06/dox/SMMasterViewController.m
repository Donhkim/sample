//
//  SMMasterViewController.m
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMMasterViewController.h"
#import "SMDetailViewController.h"

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
    
    self.notes = [NSMutableArray array];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDocument)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object:nil];
    //
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(noteHasChanged:)
     name:UIDocumentStateChangedNotification
     object:nil];
    
    //
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(loadDocument)
     name:@"com.studiomagnolia.noteReinstated"
     object:nil];
    
}

//
- (void)noteHasChanged:(id)sender {
    
    SMNote *d = [sender object];
    
    if ([d documentState] == UIDocumentStateSavingError) {
    
        [self.tableView reloadData];
    
    }
}


//
- (void)loadDocument {
    
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq) {
        
        self.query = [[NSMetadataQuery alloc] init];
        [self.query setSearchScopes:
         [NSArray arrayWithObject:
          NSMetadataQueryUbiquitousDocumentsScope]];
        NSPredicate *pred = [NSPredicate predicateWithFormat:
                             @"%K like 'Note_*'", NSMetadataItemFSNameKey];
        [self.query setPredicate:pred];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(queryDidFinishGathering:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:self.query];
        
        [self.query startQuery];
        
    } else {
        
        NSLog(@"No iCloud access");
        
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
    
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    
    NSURL *ubiquitousPackage =
    [[ubiq URLByAppendingPathComponent:@"Documents"]
     URLByAppendingPathComponent:fileName];
    
    SMNote *doc = [[SMNote alloc] initWithFileURL:ubiquitousPackage];
    
    [doc saveToURL:[doc fileURL]
  forSaveOperation:UIDocumentSaveForCreating
 completionHandler:^(BOOL success) {
     
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
    return YES;
}

//
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        SMNote *n = [self.notes objectAtIndex:indexPath.row];
        NSError *err;
        [[NSFileManager defaultManager] removeItemAtURL:[n fileURL]
                                                  error:&err];
        [self.notes removeObjectAtIndex:indexPath.row];
        [tableView
         deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
         withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
