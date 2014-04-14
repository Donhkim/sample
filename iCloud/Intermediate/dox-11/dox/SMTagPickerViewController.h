//
//  SMTagPickerViewController.h
//  dox
//
//  Created by Cesare Rocchi on 10/14/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

//
#import <UIKit/UIKit.h>
#import "SMNote.h"
#import "SMTag.h"

@interface SMTagPickerViewController : UITableViewController

@property (nonatomic, strong) SMNote *currentNote;
@property (nonatomic, strong) NSMutableSet *pickedTags;
@property (strong, nonatomic) NSFetchedResultsController
*fetchedResultsController;

@end
