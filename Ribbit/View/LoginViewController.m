//
//  LoginViewController.m
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 04/02/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "LoginViewModel.h"
#import <ReactiveCocoa.h>
#import <RACEXTScope.h>

@interface LoginViewController ()
@property (nonatomic,strong) LoginViewModel* viewModel;
@end

@implementation LoginViewController

- (instancetype) initWithViewModel:(id<ViewModel>)viewModel {
    if (self = [super init]) {
        _viewModel = viewModel;
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _viewModel = [LoginViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewModel];
}

- (void)bindViewModel {
    self.title = self.viewModel.title;
    //Binding
    RAC(self.viewModel,username) = self.usernameField.rac_textSignal;
    RAC(self.viewModel,password) = self.passwordField.rac_textSignal;
    
    [[self.viewModel.loginCommand.executing
      //deliver signal only when result changes
      distinctUntilChanged]
      //subscribe to result
      subscribeNext:^(NSNumber *executing) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = [executing boolValue];
    }];
    
    self.loginButton.rac_command = self.viewModel.loginCommand;
    
    //Command execution error
    [[self.viewModel.loginCommand.errors
      deliverOn:[RACScheduler mainThreadScheduler]]
      subscribeNext:^(NSError *error) {
        NSString *errorString = [error userInfo][@"error"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
    
    //Command execution succeeded
    @weakify(self)
    [[[self.viewModel.loginCommand.executionSignals
       //concatenate signals
        flattenMap:^RACStream *(RACSignal *subscribeSignal) {
            //convert to RACEvent
            return [[subscribeSignal materialize]
                    //Filter to only deliver completed signal
                    filter:^BOOL(RACEvent *event) {
                        return event.eventType == RACEventTypeCompleted;
                    }];
        }]
      //deliver the event on the main thread
      deliverOn:[RACScheduler mainThreadScheduler]]
      //dismiss view controller
      subscribeNext:^(id x) {
          @strongify(self)
          [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
