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
#import "SAMKeychainQuery.h"
#import "SAMKeychain.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "RNDecryptor.h"
#import "RNEncryptor.h"





@interface LoginViewController ()

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) CoreDataManager *myCoreManager;
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSString *dataBasePath;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //SETTING UP THEME//
 self.defaults = [NSUserDefaults standardUserDefaults];
    self.colourDict = @{
                        @"AQUA":[UIColor colorWithRed:0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0],
                        @"BLUE":[UIColor colorWithRed:0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0],
                        @"GREEN":[UIColor colorWithRed:0 green:204.0/255.0 blue:0 alpha:1.0],
                        @"RED":[UIColor colorWithRed:204.0/255.0 green:0 blue:0 alpha:1.0],
                        @"PURPLE":[UIColor colorWithRed:102.0/255.0 green:0 blue:204.0/255.0 alpha:1.0],
                        @"YELLOW":[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:0 alpha:1.0],
                        @"ORANGE":[UIColor colorWithRed:204.0/255.0 green:0 blue:102.0/255.0 alpha:1.0],
                        @"BLACK":[UIColor blackColor]
                        };
     [self.navigationController.navigationBar setBarTintColor: [self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.segmentedControl setTintColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self appear:YES];
  self.myCoreManager = [CoreDataManager sharedManager];
    [self.registrationLabel setHidden:!self.registrationLabel.hidden];
    self.passWordTextField.secureTextEntry =YES;
    self.dataBasePath = @"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/register.php";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
   
   ;
    
}
- (NSArray*) getAllLabels
{
    
    NSArray *labels = [[NSArray alloc] initWithObjects:self.confirm, self.registerButton, self.passLabel, self.userLabel, self.emailLabel, self.lastnameLabel,self.firstnameLabel,self.phoneLabel, nil];
    
    return labels;
}

- (void) appear:(BOOL)on
{
    for (UILabel *label in [self getAllLabels]) {
        //label.alpha = 0.0;
        label.backgroundColor=[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
        label.font =[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0f];

    }
    
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
        nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AmericanTypewriter-Condensed" size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
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
    
   // [SAMKeychain setPassword:self.passWordTextField.text forService:@"FinalProject" account:self.userNameTextField.text];
   // NSLog(@"READING VALUE %@", [SAMKeychain passwordForService:@"FinalProject" account:self.userNameTextField.text]);
//    [self setupUserDirectory];
//    [self storeUserDetail];
   
    //Saving the User//
//    [self.myCoreManager saveContext];
   
    
    
    [self.registrationLabel setEnabled:YES];
    [self.registrationLabel setText:@"REGISTRATION COMPLETE"];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(labelMethod:)
                                   userInfo:nil
                                    repeats:NO];
    //Saving to database
    
   NSDictionary *databaseParameter= @{@"username":self.userNameTextField.text,
                                        @"password":self.passWordTextField.text,
                                        @"email":self.emailTextField.text,
                                        @"firstname":self.firstNameTextField.text,
                                        @"lastname":self.lastNameTextField.text,
                                        @"phone":self.phoneNumberTextField.text
                                        };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:self.dataBasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON Successsss: %@", responseObject);
        NSLog(@"operation Successsss: %@", operation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error laaa: %@", error);
    }];
}
-(void)labelMethod:(NSTimer*)timer
{
    [self.registrationLabel setHidden:!self.registrationLabel.hidden];
}

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
