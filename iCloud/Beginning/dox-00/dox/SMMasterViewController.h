//
//  SMMasterViewController.h
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMDetailViewController;

@interface SMMasterViewController : UITableViewController

@property (strong, nonatomic) SMDetailViewController *detailViewController;

@end
