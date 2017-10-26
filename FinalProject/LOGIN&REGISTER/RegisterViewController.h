//
//  RegisterViewController.h
//  FinalProject
//
//  Created by Moshood Adeaga on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentControl:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *userIDTextField;
@property (strong, nonatomic) IBOutlet UITextField *passWordTextField;
- (IBAction)logInButton:(UIButton *)sender;
@property (strong, nonatomic) NSDictionary *userData;
@property (weak, nonatomic) IBOutlet UIButton *loginButtonproperty;
@property (weak, nonatomic) IBOutlet UILabel *passwordProperty;
@property (weak, nonatomic) IBOutlet UILabel *userNameProperty;

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSDictionary *colourDict;
@property (weak, nonatomic) IBOutlet UILabel *letschat;
@property (weak, nonatomic) IBOutlet UIImageView *letschatImageView;

@end
