//
//  ProfileViewController.h
//  FinalProject
//
//  Created by Moshood Adeaga on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UIButton *logOutButton;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageViewer;
- (IBAction)logOutButton:(UIButton *)sender;
- (IBAction)profileImagePicker:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *editProfile;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
- (IBAction)profileEditButton:(id)sender;
- (IBAction)bookmarkPageButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *logoutProp;
@property (weak, nonatomic) IBOutlet UIButton *editProp;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkProp;
@property (weak, nonatomic) IBOutlet UILabel *phoneProp;
@property (weak, nonatomic) IBOutlet UILabel *emailProp;
@property (weak, nonatomic) IBOutlet UILabel *lastnameProp;
@property (weak, nonatomic) IBOutlet UILabel *firstnameProp;
@property (weak, nonatomic) IBOutlet UILabel *userNameProp;




@end
