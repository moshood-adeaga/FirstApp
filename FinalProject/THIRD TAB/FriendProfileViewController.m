//
//  FriendProfileViewController.m
//  FinalProject
//
//  Created by Moshood Adeaga on 16/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "ImageCaching.h"
#import <QuartzCore/QuartzCore.h>

@interface FriendProfileViewController ()
@property(strong, nonatomic)NSUserDefaults *standardDefault;
@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.standardDefault = [NSUserDefaults standardUserDefaults];
    self.profileImageView.layer.cornerRadius = 50.0f;
    self.profileImageView.layer.borderWidth =5.0f;
    self.profileImageView.layer.borderColor =[UIColor blackColor].CGColor;
    self.profileImageView.clipsToBounds = YES;
    
    // As this View Controller shows the Profile of the current User being chatted to and the values stored in
    // the singleton is retrieved and viewed in this view controller.
    self.profileImageView.image = [[ImageCaching sharedInstance]getCachedImageForKey:[[ImageCaching sharedInstance]selectedImageLink]];
    
    self.userNameLabel.text = [[ImageCaching sharedInstance]selectedUsersName];
    [self.userNameLabel setFont:[UIFont fontWithName:[self.standardDefault objectForKey:@"settingsFont"] size:17.0]];
    
    NSString *usersFullname = [NSString stringWithFormat:@"%@ %@",[[ImageCaching sharedInstance]selectedFirstName],[[ImageCaching sharedInstance]selectedLastName]];
    self.fullNameLabel.text =usersFullname;
    [self.fullNameLabel setFont:[UIFont fontWithName:[self.standardDefault objectForKey:@"settingsFont"] size:17.0]];
    
    self.emailLabel.text = [[ImageCaching sharedInstance]selectedEmail];
    [self.emailLabel setFont:[UIFont fontWithName:[self.standardDefault objectForKey:@"settingsFont"] size:17.0]];
    
    self.phoneNumberLabel.text =[[ImageCaching sharedInstance]selectedPhoneNumber];
    [self.phoneNumberLabel setFont:[UIFont fontWithName:[self.standardDefault objectForKey:@"settingsFont"] size:17.0]];
    
}




@end
