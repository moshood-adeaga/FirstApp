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
@property (strong, nonatomic) MKPlacemark *destination;
@property (strong,nonatomic) MKPlacemark *source;
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
//        MKCoordinateRegion region;
//        region.center.latitude = eventLatitude;
//        region.center.longitude =eventLongtitude;
//        region.span.latitudeDelta = 0.001;
//        region.span.longitudeDelta = 0.001;
//
//        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
//        point.coordinate = region.center;
//
//        [self.myMapView addAnnotation:point];
//        [self.myMapView setRegion:region animated:YES];
        CLLocationManager *locationManager;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
            [locationManager requestWhenInUseAuthorization];
        
        [locationManager startUpdatingLocation];
        CLLocation *location = [locationManager location];
        
        CLLocationCoordinate2D sourceCoords= location.coordinate;
        
        MKCoordinateRegion region;
        //Set Zoom level using Span
        MKCoordinateSpan span;
        region.center = sourceCoords;
        
        span.latitudeDelta = 1;
        span.longitudeDelta = 1;
        region.span=span;
        [_myMapView setRegion:region animated:TRUE];
        
        MKPlacemark *placemark  = [[MKPlacemark alloc] initWithCoordinate:sourceCoords addressDictionary:nil];
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = sourceCoords;
        annotation.title = @"My Location";
        [self.myMapView addAnnotation:annotation];
        //[self.myMapView addAnnotation:placemark];
        
        _destination = placemark;
        
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:_destination];
        
        CLLocationCoordinate2D destCoords;
        destCoords.latitude =eventLatitude;
        destCoords.longitude=eventLongtitude;
        MKPlacemark *placemark1  = [[MKPlacemark alloc] initWithCoordinate:destCoords addressDictionary:nil];
        
        MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
        annotation1.coordinate = destCoords;
        annotation1.title = [root valueForKeyPath:@"address.localized_address_display"];
        [self.myMapView addAnnotation:annotation1];
        
        //[self.myMapView addAnnotation:placemark1];
        
        _source = placemark1;
        
        MKMapItem *mapItem1 = [[MKMapItem alloc] initWithPlacemark:_source];
        
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        request.source = mapItem1;
        
        request.destination = mapItem;
        request.requestsAlternateRoutes = NO;
        
        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        
        [directions calculateDirectionsWithCompletionHandler:
         ^(MKDirectionsResponse *response, NSError *error) {
             if (error) {
                 NSLog(@"ERROR");
                 NSLog(@"%@",[error localizedDescription]);
             } else {
                 [self showRoute:response];
             }
         }];
        
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}
-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [_myMapView
         addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}

#pragma mark - MKMapViewDelegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor colorWithRed:0.0/255.0 green:171.0/255.0 blue:253.0/255.0 alpha:1.0];
    renderer.lineWidth = 2.0;
    return  renderer;
}

@end
