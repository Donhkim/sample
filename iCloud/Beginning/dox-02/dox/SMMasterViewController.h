//
//  SMMasterViewController.h
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMNote.h"

@class SMDetailViewController;

@interface SMMasterViewController : UITableViewController

@property (strong, nonatomic) SMDetailViewController *detailViewController;
@property (strong, nonatomic) NSMetadataQuery *query;
@property (strong, nonatomic) NSMutableArray *notes;

- (void)loadDocument;


@end
