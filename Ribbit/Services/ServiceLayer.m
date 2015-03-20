//
//  ServiceLayer.m
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 20/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "ServiceLayer.h"

@interface ServiceLayer()
@property (nonatomic, strong) ParseService *parseService;
@end

@implementation ServiceLayer

+ (ServiceLayer*) service {
    static ServiceLayer *service;
    static dispatch_once_t dispatchO;
    dispatch_once(&dispatchO, ^{
        service = [[ServiceLayer alloc] init];
    });
    return service;
}

+ (ParseService*) parseService {
    return [ServiceLayer service].parseService;
}

- (instancetype) init {
    if (self = [super init]) {
        _parseService = [[ParseService alloc] init];
    }
    return self;
}

@end
