//
//  ProfileViewController.h
//  FinalProject
//
//  Created by TheAppExperts on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *firstName;
@property (strong, nonatomic) IBOutlet UILabel *lastName;
@property (strong, nonatomic) IBOutlet UILabel *sexLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UIButton *logOutButton;
- (IBAction)logOutButton:(UIButton *)sender;

@end
