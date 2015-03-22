//
//  ParseService.m
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 20/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "ParseService.h"
#import <ReactiveCocoa.h>
#import <Parse/Parse.h>

@implementation ParseService

-(RACSignal*)loginCallWithUsername:(NSString*)username andPassword:(NSString*)password {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *usernameEdited = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *passwordEdited = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [PFUser logInWithUsernameInBackground:usernameEdited password:passwordEdited block:^(PFUser *user, NSError *error) {
            if (!error) {
                [subscriber sendNext:user];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        return nil;
    }];
}

-(RACSignal*)signUpCallWithUsername:(NSString*)username password:(NSString*)password andEmail:(NSString*)email {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *usernameEdited = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *passwordEdited = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *emailEdited = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
       
        PFUser *user = [PFUser user];
        user.username = usernameEdited;
        user.password = passwordEdited;
        user.email = emailEdited;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
            
        return nil;
    }];
}

-(RACSignal*)getInbox {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
        [query orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [subscriber sendNext:objects];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        return nil;
    }];
}
@end
