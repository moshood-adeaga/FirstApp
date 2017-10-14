//
//  mapViewController.h
//  FinalProject
//
//  Created by Moshood Adeaga on 11/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface mapViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate,UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
@property (strong,nonatomic) MKPointAnnotation *lastAnnot;

@end
