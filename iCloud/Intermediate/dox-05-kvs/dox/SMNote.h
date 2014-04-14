//
//  SMNote.h
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMNote : NSObject <NSCoding> 

@property (copy, nonatomic) NSString *noteId;
@property (copy, nonatomic) NSString *noteContent;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *updatedAt;

@end
