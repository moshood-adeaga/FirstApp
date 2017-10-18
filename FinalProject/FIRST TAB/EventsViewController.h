//
//  EventsViewController.h
//  FinalProject
//
//  Created by Shegz on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface EventsViewController : UICollectionViewController<UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,UIGestureRecognizerDelegate,UIPopoverPresentationControllerDelegate,FBSDKSharingDelegate>
@property (strong,nonatomic) UISearchBar *searchBar;
@property (strong,nonatomic) NSMutableArray *nameOfEvent;
@property (strong,nonatomic) NSMutableArray *picOfEvent;
@property (strong,nonatomic) NSMutableArray *urlOfEvent;
@property (strong,nonatomic) NSMutableArray *venueIdOfEvent;
@property (strong,nonatomic) NSMutableArray *descriptionOfEvent;
@property (strong,nonatomic) NSMutableArray *startOfEvent;
@property (strong,nonatomic) NSMutableArray *endOfEvent;
@property (strong,nonatomic) NSMutableArray *eventID;


@end
