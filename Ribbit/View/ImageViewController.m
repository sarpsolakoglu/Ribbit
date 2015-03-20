//
//  ImageViewController.m
//  Ribbit
//
//  Created by Sarp Solakoglu on 05/02/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "ImageViewController.h"
#import <Parse/Parse.h>

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PFFile *file = [_message objectForKey:@"file"];
    NSString *senderName = [_message objectForKey:@"senderName"];
    
    self.title = [NSString stringWithFormat:@"Sent from %@",senderName];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:file.getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView.image = image;
        });
    });
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self respondsToSelector:@selector(timeout)]) {
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
    }
    
}

-(void)timeout {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
