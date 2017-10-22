//
//  RegisterViewController.m
//  FinalProject
//
//  Created by Moshood Adeaga on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//
#import "usersAndChatViewController.h"
#import "CameraViewController.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "UserDetail+CoreDataClass.h"
#import "CoreDataManager.h"
#import "ImageCaching.h"
#import "EventsViewController.h"
#import "ChatView.h"
#import "ProfileViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"


@interface RegisterViewController ()
{
    int userID;
    NSString *userName;
    NSString *firstName;
    NSString *lastName;
    NSString *email;
    NSString *phoneNumber;
    NSString *userImageLink;
    NSString *userLastMessage;
    
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
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[standardUserDefaults objectForKey:@"CurrentUserName"]);
    NSLog(@"%@",[standardUserDefaults objectForKey:@"CurrentUserPassword"]);
    
  
    
    //Setting up the Theme Colour Dictionary.
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
    //Changing the Colour Theme of the View.
    [self.navigationController.navigationBar setBarTintColor: [self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.segmentedControl setTintColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.passwordProperty setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.userNameProperty setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    [self.loginButtonproperty setBackgroundColor:[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]]];
    
    //Changing the FOnt of the View.
    [self.passwordProperty setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.userNameProperty setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    [self.loginButtonproperty setFont:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0]];
    
    //Initialising my Managers(Singletons).
    self.myCoreManager = [CoreDataManager sharedManager];
    self.dataTransfer =[ImageCaching sharedInstance];
    
    //Database Link to Connect the App to  its Login Database
    self.dataBasePath= @"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/login.php";
    
    self.passWordTextField.secureTextEntry = YES;
    
    //Setting up a gesture Recognizer.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    
}
- (IBAction)segmentControl:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        //Changing Between the Log-Out and Register View.
        LoginViewController *loginControl = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        loginControl.title = @"REGISTER";
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginControl];
        nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
        [self presentViewController:nav animated:YES completion:nil];
        
    }
}
- (IBAction)logInButton:(UIButton *)sender
{
    
    //Sending a Request to the database to Confirm the currently entered Password.
    NSDictionary *databaseParameter= @{@"username":self.userIDTextField.text,
                                       @"password":self.passWordTextField.text};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [manager POST:self.dataBasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"HTTP Success: %@", responseObject);
            self.userData = responseObject;
            
            //Saving the User Data in NSUserDefaults for Later Uses.
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
            
            userLastMessage =[self.userData valueForKeyPath:@"user.lastMessage"];
            [standardUserDefaults setObject:userLastMessage forKey:@"userMessage"];

            
            [standardUserDefaults synchronize];
            
            //Checking to see if theres any Error so that User can Log In to the App.
            int myErrorCode =[[self.userData valueForKeyPath:@"error"] intValue];
            if(myErrorCode == 0)
            {
                UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"USER DETAILS" message:@"Would You Like to Save Password for Quicker LOGIN" preferredStyle:UIAlertControllerStyleAlert];
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    EventsViewController *eventsView = [[EventsViewController alloc]initWithNibName:@"EventsViewController" bundle:nil];
                    eventsView.title = @"EVENTS";
                    CameraViewController *mediaView = [[CameraViewController alloc]initWithNibName:@"CameraViewController" bundle:nil];
                    mediaView.title= @"CAMERA";
                    ChatView *chatsView = [[ChatView alloc]initWithNibName:@"ChatView" bundle:nil];
                    chatsView.title = @"CHATS";
                    ProfileViewController *profileView = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
                    profileView.title = @"PROFILE";
                    [self.dataTransfer.userID setString:self.userIDTextField.text];
                    usersAndChatViewController *View = [[usersAndChatViewController alloc]initWithStyle:UITableViewStylePlain];
                    View.title =@"CHAT ROOM";
                    
                    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:eventsView];
                    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:mediaView];
                    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:chatsView];
                    UINavigationController *nav4 = [[UINavigationController alloc]initWithRootViewController:profileView];
                    UINavigationController *nav5 = [[UINavigationController alloc]initWithRootViewController:View];
                    
                    nav1.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav1.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav1.navigationBar.tintColor = [UIColor whiteColor];
                    nav2.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav2.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav2.navigationBar.tintColor = [UIColor whiteColor];
                    nav3.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav3.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav3.navigationBar.tintColor = [UIColor whiteColor];
                    nav4.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav4.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav4.navigationBar.tintColor = [UIColor whiteColor];
                    nav5.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav5.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav5.navigationBar.tintColor = [UIColor whiteColor];
                    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
                    UITabBarController *tabBarController = [[UITabBarController alloc]init];
                    [tabBarController setViewControllers:@[nav1,nav2,nav5,nav4]];
                    tabBarController.tabBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    tabBarController.tabBar.tintColor =[UIColor whiteColor];
                    tabBarController.tabBar.unselectedItemTintColor = [UIColor whiteColor];
                    UIImage *eventsTabImage = [UIImage imageNamed:@"status.png"];
                    [[tabBarController.tabBar.items objectAtIndex:0] setImage:eventsTabImage];
                    UIImage *mediaTabImage = [UIImage imageNamed:@"Camera"];
                    [[tabBarController.tabBar.items objectAtIndex:1] setImage:mediaTabImage];
                    UIImage *chatsTabImage = [UIImage imageNamed:@"chat.png"];
                    [[tabBarController.tabBar.items objectAtIndex:2] setImage:chatsTabImage];
                    UIImage *profileTabImage = [UIImage imageNamed:@"person.png"];
                    [[tabBarController.tabBar.items objectAtIndex:3] setImage:profileTabImage];
                    
                    
                    [self presentViewController:tabBarController animated:YES completion:nil];
                    
                    
                }]];
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    //Prompting users to save Password for future Quicker Log In.
                    [standardUserDefaults setObject:self.userIDTextField.text forKey:@"CurrentUserName"];
                    [standardUserDefaults setObject:self.passWordTextField.text forKey:@"CurrentUserPassword"];
                    [standardUserDefaults synchronize];
                    
                    EventsViewController *eventsView = [[EventsViewController alloc]initWithNibName:@"EventsViewController" bundle:nil];
                    eventsView.title = @"EVENTS";
                    CameraViewController *mediaView = [[CameraViewController alloc]initWithNibName:@"CameraViewController" bundle:nil];
                    mediaView.title= @"CAMERA";
                    ChatView *chatsView = [[ChatView alloc]initWithNibName:@"ChatView" bundle:nil];
                    chatsView.title = @"CHATS";
                    ProfileViewController *profileView = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
                    profileView.title = @"PROFILE";
                    [self.dataTransfer.userID setString:self.userIDTextField.text];
                    usersAndChatViewController *View = [[usersAndChatViewController alloc]initWithStyle:UITableViewStylePlain];
                    View.title =@"CHAT ROOM";
                    
                    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:eventsView];
                    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:mediaView];
                    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:chatsView];
                    UINavigationController *nav4 = [[UINavigationController alloc]initWithRootViewController:profileView];
                    UINavigationController *nav5 = [[UINavigationController alloc]initWithRootViewController:View];
                    
                    nav1.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav1.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav1.navigationBar.tintColor = [UIColor whiteColor];
                    nav2.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav2.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav2.navigationBar.tintColor = [UIColor whiteColor];
                    nav3.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav3.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav3.navigationBar.tintColor = [UIColor whiteColor];
                    nav4.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav4.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav4.navigationBar.tintColor = [UIColor whiteColor];
                    nav5.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav5.navigationBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    nav5.navigationBar.tintColor = [UIColor whiteColor];
                    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[self.defaults objectForKey:@"settingsFont"] size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
                    UITabBarController *tabBarController = [[UITabBarController alloc]init];
                    [tabBarController setViewControllers:@[nav1,nav2,nav5,nav4]];
                    tabBarController.tabBar.barTintColor =[self.colourDict objectForKey:[self.defaults objectForKey:@"settingsColor"]];
                    tabBarController.tabBar.tintColor =[UIColor whiteColor];
                    tabBarController.tabBar.unselectedItemTintColor = [UIColor whiteColor];
                    UIImage *eventsTabImage = [UIImage imageNamed:@"status.png"];
                    [[tabBarController.tabBar.items objectAtIndex:0] setImage:eventsTabImage];
                    UIImage *mediaTabImage = [UIImage imageNamed:@"Camera"];
                    [[tabBarController.tabBar.items objectAtIndex:1] setImage:mediaTabImage];
                    UIImage *chatsTabImage = [UIImage imageNamed:@"chat.png"];
                    [[tabBarController.tabBar.items objectAtIndex:2] setImage:chatsTabImage];
                    UIImage *profileTabImage = [UIImage imageNamed:@"person.png"];
                    [[tabBarController.tabBar.items objectAtIndex:3] setImage:profileTabImage];
                    
                    
                    [self presentViewController:tabBarController animated:YES completion:nil];
                    
                    
                    
                }]];
                // Present action sheet.
                [self presentViewController:actionSheet animated:YES completion:nil];
                
                
            }
            else {
                UIAlertController *actionSheet2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"Incorrect UserName/Password Try Again !!!" preferredStyle:UIAlertControllerStyleAlert];
                [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }]];
                // Present action sheet.
                [self presentViewController:actionSheet2 animated:YES completion:nil];
                
                [self.userIDTextField setText:nil];
                [self.passWordTextField setText:nil];
                
            }
            
            
            NSLog(@"operation Success: %@", operation);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedFailureReason]);
            UIAlertController *actionSheet3 = [UIAlertController alertControllerWithTitle:@"Error" message:@"Check Your Connection and Try Again " preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet3 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            // Present action sheet.
            [self presentViewController:actionSheet3 animated:YES completion:nil];
        }];
    });
    
    
    
}
// This would allow the keyboard to dismiss using the Tap Gesture recognizer.
-(void)dismissKeyboard
{
    [self.userIDTextField resignFirstResponder];
    [self.passWordTextField resignFirstResponder];
}


@end
