//
//  EventsViewController.h
//  FinalProject
//
//  Created by Shegz on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsViewController : UICollectionViewController<UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate>
@property (strong,nonatomic) UISearchBar *searchBar;
@property (strong,nonatomic) NSMutableArray *nameOfEvent;
@property (strong,nonatomic) NSMutableArray *picOfEvent;
@property (strong,nonatomic) NSMutableArray *urlOfEvent;

@end
