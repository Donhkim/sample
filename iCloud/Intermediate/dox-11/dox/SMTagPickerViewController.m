//
//  SMTagPickerViewController.m
//  dox
//
//  Created by Cesare Rocchi on 10/14/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMTagPickerViewController.h"

@interface SMTagPickerViewController ()

@end

@implementation SMTagPickerViewController

//
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pickedTags = [[NSMutableSet alloc] init];
    self.title = @"Tag your note";
    
    // Retrieve tags
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

	}
    
    // in case there are no tags,
    // presumably it's the first time we run the application
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        for (int i = 1; i < 6; i++) {
            
            SMTag *t = [NSEntityDescription
                        insertNewObjectForEntityForName:@"SMTag"
                        inManagedObjectContext:
                        self.currentNote.managedObjectContext];
            t.tagContent =  [NSString stringWithFormat:@"tag%i", i];
            
        }
        
        // Save to new tags
        NSError *error = nil;
        if (![self.currentNote.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error,
                  [error userInfo]);

        } else {
            // Retrieve tags again
            NSLog(@"new tags added");
            [self.fetchedResultsController performFetch:&error];
        }
    }
    
    // Each tag attached to the note should be included
	// in the pickedTags array
    for (SMTag *tag in self.currentNote.tags) {
        
        [self.pickedTags addObject:tag];
        
    }
    
}

//
- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.currentNote.tags = self.pickedTags;
    
    NSError *error = nil;
    if (![self.currentNote.managedObjectContext save:&error]) {
        
        NSLog(@"Core data error %@, %@", error, [error userInfo]);

        
    }
    
}

//
- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SMTag"
                                   inManagedObjectContext:
                                   self.currentNote.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"tagContent"
                                        ascending:NO];
    NSArray *sortDescriptors =
    [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController =
	[[NSFetchedResultsController alloc]
     initWithFetchRequest:fetchRequest
     managedObjectContext:self.currentNote.managedObjectContext
     sectionNameKeyPath:nil
     cacheName:@"Master"];
    
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Core data error %@, %@", error, [error userInfo]);

	}
    
    return _fetchedResultsController;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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

//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    SMTag *tag = (SMTag *)[self.fetchedResultsController
                           objectAtIndexPath:indexPath];
    if ([self.pickedTags containsObject:tag]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = tag.tagContent;
    
    return cell;
    
}


#pragma mark - Table view delegate

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMTag *tag = (SMTag *)[self.fetchedResultsController
                           objectAtIndexPath:indexPath];
    UITableViewCell * cell = [self.tableView
                              cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    if ([self.pickedTags containsObject:tag]) {
        
        [self.pickedTags removeObject:tag];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else {
        
        [self.pickedTags addObject:tag];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
}

@end
