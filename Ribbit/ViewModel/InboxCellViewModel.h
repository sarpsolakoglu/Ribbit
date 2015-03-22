//
//  InboxCellViewModel.h
//  Ribbit
//
//  Created by Sarp Oğulcan Solakoğlu on 22/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFObject;

@interface InboxCellViewModel : NSObject
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *senderName;
@property (nonatomic, strong) PFObject *message;
-(instancetype) initWithMessage:(PFObject*)message;
@end
