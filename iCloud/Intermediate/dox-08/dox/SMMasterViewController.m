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
    
    //
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(conflictResolved)
     name:@"com.studiomagnolia.conflictResolved"
     object:nil];

}

//
- (void) conflictResolved {
    
    [self.tableView reloadData];
    
}

//
- (void)noteHasChanged:(id)sender {
    
    [self.tableView reloadData];

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


//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    SMNote * note = self.notes[indexPath.row];
    
    if ([note documentState] == UIDocumentStateInConflict) {
        cell.textLabel.textColor = [UIColor redColor];
        
        NSArray *conflicts =
        [NSFileVersion unresolvedConflictVersionsOfItemAtURL:note.fileURL];
        
        for (NSFileVersion *version in conflicts) {
            
            NSLog(@"===========");
            NSLog(@"name = %@", version.localizedName);
            NSLog(@"date = %@", version.modificationDate);
            NSLog(@"device = %@", version.localizedNameOfSavingComputer);
            NSLog(@"url = %@", version.URL);
            NSLog(@"===========");
            
        }
        
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.textLabel.text = note.fileURL.lastPathComponent;
    return cell;
    
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SMNote *selectedNote = self.notes[indexPath.row];
    
    if (selectedNote.documentState == UIDocumentStateInConflict) {
        
        SMVersionPicker *picker = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            picker = [[SMVersionPicker alloc]
                      initWithNibName:@"SMVersionPicker_iPad" bundle:nil];
            
        } else {
        
            picker = [[SMVersionPicker alloc]
                      initWithNibName:@"SMVersionPicker_iPhone" bundle:nil];
        }
        
        picker.currentNote = selectedNote;
        
        NSArray *conflicts =
        [NSFileVersion unresolvedConflictVersionsOfItemAtURL:selectedNote.fileURL];
        
        for (NSFileVersion *version in conflicts) {
            
            SMNote *otherDeviceNote = [[SMNote alloc]
                                       initWithFileURL:version.URL];
            
            [otherDeviceNote openWithCompletionHandler:^(BOOL success) {
                
                if (success) {
                    picker.thisDeviceContentVersion = selectedNote.noteContent;
                    picker.otherDeviceContentVersion =
                    otherDeviceNote.noteContent;
                    [self.navigationController pushViewController:
                     picker animated:YES];
                }
                
            }];
        }
    }
    
    if (selectedNote.documentState == UIDocumentStateNormal) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.detailViewController.detailItem = selectedNote;
            
        } else {
            
            SMDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SMDetailViewControllerID"];
            detailViewController.detailItem = selectedNote;
            [self.navigationController pushViewController:detailViewController animated:YES];
            
        }
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
