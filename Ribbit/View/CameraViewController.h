//
//  CameraViewController.h
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 05/02/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)sendToRecipients:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
