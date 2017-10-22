//
//  EventsUnderConsiderationController.m
//  FinalProject
//
//  Created by Moshood Adeaga on 16/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "EventsUnderConsiderationController.h"
#import <FirebaseDatabase/FirebaseDatabase.h>
#import "ImageCaching.h"

@interface EventsUnderConsiderationController ()
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *descriptionArray;
@end

@implementation EventsUnderConsiderationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.titleArray = [NSMutableArray array];
    self.descriptionArray = [NSMutableArray array];
    self.imageArray = [NSMutableArray array];
    
    // As the Bookmarked event is stored on a databse and its going to be retrieved from this view controller,
    // and as the reference was created using  a identifier unique to the user , the reference for the datbase
    // is then recreated.
    NSString *favouriteDatabase = [NSString stringWithFormat:@"%@%@database",[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"phoneNumber"]];
    self.ref = [[[FIRDatabase database] reference] child:favouriteDatabase];
    
    // Calling the Function the retrieve the stored data from the server.
    [self observeMessages];
    [self.tableView reloadData];
}

// This Function will retrieve from the events bookmark database of the current user,
// the data is retreived from them database created from the events detail view controller
// through the events tab(first Tab).
-(void)observeMessages
{
    [_ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        if(!snapshot.exists){return;}
        NSLog(@"%@",snapshot.value);
        [self.titleArray addObject:snapshot.value[@"Title"]];
        [self.imageArray addObject:snapshot.value[@"ImageLink"]];
        [self.descriptionArray addObject:snapshot.value[@"Description"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
        });
        
    }];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.tableView reloadData];
}
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titleArray count];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"EVENTS AM THINKING ABOUT";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"American Typewriter Condense" size:17];
    cell.detailTextLabel.text = [self.descriptionArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.font = [UIFont fontWithName:@"American Typewriter Condense" size:5];

    if([[ImageCaching sharedInstance] getCachedImageForKey:[self.imageArray objectAtIndex:indexPath.row]])
    {
        cell.imageView.image =[[ImageCaching sharedInstance] getCachedImageForKey:[self.imageArray objectAtIndex:indexPath.row]];
    }else
    {
        cell.imageView.image = [UIImage imageNamed:@"noimage"];
        // download the image asynchronously
        if(![[self.imageArray objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        {
            NSURL *imageUrl = [NSURL URLWithString:[self.imageArray objectAtIndex:indexPath.row]];
            [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    // change the image in the cell
                    cell.imageView.image = image;
                    // cache the image for use later (when scrolling up)
                    [[ImageCaching sharedInstance]cacheImage:image forKey:[self.imageArray objectAtIndex:indexPath.row]];
                }
            }];
        }
    }
    return cell;
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
@end
