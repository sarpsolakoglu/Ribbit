//
//  FriendsViewController.m
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 04/02/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "FriendsViewController.h"
#import "AddFriendsViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface FriendsViewController ()
@property (nonatomic,strong) PFRelation *friendsRelation;
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = ((AppDelegate*)[[UIApplication sharedApplication] delegate]);
    delegate.needRefresh = YES;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = ((AppDelegate*)[[UIApplication sharedApplication] delegate]);
    
    if (delegate.needRefresh) {
        delegate.needRefresh = NO;
        
        _friendsRelation = [[PFUser currentUser] relationForKey:@"friendsRelation"];
        PFQuery *query = [self.friendsRelation query];
        [query orderByAscending:@"username"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                _friends = [NSMutableArray arrayWithArray:objects];
                [self.tableView reloadData];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _friends.count;
}

- (IBAction) unwindToFriendsPage:(UIStoryboardSegue*)unwindSegue {
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell" forIndexPath:indexPath];
    
    cell.textLabel.text = ((PFUser*)_friends[indexPath.row]).username;
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PFRelation *friendRelation = [[PFUser currentUser] relationForKey:@"friendsRelation"];
        [friendRelation removeObject:_friends[indexPath.row]];
        [_friends removeObjectAtIndex:indexPath.row];
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addFriends"]) {
        UINavigationController *controller = [segue destinationViewController];
        AddFriendsViewController *addFriendsViewController = (AddFriendsViewController*)[controller topViewController];
        addFriendsViewController.friends = _friends;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
