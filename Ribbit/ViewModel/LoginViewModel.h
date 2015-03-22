//
//  LoginViewModel.h
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 20/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

@import Foundation;
@class RACCommand;
#import "ViewModel.h"


@interface LoginViewModel : NSObject <ViewModel>

@property(nonatomic,copy) NSString *username;
@property(nonatomic,copy) NSString *password;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,strong) RACCommand *loginCommand;

@end
