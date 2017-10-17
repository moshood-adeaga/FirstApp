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
     
    NSString *favouriteDatabase = [NSString stringWithFormat:@"%@%@database",[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"phoneNumber"]];
    self.ref = [[[FIRDatabase database] reference] child:favouriteDatabase];
    [self observeMessages];
    [self.tableView reloadData];
}
-(void)observeMessages
{
    //FIRDatabaseQuery *recentPostsQuery = [[self.ref child:@"posts"] queryLimitedToFirst:10];
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
    cell.detailTextLabel.text = [self.descriptionArray objectAtIndex:indexPath.row];
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
