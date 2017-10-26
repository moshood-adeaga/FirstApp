//
//  usersAndChatViewController.m
//  FinalProject
//
//  Created by Moshood Adeaga on 11/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "usersAndChatViewController.h"
#import "ChatView.h"
#import "ImageCaching.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import <QuartzCore/QuartzCore.h>

@interface usersAndChatViewController ()
{
    NSUserDefaults *standardDefaults;
}
@property (strong, nonatomic)  NSString *dataBasePath;
@property (strong, nonatomic) ImageCaching *imageCache;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation usersAndChatViewController
@dynamic refreshControl;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.activity= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activity setCenter:CGPointMake(self.view.center.x,self.view.center.y)];
    [self.tableView addSubview:self.activity];
    [self.activity startAnimating];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    self.imageCache = [ImageCaching sharedInstance];
    
    // Initializing the Refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [self.navigationController.navigationBar barTintColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getLatestUsers)forControlEvents:UIControlEventValueChanged];
    
    // A Link to the Apps User database which will give a response in Json contain the details of all Users on the database.
    self.dataBasePath = @"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/retrieveusers.php";
    
    [self initParse:self.dataBasePath];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self initParse:self.dataBasePath];
    [self.tableView reloadData];
}

#pragma Image Download
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error)
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}


#pragma mark - Table view Delegate & Datasource.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsInSection;
    rowsInSection = 0;
    if (section == 0)
        rowsInSection =1;
    if(section == 1)
        rowsInSection = [self.firstName count];
    return rowsInSection;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.section == 0)
    {
        [cell.textLabel setText:@"GLOBAL CHAT"];
        cell.textLabel.font = [UIFont fontWithName:@"American Typewriter Condense" size:17];
        [cell.detailTextLabel setText:@"Group Chat to talk to all Users"];
        cell.detailTextLabel.font =[UIFont fontWithName:@"American Typewriter Condense" size:14];
        [cell.imageView setImage:[UIImage imageNamed:@"globalChat"]];
        
        
    }else if (indexPath.section == 1){
        
        NSString *usersFullName = [NSString stringWithFormat:@"%@ %@",self.firstName[indexPath.row],self.lastName[indexPath.row]];
        cell.textLabel.text = usersFullName;
        cell.textLabel.font = [UIFont fontWithName:@"American Typewriter Condense" size:17];
        NSLog(@"My Array ---> %@",self.messageOfSelectedUser);
        
//        //Showing last message sent/reecieved by user.
//        if([self.messageOfSelectedUser count]>[indexPath row])
//        {
//        cell.detailTextLabel.text = [self.messageOfSelectedUser objectAtIndex:indexPath.row];
//        cell.detailTextLabel.font = [UIFont fontWithName:@"American Typewriter Condense" size:17];
//        }
        
        
        //cell.detailTextLabel.text;
        if([[ImageCaching sharedInstance] getCachedImageForKey:[self.imageLink objectAtIndex:indexPath.row]])
        {
            cell.imageView.image =[[ImageCaching sharedInstance] getCachedImageForKey:[self.imageLink objectAtIndex:indexPath.row]];
        }else
        {
            cell.imageView.image = [UIImage imageNamed:@"noimage"];
            // Downloading the Image Asynchronously
            NSURL *imageUrl = [NSURL URLWithString:[self.imageLink objectAtIndex:indexPath.row]];
            [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    // change the image in the cell
                   cell.imageView.image = image;
                    // cache the image for use later (when scrolling up)
                    [[ImageCaching sharedInstance]cacheImage:image forKey:[self.imageLink objectAtIndex:indexPath.row]];
                }
            }];
        }
        
    }
    cell.imageView.layer.cornerRadius = 40.0f;
    cell.imageView.clipsToBounds =YES;
    cell.imageView.autoresizingMask= UIViewAutoresizingNone;
    [cell layoutSubviews];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatView *chatsView = [[ChatView alloc]initWithNibName:@"ChatView" bundle:nil];
    
    chatsView.hidesBottomBarWhenPushed =YES;
    if(indexPath.section == 0)
    {
        chatsView.title = @" GLOBAL CHAT";
        [self.imageCache.selectedUsersName setString:[NSString stringWithFormat:@"%d",0]];
        
    }
    else if (indexPath.section == 1)
    {
        // The Detail of the which ever users selected for chatting is stored in a singleton so that it
        // can be used later.
        chatsView.title = [self.userName objectAtIndex:indexPath.row];
        [self.imageCache.selectedUsersName setString:[self.userName objectAtIndex:indexPath.row]];
        [self.imageCache.selectedFirstName setString:[self.firstName objectAtIndex:indexPath.row]];
        [self.imageCache.selectedLastName setString:[self.lastName objectAtIndex:indexPath.row]];
        [self.imageCache.selectedEmail setString:[self.emailOfSelectedUser objectAtIndex:indexPath.row]];
        [self.imageCache.selectedPhoneNumber setString:[self.phoneNumberOfSelectedUser objectAtIndex:indexPath.row]];
        [self.imageCache.selectedImageLink setString:[self.imageLink objectAtIndex:indexPath.row]];
        
    }
    // Push the view controller.
    [self.navigationController pushViewController:chatsView animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionHeader;
    
    if(section == 0)
        sectionHeader= @"GLOBAL CHAT";
    if(section == 1)
        sectionHeader= @"USERS";
    return sectionHeader;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(0, 0, 4200, 20);
    myLabel.font = [UIFont fontWithName:@"American Typewriter Condensed" size:14];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.backgroundColor =[self.navigationController.navigationBar barTintColor];
    myLabel.textColor = [UIColor whiteColor];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

#pragma mark DATA PARSING
-(void)initParse:(NSString*)link
{
    NSURL *URL = [NSURL URLWithString:link];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData  *_Nullable data, NSURLResponse * _Nullable response, NSError* _Nullable error) {
        
        
        if (error) {
            NSLog(@"Error!");
        } else if(data){
            [self parseJSONWithData:data];
        } else {
            NSLog(@"Big error!");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
        });
        
    }];
    
    [dataTask resume];
}

-(void)parseJSONWithData:(NSData*)jsonData
{
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    if (!error) {
        // The Detail of the all the user received from the server is parsed and stored in a respective for each
        // data received from the server.
        NSString *compareFirstName =[[NSUserDefaults standardUserDefaults]objectForKey:@"firstName"];
        NSMutableArray *userFirstName = [[root valueForKey:@"firstname"]mutableCopy];
        [userFirstName removeObject:compareFirstName];
        self.firstName =userFirstName;
        
        NSString *compareLastName =[[NSUserDefaults standardUserDefaults]objectForKey:@"lastName"];
        NSMutableArray *userLastName = [[root valueForKey:@"lastname"]mutableCopy];
        [userLastName removeObject:compareLastName];
        self.lastName =userLastName;
        
        NSString *compareUserName =[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
        NSMutableArray *users = [[root valueForKey:@"username"]mutableCopy];
        [users removeObject:compareUserName];
        self.userName =users;
        
        NSString *compareImage =[[NSUserDefaults standardUserDefaults]objectForKey:@"userImage"];
        NSMutableArray *userImageLink = [[root valueForKey:@"image"]mutableCopy];
        [userImageLink removeObject:compareImage];
        self.imageLink = userImageLink;
        
        NSString *compareID = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
        NSMutableArray *userID = [[root valueForKey:@"id"]mutableCopy];
        [userID removeObject:compareID];
        self.idOfSelectedUser =userID;
        
        NSString *comparePhoneNumber = [[NSUserDefaults standardUserDefaults]objectForKey:@"phoneNumber"];
        NSMutableArray *userPhoneNumber = [[root valueForKey:@"phone"]mutableCopy];
        [userPhoneNumber removeObject:comparePhoneNumber];
        self.phoneNumberOfSelectedUser = userPhoneNumber;
        
       
        NSString *comparedEmail = [[NSUserDefaults standardUserDefaults]objectForKey:@"email"];
        NSMutableArray *userEmail = [[root valueForKey:@"email"]mutableCopy];
        [userEmail removeObject:comparedEmail];
        self.emailOfSelectedUser =userEmail;
        
        
        NSString *comparedMessage = [[NSUserDefaults standardUserDefaults]objectForKey:@"userMessage"];
        NSMutableArray *userMessage = [[root valueForKey:@"lastMessage"]mutableCopy];
        [userMessage removeObject:comparedMessage];
        self.messageOfSelectedUser = userMessage;
        
        
        
        
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activity stopAnimating];
    });
}
- (void)getLatestUsers
{
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

@end
