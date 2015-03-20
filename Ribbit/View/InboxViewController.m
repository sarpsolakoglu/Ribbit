//
//  InboxViewController.m
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 03/02/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "InboxViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface InboxViewController ()
@property (nonatomic,strong) NSArray *messages;
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;
@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moviePlayer = [MPMoviePlayerController new];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    
    if (!currentUser) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    } else {
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
        [query orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.messages = objects;
                [self.tableView reloadData];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
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
    return _messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inboxCell" forIndexPath:indexPath];
    
    PFObject *message = [_messages objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [message objectForKey:@"senderName"];
    
    NSString *fileType = [message objectForKey:@"fileType"];
    
    if ([fileType isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    } else if ([fileType isEqualToString:@"video"]){
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PFObject *message = _messages[indexPath.row];
    NSString *fileType = [message objectForKey:@"fileType"];
    
    NSMutableArray *recipients = [NSMutableArray arrayWithArray:[message objectForKey:@"recipientIds"]];
    
    if (recipients.count == 1) {
        [message deleteInBackground];
    } else {
        [recipients removeObject:[[PFUser currentUser] objectId]];
        [message setObject:recipients forKey:@"recipientIds"];
        
        [message saveInBackground];
    }
    
    
    if ([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:message];
    } else {
        PFFile *videoFile = [message objectForKey:@"file"];
        _moviePlayer.contentURL = [NSURL URLWithString:videoFile.url];
        [_moviePlayer prepareToPlay];
        [_moviePlayer requestThumbnailImagesAtTimes:@[@0.f] timeOption:MPMovieTimeOptionNearestKeyFrame];
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.identifier isEqualToString:@"showImage"]) {
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
        if ([[segue destinationViewController] isKindOfClass:[ImageViewController class]]) {
            ((ImageViewController*)[segue destinationViewController]).message = (PFObject*)sender;
        }
    }
}


- (IBAction)logOut:(id)sender {
    
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).needRefresh = YES;
    
    if ([PFUser currentUser]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PFUser logOut];
            [self performSegueWithIdentifier:@"showLogin" sender:self];
        });
    }
}
@end
