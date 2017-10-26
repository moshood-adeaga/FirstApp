//
//  AppDelegate.m
//  FinalProject
//
//  Created by Moshood Adeaga on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "AppDelegate.h"
#import "usersAndChatViewController.h"
#import "CameraViewController.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "ImageCaching.h"
#import "EventsViewController.h"
#import "ChatView.h"
#import "ProfileViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import <Firebase.h>
#import "ChatView.h"
#import "usersAndChatViewController.h"



@interface AppDelegate ()
{
    NSUserDefaults *standard;
    int userID;
    NSString *userName;
    NSString *firstName;
    NSString *lastName;
    NSString *email;
    NSString *phoneNumber;
    NSString *userImageLink;
    NSString *userLastMessage;
    
}
@property (strong, nonatomic) NSDictionary *userData;
@property (strong, nonatomic) ImageCaching *dataTransfer;
@property (strong, nonatomic) NSDictionary *colourDict;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    standard = [NSUserDefaults standardUserDefaults];
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
    NSString *dataBasePath= @"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/login.php";

    if ([standard objectForKey:@"CurrentUserName"] != nil)
    {
        NSDictionary *databaseParameter= @{
                                           @"username":[standard objectForKey:@"CurrentUserName"],
                                           @"password":[standard objectForKey:@"CurrentUserPassword"]
                                           };
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [manager POST:dataBasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"HTTP Success: %@", responseObject);
                self.userData = responseObject;
                userName = [self.userData valueForKeyPath:@"user.username"];
                [standard setObject:userName forKey:@"userName"];
                
                firstName = [self.userData valueForKeyPath:@"user.firstname"];
                [standard setObject:firstName forKey:@"firstName"];
                
                lastName = [self.userData valueForKeyPath:@"user.lastname"];
                [standard setObject:lastName forKey:@"lastName"];
                
                email = [self.userData valueForKeyPath:@"user.email"];
                [standard setObject:email forKey:@"email"];
                
                phoneNumber = [self.userData valueForKeyPath:@"user.phone"];
                [standard setObject:phoneNumber forKey:@"phoneNumber"];
                
                userImageLink = [self.userData valueForKeyPath:@"user.image"];
                [standard setObject:userImageLink forKey:@"userImage"];
                
                userID =[[self.userData valueForKeyPath:@"user.id"]intValue];
                [standard setObject:[NSString stringWithFormat:@"%d",userID] forKey:@"userID"];
                
                userLastMessage =[self.userData valueForKeyPath:@"user.lastMessage"];
                [standard setObject:userLastMessage forKey:@"userMessage"];
                
                [standard synchronize];
                int myErrorCode =[[self.userData valueForKeyPath:@"error"] intValue];
                if(myErrorCode == 0)
                {
                    
                    
                    EventsViewController *eventsView = [[EventsViewController alloc]initWithNibName:@"EventsViewController" bundle:nil];
                    eventsView.title = @"EVENTS";
                    CameraViewController *mediaView = [[CameraViewController alloc]initWithNibName:@"CameraViewController" bundle:nil];
                    mediaView.title= @"CAMERA";
                    ChatView *chatsView = [[ChatView alloc]initWithNibName:@"ChatView" bundle:nil];
                    chatsView.title = @"CHATS";
                    ProfileViewController *profileView = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
                    profileView.title = @"PROFILE";
                   // [self.dataTransfer.userID setString:self.userIDTextField.text];
                    usersAndChatViewController *View = [[usersAndChatViewController alloc]initWithStyle:UITableViewStylePlain];
                    View.title =@"CHAT ROOM";
                    
                    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:eventsView];
                    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:mediaView];
                    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:chatsView];
                    UINavigationController *nav4 = [[UINavigationController alloc]initWithRootViewController:profileView];
                    UINavigationController *nav5 = [[UINavigationController alloc]initWithRootViewController:View];
                    
                    nav1.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[standard objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav1.navigationBar.barTintColor =[self.colourDict objectForKey:[standard objectForKey:@"settingsColor"]];
                    nav1.navigationBar.tintColor = [UIColor whiteColor];
                    nav2.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[standard objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav2.navigationBar.barTintColor =[self.colourDict objectForKey:[standard objectForKey:@"settingsColor"]];
                    nav2.navigationBar.tintColor = [UIColor whiteColor];
                    nav3.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[standard objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav3.navigationBar.barTintColor =[self.colourDict objectForKey:[standard objectForKey:@"settingsColor"]];
                    nav3.navigationBar.tintColor = [UIColor whiteColor];
                    nav4.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[standard objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav4.navigationBar.barTintColor =[self.colourDict objectForKey:[standard objectForKey:@"settingsColor"]];
                    nav4.navigationBar.tintColor = [UIColor whiteColor];
                    nav5.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[standard objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
                    nav5.navigationBar.barTintColor =[self.colourDict objectForKey:[standard objectForKey:@"settingsColor"]];
                    nav5.navigationBar.tintColor = [UIColor whiteColor];
                    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[standard objectForKey:@"settingsFont"] size:17.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
                    UITabBarController *tabBarController = [[UITabBarController alloc]init];
                    [tabBarController setViewControllers:@[nav1,nav2,nav5,nav4]];
                    tabBarController.tabBar.barTintColor =[self.colourDict objectForKey:[standard objectForKey:@"settingsColor"]];
                    tabBarController.tabBar.tintColor =[UIColor whiteColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
                    tabBarController.tabBar.unselectedItemTintColor = [UIColor whiteColor];
                    #endif
                    UIImage *eventsTabImage = [UIImage imageNamed:@"status.png"];
                    [[tabBarController.tabBar.items objectAtIndex:0] setImage:eventsTabImage];
                    UIImage *mediaTabImage = [UIImage imageNamed:@"Camera"];
                    [[tabBarController.tabBar.items objectAtIndex:1] setImage:mediaTabImage];
                    UIImage *chatsTabImage = [UIImage imageNamed:@"chat.png"];
                    [[tabBarController.tabBar.items objectAtIndex:2] setImage:chatsTabImage];
                    UIImage *profileTabImage = [UIImage imageNamed:@"person.png"];
                    [[tabBarController.tabBar.items objectAtIndex:3] setImage:profileTabImage];
                    
                    
                    self.window =[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]bounds]];;
                    [self.window setRootViewController:tabBarController];
                    [self.window makeKeyAndVisible];
                    
                    
                }
                NSLog(@"operation Success: %@", operation);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", [error localizedFailureReason]);
                UIAlertController *actionSheet3 = [UIAlertController alertControllerWithTitle:@"Error" message:@"Check Your Connection and Try Again " preferredStyle:UIAlertControllerStyleAlert];
                [actionSheet3 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }]];
                // Present action sheet.
                self.window =[[UIWindow alloc] initWithFrame:CGRectMake(54, 200, 100, 120)];
                [self.window setRootViewController:actionSheet3];
                [self.window makeKeyAndVisible];
            }];
        });
        
        
    }
    
    if ([standard objectForKey:@"CurrentUserName"] == nil)
    {
    RegisterViewController *loginView = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    loginView.title = @"LOG-IN";
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginView];
    nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[standard objectForKey:@"settingsFont"] size:17.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    
    self.window =[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    }
    //Firebase configuration//
    [FIRApp configure];
    
    
    
    /// NSUserDefaults Configuration for Setttings Bundle//
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"text_preference"])
    {
        [self registerDefaultsFromSettingsBundle];
    }
    
    return YES;
}

-(void)registerDefaultsFromSettingsBundle{
    NSString *settingsBundle =[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle)
    {
        NSLog(@"could not find settings.bundle");
        return;
    }
    NSDictionary *settings=[NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences)
    {
        NSString *key= [prefSpecification objectForKey:@"Key"];
        if(key)
        {
            [defaultToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
            NSLog(@"writing as default %@ to the key %@",[prefSpecification objectForKey:@"DefaultValue"],key);
        }
        
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultToRegister];
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"FinalProject"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
