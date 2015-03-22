//
//  InboxCellViewModel.m
//  Ribbit
//
//  Created by Sarp Oğulcan Solakoğlu on 22/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "InboxCellViewModel.h"
#import <Parse/Parse.h>


@implementation InboxCellViewModel
-(instancetype) initWithMessage:(PFObject*)message{
    if (self = [super init]) {
        self.message = message;
        self.senderName = [message objectForKey:@"senderName"];
        self.fileType = [message objectForKey:@"fileType"];
    }
    return self;
}


@end
