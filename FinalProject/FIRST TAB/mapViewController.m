//
//  mapViewController.m
//  FinalProject
//
//  Created by Moshood Adeaga on 11/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "mapViewController.h"
#import "ImageCaching.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface mapViewController ()
{
    double eventLatitude;
    double eventLongtitude;
    id venueID;
}
@property(strong,nonatomic)ImageCaching *imageCache;
@end

@implementation mapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageCache = [ImageCaching sharedInstance];
    [self.myMapView setDelegate: self];
    venueID =self.imageCache.venueID;
    
    NSString *venueLink =[NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/venues/%@/?token=XU4CJHOK4JHP4VB3XY4B",venueID];
    
    [self initParse:venueLink];
    
    
    
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
        
    }];
    
    [dataTask resume];
}

-(void)parseJSONWithData:(NSData*)jsonData
{
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    if (!error) {
        NSString *eventLatitude1 = [root valueForKeyPath:@"address.latitude"];
        eventLatitude = [eventLatitude1 doubleValue];
        
        NSString *eventLongtitude1 = [root valueForKeyPath:@"address.longitude"];
        eventLongtitude = [eventLongtitude1 doubleValue];
        
        //Plotting the data of the event Latitude and Logitude to the Map
        // this is shown in the Event View Controller,and triggered by the
        //Long press Gesture Recognizer.
        MKCoordinateRegion region;
        region.center.latitude = eventLatitude;
        region.center.longitude =eventLongtitude;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
        point.coordinate = region.center;
        
        [self.myMapView addAnnotation:point];
        [self.myMapView setRegion:region animated:YES];
        
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}


@end
