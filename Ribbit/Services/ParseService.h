//
//  ParseService.h
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 20/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;

@interface ParseService : NSObject
-(RACSignal*)loginCallWithUsername:(NSString*)username andPassword:(NSString*)password;
-(RACSignal*)signUpCallWithUsername:(NSString*)username password:(NSString*)password andEmail:(NSString*)email;
-(RACSignal*)getInbox;
@end
