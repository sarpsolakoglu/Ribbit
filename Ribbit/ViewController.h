//
//  ViewController.h
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 20/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//
#import "ViewModel.h"

@protocol ViewController <NSObject>
@required
-(instancetype)initWithViewModel:(id<ViewModel>)viewModel;
-(void)bindViewModel;
@end
