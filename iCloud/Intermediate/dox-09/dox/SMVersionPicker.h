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

@property (strong, nonatomic) IBOutlet UITextView *oldContentTextView;
@property (strong, nonatomic) IBOutlet UITextView *newerContentTextView;
@property (strong, nonatomic) NSString *oldNoteContentVersion;
@property (strong, nonatomic) NSString *newerNoteContentVersion;
@property (strong, nonatomic) SMNote *currentNote;

- (IBAction)pickNewerVersion:(id)sender;
- (IBAction)pickOldVersion:(id)sender;

@end
