//
//  SignUpViewModel.m
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 20/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "SignUpViewModel.h"
#import "ServiceLayer.h"
#import <ReactiveCocoa.h>

@implementation SignUpViewModel

- (instancetype) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

-(void) initialize {
    self.title = NSLocalizedString(@"Log in", @"");
    //Check if username, password and email is valid. Just length check for simpleness
    //Observe the username field and get the text and map it to boolean
    RACSignal *validUsername = [RACObserve(self, username)
                                map:^id(NSString *username) {
                                    return @([username length] > 4);
                                }];
    //Observe the password field and get the text and map it to boolean
    RACSignal *validPassword = [RACObserve(self, password)
                                map:^id(NSString *password) {
                                    return @([password length] > 4);
                                }];
    //Observe the email field and get the text and map it to boolean
    RACSignal *validEmail = [RACObserve(self, email)
                                map:^id(NSString *email) {
                                    return @([email length] > 4);
                                }];
    //Combine the two signals to get if both are valid
    RACSignal *enableSignal = [RACSignal combineLatest:@[validUsername,validPassword,validEmail]
                                                reduce:^id(NSNumber* username, NSNumber* password, NSNumber* email){
                                                    return @([username boolValue] && [password boolValue] && [email boolValue]);
                                                }];
    //Use this signal to enable the command
    self.signUpCommand = [[RACCommand alloc] initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        return [self signUpAction];
    }];
}

- (RACSignal*) signUpAction {
    return [[ServiceLayer parseService] signUpCallWithUsername:_username password:_password andEmail:_email];
}

@end
