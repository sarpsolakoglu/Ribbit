//
//  AddFriendsViewController.m
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 04/02/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "FriendsViewController.h"
#import <Parse/Parse.h>

@interface AddFriendsViewController ()
@property (nonatomic, strong) NSMutableArray *users;
@end

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelection = YES;
    
    _users = [NSMutableArray array];
    
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFUser *user in objects) {
                if (user != [PFUser currentUser]) {
                    [_users addObject:user];
                }
            }
            [self.tableView reloadData];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addFriendsCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PFUser *user = ((PFUser*)_users[indexPath.row]);
    cell.textLabel.text = user.username;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self isFriend:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    PFUser *user = ((PFUser*)_users[indexPath.row]);
    if ([self isFriend:user]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = ((PFUser*)_users[indexPath.row]);
    if ([self isFriend:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
         cell.accessoryType = UITableViewCellAccessoryNone;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"unwindToFriendsPage"]) {
        NSMutableArray *selectedFriends = [NSMutableArray new];
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            [selectedFriends addObject:[_users objectAtIndex:indexPath.row]];
        }
        if (selectedFriends.count > 0) {
            PFRelation *relation = [[PFUser currentUser] relationForKey:@"friendsRelation"];
            for (PFUser *friend in selectedFriends) {
                [relation addObject:friend];
            }
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSString *errorString = [error userInfo][@"error"];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            }];
        }
        [selectedFriends addObjectsFromArray:_friends];
        if (selectedFriends.count > 0) {
            if ([[segue destinationViewController] isKindOfClass:[FriendsViewController class]]) {
                FriendsViewController *viewController = (FriendsViewController*)[segue destinationViewController];
                viewController.friends = selectedFriends;
            }
        }
    }
    
    
}

- (BOOL) isFriend:(PFUser*)candidate {
    for (PFUser *friend in _friends) {
        if (candidate == friend) {
            return YES;
        }
    }
    return NO;
}


@end
