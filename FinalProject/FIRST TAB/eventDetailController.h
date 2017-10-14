//
//  eventDetailController.h
//  FinalProject
//
//  Created by Moshood Adeaga on 12/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface eventDetailController : UIViewController<UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UITextView *eventDescription;
@property (weak, nonatomic) IBOutlet UILabel *eventDate;
@property (weak, nonatomic) IBOutlet UILabel *eventStartTime;
@property (weak, nonatomic) IBOutlet UILabel *eventEndTime;
@property (weak, nonatomic) IBOutlet UILabel *ticketPrice;
@property (weak, nonatomic) IBOutlet UILabel *eventVenue;
@property (weak, nonatomic) IBOutlet UITextView *ticketLink;
@property (weak, nonatomic) IBOutlet UITextView *eventLocation;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end
