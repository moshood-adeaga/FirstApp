//
//  LoginViewController.m
//  FinalProject
//
//  Created by TheAppExperts on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "CoreDataManager.h"
#import "UserDetail+CoreDataClass.h"
#import <SAMKeychainQuery.h>
#import <SAMKeychain.h>





@interface LoginViewController ()
@property (strong, nonatomic) CoreDataManager *myCoreManager;



@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myCoreManager = [CoreDataManager sharedManager];
    [self.registrationLabel setHidden:!self.registrationLabel.hidden];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)segmentControl:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        RegisterViewController *registerControl =[[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
        registerControl.title = @"LOG-IN";
        self.segmentedControl.selected =NO;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:registerControl];
        nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Arial" size:13.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
        nav.navigationBar.barStyle = UIBarStyleBlack;
         [self presentViewController:nav animated:YES completion:nil];
        //[self presentModalViewController:registerControl animated:YES];
    }
}
- (IBAction)registerButton:(UIButton *)sender {
//    //Adding Users to CoreData//
//    UserDetail *newUser = [[UserDetail alloc] initWithContext:[[self.myCoreManager persistentContainer] viewContext]];
//    [newUser setFirstName:self.firstNameTextField.text];
//    [newUser setLastName:self.lastNameTextField.text];
//    [newUser setEmail:self.emailTextField.text];
//    [newUser setPassword:self.passWordTextField.text];
    
    [SAMKeychain setPassword:self.passWordTextField.text forService:@"FinalProject" account:self.emailTextField.text];
    NSLog(@"READING VALUE %@", [SAMKeychain passwordForService:@"FinalProject" account:self.emailTextField.text]);
   
    //Saving the User//
//    [self.myCoreManager saveContext];
    
    self.firstNameTextField.text = nil;
    self.lastNameTextField.text = nil;
    self.emailTextField.text = nil;
    self.passWordTextField.text = nil;
    
    
    [self.registrationLabel setEnabled:YES];
    [self.registrationLabel setText:@"REGISTRATION COMPLETE"];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(labelMethod:)
                                   userInfo:nil
                                    repeats:NO];
    
}
-(void)labelMethod:(NSTimer*)timer
{
    [self.registrationLabel setHidden:!self.registrationLabel.hidden];
}
@end
