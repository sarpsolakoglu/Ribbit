//
//  InboxViewModel.m
//  Ribbit
//
//  Created by Sarp Oğulcan Solakoğlu on 22/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "InboxViewModel.h"
#import "ServiceLayer.h"
#import <ReactiveCocoa.h>
#import <Parse/Parse.h>
#import "InboxCellViewModel.h"

@implementation InboxViewModel

-(instancetype)init{
    if(self = [super init]) {
        [self initialize];
    }
    return self;
}

-(void)initialize {
    self.title = NSLocalizedString(@"Inbox", @"");
    //set command for getting the inbox
    self.getInboxCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
         return [[self getInbox] doNext:^(NSArray *objects) {
             NSMutableArray *inboxCellVMs = [NSMutableArray array];
             //get the PFObject from Parse and init the ViewModel of the ViewTableCell
             for (PFObject *message in objects) {
                 InboxCellViewModel *inboxCellVM = [[InboxCellViewModel alloc] initWithMessage:message];
                 [inboxCellVMs addObject:inboxCellVM];
             }
             self.messages = inboxCellVMs;
         }];
    }];
    //set command for when a cell is selected, message is given in the execute command inside the helper class CETableViewBindingHelper
    
    self.cellSelected = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(InboxCellViewModel *cellViewModel) {
        return [self cellSelectedSignal:cellViewModel];
    }];
    
}

-(RACSignal*)getInbox {
   return [[ServiceLayer parseService] getInbox];
}

-(RACSignal*)cellSelectedSignal:(InboxCellViewModel*)cellViewModel{
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //non-UI stuff handled here
        PFObject *message = cellViewModel.message;
        
        NSMutableArray *recipients = [NSMutableArray arrayWithArray:[message objectForKey:@"recipientIds"]];
        
        if (recipients.count == 1) {
            [message deleteInBackground];
        } else {
            [recipients removeObject:[[PFUser currentUser] objectId]];
            [message setObject:recipients forKey:@"recipientIds"];
            
            [message saveInBackground];
        }
        
        [subscriber sendCompleted];
        return nil;
    }];  
    
}

@end
