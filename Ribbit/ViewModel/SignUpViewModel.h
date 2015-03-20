//
//  SignUpViewModel.h
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 20/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

@import Foundation;
#import "ViewModel.h"
@class RACCommand;

@interface SignUpViewModel : NSObject <ViewModel>

@property(nonatomic,strong) NSString *username;
@property(nonatomic,strong) NSString *password;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) RACCommand *signUpCommand;

@end
