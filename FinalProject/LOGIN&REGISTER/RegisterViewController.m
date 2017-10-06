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
#import "EventsViewController.h"
#import "MediaController.h"
#import <SAMKeychainQuery.h>
#import <SAMKeychain.h>

@interface RegisterViewController ()
@property (strong, nonatomic) CoreDataManager *myCoreManager;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myCoreManager = [CoreDataManager sharedManager];
    
    
}




- (IBAction)segmentControl:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        LoginViewController *loginControl = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        loginControl.title = @"REGISTER";
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginControl];
        nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Arial" size:13.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
        nav.navigationBar.barStyle = UIBarStyleBlack;
        [self presentViewController:nav animated:YES completion:nil];
    }
}
- (IBAction)logInButton:(UIButton *)sender
{
    NSLog(@"Result:%@",[SAMKeychain passwordForService:@"FinalProject" account:self.userIDTextField.text]);

    if([[SAMKeychain passwordForService:@"FinalProject" account:self.userIDTextField.text] isEqualToString:self.passWordTextField.text])
    {
        NSLog(@"Result:%@",[SAMKeychain passwordForService:@"FinalProject" account:self.userIDTextField.text]);
    EventsViewController *eventsView = [[EventsViewController alloc]initWithNibName:@"EventsViewController" bundle:nil];
    eventsView.title = @"EVENTS";
    MediaController *mediaView = [[MediaController alloc]initWithNibName:@"MediaController" bundle:nil];
    mediaView.title= @"Camera";
    
    UINavigationController *nav1 =  [[UINavigationController alloc]initWithRootViewController:eventsView];
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:mediaView];
    
    nav1.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Arial" size:13.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    nav1.navigationBar.barStyle = UIBarStyleBlack;
    
    UITabBarController *tabBarController = [[UITabBarController alloc]init];
    [tabBarController setViewControllers:@[nav1,nav2]];
    
    UIImage *eventsTabImage = [UIImage imageNamed:@"status.png"];
    [[tabBarController.tabBar.items objectAtIndex:0] setImage:eventsTabImage];
    
    UIImage *mediaTabImage = [UIImage imageNamed:@"myCamera.png"];
    [[tabBarController.tabBar.items objectAtIndex:1] setImage :mediaTabImage];
    
     [self presentViewController:tabBarController animated:YES completion:nil];
    }
        
    
}
@end