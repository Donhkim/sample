//
//  SMVersionPicker.h
//  dox
//
//  Created by Cesare Rocchi on 10/13/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

//
#import <UIKit/UIKit.h>
#import "SMNote.h"

@interface SMVersionPicker : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *thisDeviceContentTextView;
@property (strong, nonatomic) IBOutlet UITextView *otherDeviceContentTextView;
@property (strong, nonatomic) NSString *thisDeviceContentVersion;
@property (strong, nonatomic) NSString *otherDeviceContentVersion;
@property (strong, nonatomic) SMNote *currentNote;

- (IBAction)pickOtherDeviceVersion:(id)sender;
- (IBAction)pickThisDeviceVersion:(id)sender;

- (void) cleanConflicts;

@end
