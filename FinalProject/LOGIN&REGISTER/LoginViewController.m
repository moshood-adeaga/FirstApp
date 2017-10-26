//
//  LoginViewController.m
//  FinalProject
//
//  Created by Moshood Adeaga on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "CoreDataManager.h"
#import "UserDetail+CoreDataClass.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>





@interface LoginViewController ()

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSString *dataBasePath;

@property (strong, nonatomic) CoreDataManager *myCoreManager;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.myCoreManager = [CoreDataManager sharedManager];
    self.passWordTextField.secureTextEntry =YES;
    
    //Setting Up Colour Dictionary.
    self.colourDict = @{
                        @"AQUA":[UIColor colorWithRed:0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0],
                        @"BLUE":[UIColor colorWithRed:0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0],
                        @"GREEN":[UIColor colorWithRed:0 green:204.0/255.0 blue:0 alpha:1.0],
                        @"RED":[UIColor colorWithRed:204.0/255.0 green:0 blue:0 alpha:1.0],
                        @"PURPLE":[UIColor colorWithRed:102.0/255.0 green:0 blue:204.0/255.0 alpha:1.0],
                        @"YELLOW":[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:0 alpha:1.0],
                        @"ORANGE":[UIColor colorWithRed:204.0/255.0 green:0 blue:102.0/255.0 alpha:1.0],
                        @"CYAN":[UIColor colorWithRed:75.0/255.0 green:186/255.0 blue:231.0/255.0 alpha:1.0],
                        @"BLACK":[UIColor blackColor]
                        };
    [self.navigationController.navigationBar setBarTintColor: [self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    //Change the Colour of all Labels in the View
    [self.segmentedControl setTintColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.registerButton setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.firstnameLabel setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.lastnameLabel setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.emailLabel setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.userLabel setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.phoneLabel setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.passLabel setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    
    //Change the Fonts of all TextField in the View
    [self.userNameTextField setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.firstNameTextField setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.lastNameTextField setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.emailTextField setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.phoneNumberTextField setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.passWordTextField setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    
    //Change the Fonts of all TextField in the View
    [self.userLabel setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.firstnameLabel setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.lastnameLabel setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.emailLabel setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.passLabel setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.phoneLabel setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.registerButton.titleLabel setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];

    
    //Database Path To connect to Registration Path.
    self.dataBasePath = @"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/register.php";
    
    //Adding Tap Gesture to Resign responders.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
}
- (IBAction)segmentControl:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        //Changing Between the Register and Log-Out View.
        RegisterViewController *registerControl =[[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
        registerControl.title = @"LOG-IN";
        self.segmentedControl.selected =NO;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:registerControl];
        nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
        nav.navigationBar.barStyle = UIBarStyleBlack;
        [self presentViewController:nav animated:YES completion:nil];
        //[self presentModalViewController:registerControl animated:YES];
    }
}
- (IBAction)registerButton:(UIButton *)sender {
    
    //Registering a New user to the system with the Details the Enter to textfields in the View.
    NSDictionary *databaseParameter= @{@"username":self.userNameTextField.text,
                                       @"password":self.passWordTextField.text,
                                       @"email":self.emailTextField.text,
                                       @"firstname":self.firstNameTextField.text,
                                       @"lastname":self.lastNameTextField.text,
                                       @"phone":self.phoneNumberTextField.text
                                       };
    
    //Making a Post Request to the Database Path for Registration, the Path is shown In the View Did Load Fuction Above.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:self.dataBasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *errorString = [responseObject valueForKey:@"message"];
        
        //Checking to see if user has been Created  and if there is any Error by using the Error message which is provided by the Server.
        if ([errorString isEqualToString:@"User created successfully"]) {
            UIAlertController *actionSheet2 = [UIAlertController alertControllerWithTitle:@"Success" message:@"Registration Completed" preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                RegisterViewController *registerControl =[[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
                registerControl.title = @"LOG-IN";
                self.segmentedControl.selected =NO;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:registerControl];
                nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                nav.navigationBar.barStyle = UIBarStyleBlack;
                [self presentViewController:nav animated:YES completion:nil];
            }]];
            // Present action sheet.
            [self presentViewController:actionSheet2 animated:YES completion:nil];
        } else if ([errorString isEqualToString:@"User already exist"])
        {
            UIAlertController *actionSheet2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"User Exists Already" preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            // Present action sheet.
            [self presentViewController:actionSheet2 animated:YES completion:nil];
        } else if ([errorString isEqualToString:@"Some error occurred"])
        {
            UIAlertController *actionSheet2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something Went Wrong, Check Details and Try Again" preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            // Present action sheet.
            [self presentViewController:actionSheet2 animated:YES completion:nil];
        }else if ([errorString isEqualToString:@"Required parameters are missing"])
        {
            UIAlertController *actionSheet2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"Check That You Have Entered All Your Details Correctly" preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            // Present action sheet.
            [self presentViewController:actionSheet2 animated:YES completion:nil];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}

///This Dismiss the Key Board When any where else is Tapped, using the Tap gesture recognizer.
-(void)dismissKeyboard {
    [self.userNameTextField resignFirstResponder];
    [self.passWordTextField resignFirstResponder];
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
    
}
//#pragma Setting Up USER
//- (void)setupUserDirectory {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documents = [paths objectAtIndex:0];
//    self.filePath = [documents stringByAppendingPathComponent:self.userNameTextField.text];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
//    if ([fileManager fileExistsAtPath:self.filePath]) {
//        NSLog(@"Directory already present.");
//
//    } else {
//        NSError *error = nil;
//        [fileManager createDirectoryAtPath:self.filePath withIntermediateDirectories:YES attributes:nil error:&error];
//
//        if (error) {
//            NSLog(@"Unable to create directory for user.");
//        }
//    }
//}
//-(void)storeUserDetail
//{
//    NSData *firstNameData = [self.firstNameTextField.text dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *userFirstName = @"userfirstName.securedFirstName";
//    NSData *encryptedFirstName = [RNEncryptor encryptData:firstNameData withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
//    [encryptedFirstName writeToFile:[self.filePath stringByAppendingPathComponent:userFirstName] atomically:YES];
//
//
//    NSData *lastNameData = [self.lastNameTextField.text dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *userLastName = @"userlastName.securedLastName";
//    NSData *encryptedLastName = [RNEncryptor encryptData:lastNameData withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
//    [encryptedLastName writeToFile:[self.filePath stringByAppendingPathComponent:userLastName] atomically:YES];
//
//
//    NSData *emailData = [self.emailTextField.text dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *userEmail = @"userEmail.securedEmail";
//    NSData *encryptedEmail = [RNEncryptor encryptData:emailData withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
//    [encryptedEmail writeToFile:[self.filePath stringByAppendingPathComponent:userEmail] atomically:YES];
//
//
//    NSData *phoneNumberData = [self.phoneNumberTextField.text dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *userPhoneNumber = @"userPhoneNumber.securedPhoneNumber";
//    NSData *encryptedPhoneNumber = [RNEncryptor encryptData:phoneNumberData withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
//    [encryptedPhoneNumber writeToFile:[self.filePath stringByAppendingPathComponent:userPhoneNumber] atomically:YES];
//
//}

@end
