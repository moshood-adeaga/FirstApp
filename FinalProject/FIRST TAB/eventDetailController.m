//
//  eventDetailController.m
//  FinalProject
//
//  Created by Moshood Adeaga on 12/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "eventDetailController.h"
#import "ImageCaching.h"
#import <EventKit/EventKit.h>

@interface eventDetailController ()
{
    NSString *timeAndStart;
    NSString *timeAndEnd;
    NSString *venueId;
    NSString *ticketID;
    NSString *venueDetails;
    NSString *ticketDetails;
    NSString *addressLine1;
    NSString *addressLine2;
    NSString *city;
    NSString *region;
    NSString *postalCode;
    NSString *country;
    NSString *ticketAmount;
    NSString *venueName;
    NSString *ticketCost;
    
    
}

@property(strong,nonatomic)ImageCaching *imageCache;

@end

@implementation eventDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollView.contentSize.height);
    [self.scrollView setContentOffset: CGPointMake(0, self.scrollView.contentOffset.y)];
    self.scrollView.directionalLockEnabled = YES;
    
    // customizing View //
    self.eventDescription.layer.borderWidth = 3.0f;
    self.eventDescription.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.eventLocation.layer.borderWidth =3.0f;
    self.eventLocation.layer.borderColor =[UIColor blackColor].CGColor;
    
    self.ticketLink.layer.borderWidth = 3.0f;
    self.ticketLink.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.imageCache = [ImageCaching sharedInstance];
    self.navigationItem.title =self.imageCache.eventName;
    self.eventImage.image = [UIImage imageNamed:@"noimage"];
    if(![self.imageCache.eventPic isEqualToString: @""])
    self.eventImage.image = [[ImageCaching sharedInstance]getCachedImageForKey:self.imageCache.eventPic];
    
    
    
    self.eventDescription.text = self.imageCache.eventsDescription;
    timeAndStart =self.imageCache.startTime;
    self.eventStartTime.text = [timeAndStart substringWithRange:NSMakeRange(11,8)];
    self.eventDate.text= [timeAndStart substringWithRange:NSMakeRange(0,10)];
    timeAndEnd = self.imageCache.endTime;
    self.eventEndTime.text =[timeAndEnd substringWithRange:NSMakeRange(11,8)];

    self.ticketLink.text = self.imageCache.ticketUrl;
    venueId =self.imageCache.venueID;
    ticketID =self.imageCache.eventID;
    ticketDetails = [NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/events/%@/ticket_classes/?token=XU4CJHOK4JHP4VB3XY4B",ticketID];
    venueDetails = [NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/venues/%@/?token=XU4CJHOK4JHP4VB3XY4B",venueId];
    if(ticketID != nil)
    [self initParse:ticketDetails];
    
    if(venueId != nil)
    [self initParse2:venueDetails];
    


    //Adding the Bar Button Item
    UIBarButtonItem *optionBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barButton"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(optionButton:)];
    
    self.navigationItem.rightBarButtonItem = optionBarButton;
 
    
}
-(void)optionButton:(UIBarButtonItem*)sender
{
    

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Action" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
    }]];
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Add To Events Consideration List " style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Set Reminder" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       //Creating an Event //
        EKEventStore *store = [[EKEventStore alloc] init];
        //ask for permission //
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) return;
            EKEvent *event = [EKEvent eventWithEventStore:store];
            event.title = self.navigationItem.title;
            
            //setting Event start Date//
            NSDateFormatter *dateFormat =[[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSDate *startDate =[dateFormat dateFromString:self.imageCache.startTime];
            event.startDate = startDate;
           
            
            //setting Event end Date//
            NSDateFormatter *dateFormat2 =[[NSDateFormatter alloc]init];
            [dateFormat2 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSDate *startDate2 =[dateFormat dateFromString:self.imageCache.endTime];
            event.endDate = startDate2;
            
            [event setCalendar:[store defaultCalendarForNewEvents]];
            NSError *err = nil;
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
            //NSString *savedEventId = event.eventIdentifier;
            UIAlertController *actionSheet2 = [UIAlertController alertControllerWithTitle:@"EVENT" message:@"Event has been Successfully Added" preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            // Present action sheet.
            [self presentViewController:actionSheet2 animated:YES completion:nil];
        }];
    }]];
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    actionSheet.popoverPresentationController.delegate =self;
    actionSheet.preferredContentSize = CGSizeMake(480, 400);
    actionSheet.popoverPresentationController.sourceRect =[[sender valueForKey:@"view"] bounds];
    actionSheet.popoverPresentationController.sourceView =self.view;
    
    UIPopoverPresentationController *popoverController = actionSheet.popoverPresentationController;
    popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverController.delegate = self;
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma  Parsing for Venue and Ticket Details
-(void)initParse:(NSString*)ticketLink
{
    NSURL *URL = [NSURL URLWithString:ticketLink];
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

-(void)parseJSONWithData:(NSData*)ticketData
{
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:ticketData options:0 error:nil];
    if (!error) {
        NSMutableArray *ticketClass = [root objectForKey:@"ticket_classes"];
        for (NSDictionary * dataDict in ticketClass) {
             ticketCost = [dataDict valueForKeyPath:@"cost.display"];
             NSLog(@"FROM ---> %@", ticketCost);
        }
            
       if(ticketCost ==nil)
        {
           ticketAmount = @"Free";
          
        }
       else if (ticketClass)
        {
            NSMutableArray *ticketClass = [root objectForKey:@"ticket_classes"];
            for (NSDictionary * dataDict in ticketClass) {
                ticketCost = [dataDict valueForKeyPath:@"cost.display"];
                NSLog(@"FROM2 ---> %@", ticketCost);
                 ticketAmount = ticketCost;
            }
           

        }
        
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
     dispatch_async(dispatch_get_main_queue(), ^{
    self.ticketPrice.text = ticketAmount;
     });

}
-(void)initParse2:(NSString*)venueLink
{
    NSURL *URL = [NSURL URLWithString:venueLink];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData  *_Nullable data, NSURLResponse * _Nullable response, NSError* _Nullable error) {
        
        
        if (error) {
            NSLog(@"Error!");
        } else if(data){
            [self parseJSONWithData2:data];
        } else {
            NSLog(@"Big error!");
        }
    }];
    
    [dataTask resume];
}

-(void)parseJSONWithData2:(NSData*)venueData
{
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:venueData options:0 error:nil];
    if (!error) {
       if(![[root valueForKeyPath:@"address.address_1"] isKindOfClass:[ NSNull class]])
       {
       addressLine1 =[root valueForKeyPath:@"address.address_1"];
       }else{
           addressLine1 =@"Not Available";
       }
        
        if(![[root valueForKeyPath:@"address.address_2"] isKindOfClass:[ NSNull class]])
        {
            addressLine2 =[root valueForKeyPath:@"address.address_2"];
        }else{
            addressLine2 =@"Not Available";
        }
        
        if(![[root valueForKeyPath:@"address.city"] isKindOfClass:[ NSNull class]])
        {
            city =[root valueForKeyPath:@"address.city"];
        }else{
            city =@"Not Available";
        }
        
        if(![[root valueForKeyPath:@"address.region"] isKindOfClass:[ NSNull class]])
        {
            region =[root valueForKeyPath:@"address.region"];
        }else{
            region =@"Not Available";
        }
        
        if(![[root valueForKeyPath:@"address.postal_code"] isKindOfClass:[ NSNull class]])
        {
            postalCode =[root valueForKeyPath:@"address.postal_code"];
        }else{
            postalCode =@"Not Available";
        }
        if(![[root valueForKeyPath:@"address.country"] isKindOfClass:[ NSNull class]])
        {
            country =[root valueForKeyPath:@"address.country"];
        }else{
            country =@"Not Available";
        }
        if(![[root valueForKeyPath:@"name"] isKindOfClass:[ NSNull class]])
        {
            venueName = [root valueForKeyPath:@"name"];
        }else
        {
            venueName =@"Not Available";
        }
        
        
        
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (addressLine1 ==nil) addressLine1 =@"Not Available";
        if (addressLine2 ==nil) addressLine2 =@"Not Available";
        if (city ==nil) city =@"Not Available";
        if (region ==nil) region =@"Not Available";
        if (postalCode ==nil) postalCode =@"Not Available";
        if (country ==nil) country =@"Not Available";

       self.eventLocation.text = [NSString stringWithFormat:@"%@,\n%@,\n%@,\n%@,\n%@,\n%@,\n",addressLine1,addressLine2,city,region,postalCode,country];
        
        if(venueName == nil)
        {
            self.eventVenue.text = @"Not Available";
        }else{
        self.eventVenue.text = venueName;
        }
    });
}

@end
