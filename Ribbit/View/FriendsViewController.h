//
//  FriendsViewController.h
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 04/02/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsViewController : UITableViewController
@property (nonatomic,strong) NSMutableArray *friends;
- (IBAction) unwindToFriendsPage:(UIStoryboardSegue*)unwindSegue;
@end
