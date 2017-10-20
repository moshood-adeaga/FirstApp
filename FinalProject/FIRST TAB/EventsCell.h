//
//  EventsCell.h
//  FinalProject
//
//  Created by Moshood Adeaga on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsCell : UICollectionViewCell<UIGestureRecognizerDelegate>

+(NSString*)cell_ID;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventsImageView;

-(void)fillEvent:(NSString*)title eventImage:(UIImage*)image;
@end
