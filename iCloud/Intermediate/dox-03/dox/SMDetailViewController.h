//
//  SMDetailViewController.h
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMNote.h"

@interface SMDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) SMNote *detailItem;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;

@end
