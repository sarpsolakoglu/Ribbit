//
//  ImageViewController.h
//  Ribbit
//
//  Created by Sarp Solakoglu on 05/02/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFObject;

@interface ImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) PFObject* message;

@end
