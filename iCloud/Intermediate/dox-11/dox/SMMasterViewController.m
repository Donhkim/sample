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
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // 1) Create a fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 2) Create an entity description for the entity to be fetched.
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SMNote"
                                   inManagedObjectContext:
                                   self.managedObjectContext];
    
    // 3) Assign the entity description to the request.
    [fetchRequest setEntity:entity];
    
    // 4) Create a sort descriptor to specify how the results should be
    // sorted.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"noteTitle"
                                        ascending:NO];
    NSArray *sortDescriptors =
    [NSArray arrayWithObjects:sortDescriptor, nil];
    
    // 5) Assign the sort descriptor to the request.
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 6) Create a fetched results controller with the fetch request and
    // the context.
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc]
     initWithFetchRequest:fetchRequest
     managedObjectContext:self.managedObjectContext
     sectionNameKeyPath:nil
     cacheName:@"Master"];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    // 7) Perform a fetch request to retrieve the data!
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }
    
    return _fetchedResultsController;
    
}

//
- (void)controllerDidChangeContent: (NSFetchedResultsController *)controller {
    
    NSLog(@"something has changed");
    [self.tableView reloadData];
    
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
    
    //
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadNotes)
     name:@"com.studiomagnolia.refetchNotes"
     object:nil];
}

//
- (void) reloadNotes {
    
    NSLog(@"refetching notes");
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        
		NSLog(@"Core data error %@, %@", error, [error userInfo]);

	} else {
        
        NSLog(@"reloadNotes - results are %i",
              self.fetchedResultsController.fetchedObjects.count);
        [self.tableView reloadData];
        
    }
    
}


//
- (void)insertNewObject:(id)sender
{
    
    SMNote *newNote = [NSEntityDescription
                       insertNewObjectForEntityForName:@"SMNote"
                       inManagedObjectContext:self.managedObjectContext];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    NSString *noteTitle = [NSString stringWithFormat:@"Note_%@",
                           [formatter stringFromDate:[NSDate date]]];
    newNote.noteTitle = noteTitle;
    newNote.noteContent = @"New note content";
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"Core Data error %@, %@", error, [error userInfo]);
    
    }
    
}

#pragma mark - Table View
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo =
    [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSManagedObject *managedObject = [self.fetchedResultsController
                                      objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = [managedObject valueForKey:@"noteTitle"];
    
    return cell;
    
}


//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        SMNote *n = (SMNote *)[self.fetchedResultsController
                               objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = n;
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SMNote *n = (SMNote *)[self.fetchedResultsController
                               objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = n;
        [[segue destinationViewController] setDetailItem:n];
        
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
