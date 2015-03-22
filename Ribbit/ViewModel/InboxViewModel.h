//
//  InboxViewModel.h
//  Ribbit
//
//  Created by Sarp Oğulcan Solakoğlu on 22/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

@import Foundation;
#import "ViewModel.h"
@class RACCommand;

@interface InboxViewModel : NSObject <ViewModel>
//contains InboxCellViewModel's
@property (nonatomic,strong) NSArray *messages;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) RACCommand *getInboxCommand;
@property (nonatomic,strong) RACCommand *cellSelected;
@end
