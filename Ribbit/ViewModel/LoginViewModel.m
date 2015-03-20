//
//  LoginViewModel.m
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 20/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "LoginViewModel.h"
#import <ReactiveCocoa.h>
#import "ServiceLayer.h"

@implementation LoginViewModel

- (instancetype) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

-(void) initialize {
    self.title = NSLocalizedString(@"Log in", @"");
    //Check if username and password is valid. Just length check for simpleness
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
    //Combine the two signals to get if both are valid
    RACSignal *enableSignal = [RACSignal combineLatest:@[validUsername,validPassword]
                                                reduce:^id(NSNumber* username, NSNumber* password){
                                                    return @([username boolValue] && [password boolValue]);
                                                }];
    //Use this signal to enable the command
    self.loginCommand = [[RACCommand alloc] initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        return [self loginAction];
    }];
}

- (RACSignal*) loginAction {
    return [[ServiceLayer parseService] loginCallWithUsername:_username andPassword:_password];
}

@end
