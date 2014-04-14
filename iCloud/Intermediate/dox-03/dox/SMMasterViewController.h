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
//
@interface SMMasterViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) SMDetailViewController *detailViewController;
@property (strong, nonatomic) NSMetadataQuery *query;
@property (strong, nonatomic) NSMutableArray *notes;
@property (strong, nonatomic) UISwitch *cloudSwitch;
@property BOOL useiCloud;

- (void)loadDocument;


@end
