//
//  InboxViewCell.m
//  Ribbit
//
//  Created by Sarp Oğulcan Solakoğlu on 22/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "InboxViewCell.h"
#import "InboxCellViewModel.h"

@implementation InboxViewCell

- (void) bindViewModel:(id)viewModel {
    InboxCellViewModel *cellViewModel = (InboxCellViewModel*)viewModel;
    self.textLabel.text = cellViewModel.senderName;
    NSString *fileType = cellViewModel.fileType;
    
    if ([fileType isEqualToString:@"image"]) {
        self.imageView.image = [UIImage imageNamed:@"icon_image"];
    } else if ([fileType isEqualToString:@"video"]){
        self.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
}

@end
