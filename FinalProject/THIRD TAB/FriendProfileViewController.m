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

@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profileImageView.layer.cornerRadius = 50.0f;
    self.profileImageView.layer.borderWidth =5.0f;
    self.profileImageView.layer.borderColor =[UIColor blackColor].CGColor;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.image = [[ImageCaching sharedInstance]getCachedImageForKey:[[ImageCaching sharedInstance]selectedImageLink]];
    
    self.userNameLabel.text = [[ImageCaching sharedInstance]selectedUsersName];
    
    NSString *usersFullname = [NSString stringWithFormat:@"%@ %@",[[ImageCaching sharedInstance]selectedFirstName],[[ImageCaching sharedInstance]selectedLastName]];
    
    self.fullNameLabel.text =usersFullname;
    
    self.emailLabel.text = [[ImageCaching sharedInstance]selectedEmail];
    
    self.phoneNumberLabel.text =[[ImageCaching sharedInstance]selectedPhoneNumber];
    
}




@end
