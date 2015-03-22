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
#import "InboxViewModel.h"
#import "InboxCellViewModel.h"
#import "CETableViewBindingHelper.h"

@interface InboxViewController ()

@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic,strong) InboxViewModel *viewModel;
@property (strong, nonatomic) CETableViewBindingHelper *bindingHelper;

@end

@implementation InboxViewController

-(instancetype)initWithViewModel:(id<ViewModel>)viewModel {
    if (self = [super init]) {
        _viewModel = viewModel;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _viewModel = [InboxViewModel new];
    }
    return self;
}

- (void) bindViewModel {
    //bind the tableview to it's tableviewcell model. tableviewcell models are stored as an array inside the viewmodel of this
    //view controller
    
    self.bindingHelper = [CETableViewBindingHelper bindingHelperForTableView:self.tableView
                                                                sourceSignal:RACObserve(self.viewModel, messages) selectionCommand:self.viewModel.cellSelected reuseIdentifier:@"inboxCell"
                                                                    templateCell:nil];
    self.bindingHelper.delegate = self;
    
    //Command execution error
    [[self.viewModel.getInboxCommand.errors
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSError *error) {
         NSString *errorString = [error userInfo][@"error"];
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:errorString delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
         [alertView show];
     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewModel];
    self.moviePlayer = [MPMoviePlayerController new];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    //UI Related Navigation
    if (!currentUser) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    } else {
        [self.viewModel.getInboxCommand execute:nil];
    }
}

/*
 *Table view related stuff is handled by the binding done with CETableViewBindingHelper
 *
 */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    InboxCellViewModel *cellViewModel = self.viewModel.messages[indexPath.row];
    PFObject *message = cellViewModel.message;
    NSString *fileType = [message objectForKey:@"fileType"];
  
    //NON-UI related stuff done in the ViewModel and with the help of CEBTableViewBindingHelper
    //But I could not figure out what to do with the UI related stuff so I didn't move them.
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

//Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showImage"]) {
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
        if ([[segue destinationViewController] isKindOfClass:[ImageViewController class]]) {
            ((ImageViewController*)[segue destinationViewController]).message = (PFObject*)sender;
        }
    }
}

//UI Related
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
