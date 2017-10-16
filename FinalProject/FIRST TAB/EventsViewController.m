//
//  EventsViewController.m
//  FinalProject
//
//  Created by Shegz on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "EventsViewController.h"
#import "ImageCaching.h"
#import "mapViewController.h"
#import "EventsCell.h"
#import "eventDetailController.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>



@interface EventsViewController ()
{
    NSString * imageUrl;
    UIImage *image;
    NSUserDefaults *standardUserDefaults;
}
@property (strong,nonatomic) ImageCaching *imageCache;
@end

@implementation EventsViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.imageCache = [ImageCaching sharedInstance];
    image =[[UIImage alloc]init];
    self.collectionView.delegate = self;
    self.collectionView.dataSource =self;
    self.collectionView.allowsSelection=YES;
    [self.collectionView setExclusiveTouch:YES];
    
    //Setting Appearance.
    self.collectionView.backgroundColor =[UIColor blackColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Arial" size:13.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.tabBarController.tabBar setBarTintColor:[UIColor blackColor]];
    
    // Register Nib classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"EventsCell" bundle:nil] forCellWithReuseIdentifier:[EventsCell cell_ID]];
    
    //Creating A Search Bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, 415, 44)];
    self.searchBar.placeholder = @"Enter Topic for Events";
    self.searchBar.delegate =self;
    self.searchBar.barStyle = UIBarStyleBlack;
     [self.collectionView addSubview:self.searchBar];
    
    //Adding constraint to SearchBar
    self.searchBar.translatesAutoresizingMaskIntoConstraints=NO;
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeLeftMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeftMargin multiplier:0.4 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeRightMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRightMargin multiplier:1.019 constant:0];
    
   
    [self.view addConstraints:@[leftConstraint,rightConstraint]];
   
    [self.collectionView reloadData];
    
    //Adding Gesture Recognizer to resign firstResponder//
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
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
-(void)viewWillAppear:(BOOL)animated
{
   
    [super viewWillAppear:YES];
    [self.collectionView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchString = self.searchBar.text;
    NSString *eventLink = [NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/events/search/?q=%@&token=XU4CJHOK4JHP4VB3XY4B",searchString];
    [self initParse:eventLink];
    [self.searchBar resignFirstResponder];
}



#pragma mark <UICollectionViewDataSource>&<UICollectionViewDelegate>



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.nameOfEvent count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EventsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[EventsCell cell_ID] forIndexPath:indexPath];
   
    if([[ImageCaching sharedInstance] getCachedImageForKey:[self.picOfEvent objectAtIndex:indexPath.row]])
    {
    [cell fillEvent:[self.nameOfEvent objectAtIndex:indexPath.row] eventImage:[[ImageCaching sharedInstance] getCachedImageForKey:[self.picOfEvent objectAtIndex:indexPath.row]]];
    }else
    {
        [cell fillEvent:[self.nameOfEvent objectAtIndex:indexPath.row] eventImage:[UIImage imageNamed:@"noimage"]];
        // download the image asynchronously
        if(![[self.picOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        {
        NSURL *imageUrl = [NSURL URLWithString:[self.picOfEvent objectAtIndex:indexPath.row]];
        [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
               [cell fillEvent:[self.nameOfEvent objectAtIndex:indexPath.row] eventImage:image];
                // cache the image for use later (when scrolling up)
                [[ImageCaching sharedInstance]cacheImage:image forKey:[self.picOfEvent objectAtIndex:indexPath.row]];
            }
        }];
        }
    }
    CGRect btnRect = CGRectMake(352,263, 45, 29);
    UIButton *cellBtn = [[UIButton alloc] initWithFrame:btnRect];
    [cellBtn setBackgroundImage:[UIImage imageNamed:@"myshare"] forState:UIControlStateNormal];
    cellBtn.layer.cornerRadius = 5.0f;
    cellBtn.clipsToBounds =YES;
    [cellBtn setTitle:@"" forState:UIControlStateNormal];
    [cell.contentView addSubview:cellBtn];
    [cellBtn addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cellBtn setTag:indexPath.row];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer= [[UILongPressGestureRecognizer alloc]
                                                               initWithTarget:self action:@selector(handleLongPress:)];
    longPressGestureRecognizer.delegate = self;
    longPressGestureRecognizer.delaysTouchesBegan = YES;
    longPressGestureRecognizer.cancelsTouchesInView =YES;
    [cell addGestureRecognizer:longPressGestureRecognizer];
    
    
    return cell;
}
-(void)shareButtonTapped:(UIButton*)sender
{
   // NSIndexPath *index = self.collectionView indexPathForCell:
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *postSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *post = [self.nameOfEvent objectAtIndex:sender.tag];
        NSString *postString = [NSString stringWithFormat:@" I am Interested in Going to : %@ Check it Out:", post];
        [postSheet setInitialText: postString];
        [postSheet addImage:[[ImageCaching sharedInstance] getCachedImageForKey:[self.picOfEvent objectAtIndex:sender.tag]]];
        NSURL *eventLink = [NSURL URLWithString:[self.urlOfEvent objectAtIndex:sender.tag]];
        [postSheet addURL:eventLink];
        [self presentViewController:postSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertController *actionSheet2 = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"You Cant make a Post right now, make sure your device has an internet connection and you have at least one Facebook account setup" preferredStyle:UIAlertControllerStyleAlert];
        [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        // Present action sheet.
        [self presentViewController:actionSheet2 animated:YES completion:nil];
       
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(400, 300);
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    eventDetailController *eventDetail =[[eventDetailController alloc]initWithNibName:@"eventDetailController" bundle:nil];
    if(![[self.venueIdOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        [self.imageCache.venueID setString:[self.venueIdOfEvent objectAtIndex:indexPath.row]];
    if(![[self.nameOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        [self.imageCache.eventName setString:[self.nameOfEvent objectAtIndex:indexPath.row]];
    if(![[self.descriptionOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        [self.imageCache.eventsDescription setString:[self.descriptionOfEvent objectAtIndex:indexPath.row]];
    if(![[self.startOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        [self.imageCache.startTime setString:[self.startOfEvent objectAtIndex:indexPath.row]];
    if(![[self.endOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        [self.imageCache.endTime setString:[self.endOfEvent objectAtIndex:indexPath.row]];
    if(![[self.urlOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        [self.imageCache.ticketUrl setString:[self.urlOfEvent objectAtIndex:indexPath.row]];
    if(![[self.picOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        [self.imageCache.eventPic setString:[self.picOfEvent objectAtIndex:indexPath.row]];
    if(![[self.eventID objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        [self.imageCache.eventID setString:[self.eventID objectAtIndex:indexPath.row]];
    
    
   [self.navigationController pushViewController: eventDetail animated:YES];

    return YES;
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
            
            [self.collectionView reloadData];
        });
        
    }];
    
    [dataTask resume];
}

-(void)parseJSONWithData:(NSData*)jsonData
{
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    if (!error) {
        NSMutableArray *eventTitle = [root valueForKeyPath:@"events.name.text"];
        self.nameOfEvent= eventTitle;
        NSMutableArray *eventPic = [root valueForKeyPath:@"events.logo.original.url"];
        self.picOfEvent= eventPic;
        NSMutableArray *eventTicketUrl = [root valueForKeyPath:@"events.url"];
        self.urlOfEvent= eventTicketUrl;
        NSMutableArray *venueID = [root valueForKeyPath:@"events.venue_id"];
        self.venueIdOfEvent = venueID;
        NSMutableArray *eventDescription =[root valueForKeyPath:@"events.description.text"];
        self.descriptionOfEvent =eventDescription;
        NSMutableArray *eventStart =[root valueForKeyPath:@"events.start.local"];
        self.startOfEvent=eventStart;
        NSMutableArray *eventEnd =[root valueForKeyPath:@"events.end.local"];
        self.endOfEvent=eventEnd;
        NSMutableArray *idOfEvent = [root valueForKeyPath:@"events.id"];
        self.eventID =idOfEvent;


        
        
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}
#pragma Gesture Recognizer Delegate
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint tappedPoint = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *tappedCellPath = [self.collectionView indexPathForItemAtPoint:tappedPoint];
    if (tappedCellPath)
    {
    EventsCell* cell =(EventsCell*)[self.collectionView cellForItemAtIndexPath:tappedCellPath];
        mapViewController *mapView = [[mapViewController alloc]initWithNibName:@"mapViewController" bundle:nil];
        mapView.title = cell.eventTitleLabel.text;
        if(![[self.venueIdOfEvent objectAtIndex:tappedCellPath.row] isKindOfClass:[NSNull class]])
        [self.imageCache.venueID setString:[self.venueIdOfEvent objectAtIndex:tappedCellPath.row]];
        NSLog(@"%@",[self.venueIdOfEvent objectAtIndex:tappedCellPath.row]);
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mapView];
        nav.title =cell.eventTitleLabel.text;
        nav.modalPresentationStyle = UIModalPresentationPopover;
        nav.popoverPresentationController.delegate =self;
        nav.preferredContentSize = CGSizeMake(480, 400);
        nav.popoverPresentationController.sourceRect =[[gestureRecognizer valueForKey:@"view"] bounds];
        nav.popoverPresentationController.sourceView =self.view;
        
        UIPopoverPresentationController *popoverController = nav.popoverPresentationController;
        popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popoverController.delegate = self;
        
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    
    return UIModalPresentationNone;
}
- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
    return navController;
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return NO;
}
-(void)dismissKeyboard {
    [self.searchBar resignFirstResponder];
}
@end
