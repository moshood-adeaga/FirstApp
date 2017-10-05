//
//  EventsViewController.m
//  FinalProject
//
//  Created by Shegz on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "EventsViewController.h"
#import "ImageCaching.h"
#import "EventsCell.h"
#import <Social/Social.h>
#import <objc/runtime.h>

@interface EventsViewController ()
{
    NSString * imageUrl;
    UIImage *image;
    
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
    self.collectionView.backgroundColor = [UIColor whiteColor];
    // Register Nib classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"EventsCell" bundle:nil] forCellWithReuseIdentifier:[EventsCell cell_ID]];
    
    //Creating A Search Bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, 415, 44)];
    self.searchBar.placeholder = @"Enter Location for Events";
    self.searchBar.delegate =self;
    [self.view addSubview:self.searchBar];
    [self.collectionView reloadData];
    
    
    
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchString = self.searchBar.text;
    NSString *eventLink = [NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/events/search/?q=%@&token=XU4CJHOK4JHP4VB3XY4B",searchString];
    [self initParse:eventLink];
    [self.searchBar resignFirstResponder];
}



#pragma mark <UICollectionViewDataSource>



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.nameOfEvent count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EventsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[EventsCell cell_ID] forIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    // Image Caching
    if(![[self.picOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
    {
    NSURL *imageURL = [NSURL URLWithString:[self.picOfEvent objectAtIndex:indexPath.row]];
    
    image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
    } else if([[self.picOfEvent objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
    {
        image =[[UIImage alloc]initWithData:[NSData dataWithContentsOfFile:@"noimage.png"]];
        //[UIImage imageWithContentsOfFile:@"noimage.png"];
    }

    if(image)
    {
        NSLog(@"Caching ....");
        [[ImageCaching sharedInstance] cacheImage:image forKey:[self.picOfEvent objectAtIndex:indexPath.row]];
    }
       
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [cell fillEvent:[self.nameOfEvent objectAtIndex:indexPath.row] eventImage:[[ImageCaching sharedInstance] getCachedImageForKey:[self.picOfEvent objectAtIndex:indexPath.row]]];
    });
    CGRect btnRect = CGRectMake(352,263, 45, 29);
    UIButton *cellBtn = [[UIButton alloc] initWithFrame:btnRect];
    [cellBtn setBackgroundImage:[UIImage imageNamed:@"sharebutton.png"] forState:UIControlStateNormal];
    [cellBtn setTitle:@"" forState:UIControlStateNormal];
    [cell.contentView addSubview:cellBtn];
    [cellBtn addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cellBtn setTag:indexPath.row];
    
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
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You Cant make a Post right now, make sure your device has an internet connection and you have at least one Facebook account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
#pragma mark <UICollectionViewDelegate>
-(CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(400, 300);
}

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
-(BOOL)collectionView:(UICollectionView *)collectionView canEditItemAtIndexPath:(NSIndexPath *)indexPath
{
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
        NSMutableArray *eventUrl = [root valueForKeyPath:@"events.url"];
        self.urlOfEvent= eventUrl;
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}
@end
