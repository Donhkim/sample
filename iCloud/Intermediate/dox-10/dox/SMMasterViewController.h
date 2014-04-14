//
//  SMMasterViewController.h
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

//
#import <UIKit/UIKit.h>
#import "SMNote.h"
#import "SMTag.h"

@class SMDetailViewController;

@interface SMMasterViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) SMDetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
