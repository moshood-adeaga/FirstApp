//
//  LoginViewController.h
//  FinalProject
//
//  Created by TheAppExperts on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
- (IBAction)segmentControl:(id)sender;
@property (strong, nonatomic) IBOutlet UISegmentedControl * segmentedControl;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;

@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passWordTextField;
- (IBAction)registerButton:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *registrationLabel;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@end
