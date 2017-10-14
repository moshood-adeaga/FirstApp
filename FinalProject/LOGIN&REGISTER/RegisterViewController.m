//
//  RegisterViewController.m
//  FinalProject
//
//  Created by TheAppExperts on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "UserDetail+CoreDataClass.h"
#import "CoreDataManager.h"
#import "ImageCaching.h"
#import "EventsViewController.h"
#import "MediaController.h"
#import "ChatView.h"
#import "ProfileViewController.h"
#import "SAMKeychainQuery.h"
#import "SAMKeychain.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "ViewController.h"

@interface RegisterViewController ()
    {
        int userID;
        NSString *userName;
        NSString *firstName;
        NSString *lastName;
        NSString *email;
        NSString *phoneNumber;
        NSString *userImageLink;
        
        NSUserDefaults *standardUserDefaults;
    }
@property (strong, nonatomic) CoreDataManager *myCoreManager;
@property (strong, nonatomic) ImageCaching *dataTransfer;
@property (copy, nonatomic) NSString *dataBasePath;


@end

@implementation RegisterViewController

- (void)viewDidLoad
{
[super viewDidLoad];
self.myCoreManager = [CoreDataManager sharedManager];
self.dataTransfer =[ImageCaching sharedInstance];
self.dataBasePath= @"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/login.php";
standardUserDefaults = [NSUserDefaults standardUserDefaults];
self.passWordTextField.secureTextEntry = YES;
UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
[self.view addGestureRecognizer:tap];
    
    
}
- (IBAction)segmentControl:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        LoginViewController *loginControl = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        loginControl.title = @"REGISTER";
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginControl];
        nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Bradley Hand" size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
        nav.navigationBar.barStyle = UIBarStyleBlack;
        [self presentViewController:nav animated:YES completion:nil];
        
    }
}
- (IBAction)logInButton:(UIButton *)sender
{
    
    //NSLog(@"Result:%@",[SAMKeychain passwordForService:@"FinalProject" account:self.userIDTextField.text]);
    NSDictionary *databaseParameter= @{@"username":self.userIDTextField.text,
                                       @"password":self.passWordTextField.text};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    dispatch_async(dispatch_get_main_queue(), ^{

    [manager POST:self.dataBasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"HTTP Success: %@", responseObject);
        self.userData = responseObject;
        userName = [self.userData valueForKeyPath:@"user.username"];
        [standardUserDefaults setObject:userName forKey:@"userName"];
        
        firstName = [self.userData valueForKeyPath:@"user.firstname"];
        [standardUserDefaults setObject:firstName forKey:@"firstName"];
        
        lastName = [self.userData valueForKeyPath:@"user.lastname"];
        [standardUserDefaults setObject:lastName forKey:@"lastName"];
        
        email = [self.userData valueForKeyPath:@"user.email"];
        [standardUserDefaults setObject:email forKey:@"email"];
        
        phoneNumber = [self.userData valueForKeyPath:@"user.phone"];
        [standardUserDefaults setObject:phoneNumber forKey:@"phoneNumber"];
        
        userImageLink = [self.userData valueForKeyPath:@"user.image"];
        [standardUserDefaults setObject:userImageLink forKey:@"userImage"];
        
        userID =[[self.userData valueForKeyPath:@"user.id"]intValue];
        [standardUserDefaults setObject:[NSString stringWithFormat:@"%d",userID] forKey:@"userID"];
        
        [standardUserDefaults synchronize];
        int myErrorCode =[[self.userData valueForKeyPath:@"error"] intValue];
        if(myErrorCode == 0)
        {
            //NSLog(@"Result:%@",[SAMKeychain passwordForService:@"FinalProject" account:self.userIDTextField.text]);
            
            EventsViewController *eventsView = [[EventsViewController alloc]initWithNibName:@"EventsViewController" bundle:nil];
            eventsView.title = @"EVENTS";
            MediaController *mediaView = [[MediaController alloc]initWithNibName:@"MediaController" bundle:nil];
            mediaView.title= @"CAMERA";
            ChatView *chatsView = [[ChatView alloc]initWithNibName:@"ChatView" bundle:nil];
            chatsView.title = @"CHATS";
            ProfileViewController *profileView = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
            profileView.title = @"PROFILE";
            [self.dataTransfer.userID setString:self.userIDTextField.text];
            ViewController *View = [[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
            View.title =@"CHAT ROOM";
            
            UINavigationController *nav1 =  [[UINavigationController alloc]initWithRootViewController:eventsView];
            UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:mediaView];
            UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:chatsView];
            UINavigationController *nav4 = [[UINavigationController alloc]initWithRootViewController:profileView];
            UINavigationController *nav5 = [[UINavigationController alloc]initWithRootViewController:View];

            nav1.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Bradley Hand" size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
            nav1.navigationBar.barStyle = UIBarStyleBlack;
            nav2.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Bradley Hand" size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
            nav2.navigationBar.barStyle = UIBarStyleBlack;
            nav3.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Bradley Hand" size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
            nav3.navigationBar.barStyle = UIBarStyleBlack;
            nav4.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Bradley Hand" size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
            nav4.navigationBar.barStyle = UIBarStyleBlack;
            nav5.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Bradley Hand" size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
            nav5.navigationBar.barStyle = UIBarStyleBlack;
            
            UITabBarController *tabBarController = [[UITabBarController alloc]init];
            [tabBarController setViewControllers:@[nav1,nav2,nav5,nav4]];
            
            UIImage *eventsTabImage = [UIImage imageNamed:@"status.png"];
            [[tabBarController.tabBar.items objectAtIndex:0] setImage:eventsTabImage];
            UIImage *mediaTabImage = [UIImage imageNamed:@"myCamera.png"];
            [[tabBarController.tabBar.items objectAtIndex:1] setImage :mediaTabImage];
            UIImage *chatsTabImage = [UIImage imageNamed:@"chat.png"];
            [[tabBarController.tabBar.items objectAtIndex:2] setImage :chatsTabImage];
            UIImage *profileTabImage = [UIImage imageNamed:@"person.png"];
            [[tabBarController.tabBar.items objectAtIndex:3] setImage :profileTabImage];
            
            [self presentViewController:tabBarController animated:YES completion:nil];
        }
        else {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Error" message:@"Incorrect UserName/Password Try Again !!!" preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            // Present action sheet.
            [self presentViewController:actionSheet animated:YES completion:nil];
            
            [self.userIDTextField setText:nil];
            [self.passWordTextField setText:nil];
            
        }
        
        
        NSLog(@"operation Success: %@", operation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
         });
    
//    if([[SAMKeychain passwordForService:@"FinalProject" account:self.userIDTextField.text] isEqualToString:self.passWordTextField.text])
    
    
    
}
-(void)dismissKeyboard {
    [self.userIDTextField resignFirstResponder];
    [self.passWordTextField resignFirstResponder];
    
    
}
@end
