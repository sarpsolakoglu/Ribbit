//
//  CameraViewController.m
//  Ribbit
//
//  Created by Sarp Ogulcan Solakoglu on 05/02/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Parse/Parse.h>

@interface CameraViewController ()
@property (nonatomic,strong) UIImagePickerController *pickerController;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) NSString *videoFilePath;
@property (nonatomic,strong) PFRelation *friendsRelation;
@property (nonatomic,strong) NSArray *friends;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelection = YES;
    
    self.pickerController = [UIImagePickerController new];
    _pickerController.delegate = self;
    _pickerController.allowsEditing = NO;
    _pickerController.videoMaximumDuration = 10;
    _pickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
         _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        _pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
   
    _pickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:_pickerController.sourceType];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_image && !(self.videoFilePath.length > 0)) {
        [self presentViewController:_pickerController animated:NO completion:nil];
    } else {
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
   
}

-(void)viewWillDisappear:(BOOL)animated {
    self.image = nil;
    self.videoFilePath = nil;
    NSArray *selectedIndexes = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *index in selectedIndexes) {
        [self.tableView deselectRowAtIndexPath:index animated:NO];
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
    return _friends.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"recipientsCell" forIndexPath:indexPath];
    
    PFUser *friend = (PFUser*)_friends[indexPath.row];
    cell.textLabel.text = friend.username;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.tabBarController.selectedIndex = 0;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)CFBridgingRelease(kUTTypeImage)]) {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (_pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);
        }
    } else if([mediaType isEqualToString:(NSString*)CFBridgingRelease(kUTTypeMovie)]) {
        NSURL *imagePickerURL = [info objectForKey:UIImagePickerControllerMediaURL];
        self.videoFilePath = [imagePickerURL path];
        if (_pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(_videoFilePath, nil, nil, nil);
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendToRecipients:(id)sender {
    
    if (!self.image && self.videoFilePath.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Take picture or video" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [self presentViewController:self.pickerController animated:NO completion:nil];
    } else {
        [self sendMessage];
    }
    
}

- (IBAction)cancelAction:(id)sender {
    self.tabBarController.selectedIndex = 0;
}

- (void) sendMessage {
    
    NSArray *selectedIndexes = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *recipients = [NSMutableArray new];
    for (NSIndexPath *index in selectedIndexes) {
        PFUser *recipient = _friends[index.row];
        [recipients addObject:[recipient objectId]];
    }
    
    if (recipients.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Select at least one recipient to send." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    if (_image) {
        UIImage *newImage = [self resizeImage:_image toWidth:320.0f andHeight:480.0f];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
    } else {
        fileData = [NSData dataWithContentsOfFile:_videoFilePath],
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please send your message again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            
            
            
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:recipients forKey:@"recipientIds"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please send your message again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                } else {
                    self.tabBarController.selectedIndex = 0;
                }
            }];
        }
    }];
    
}

- (UIImage*) resizeImage:(UIImage*) image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:rect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}
@end
