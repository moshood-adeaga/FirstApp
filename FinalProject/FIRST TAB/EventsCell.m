//
//  EventsCell.m
//  FinalProject
//
//  Created by Shegz on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "EventsCell.h"
#import <QuartzCore/QuartzCore.h>



@implementation EventsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSUserDefaults *standardUserDefaults;
    standardUserDefaults =[NSUserDefaults standardUserDefaults];
    [self.eventTitleLabel setFont:[UIFont fontWithName:[standardUserDefaults objectForKey:@"settingsFont"] size:17.0]];
    self.eventsImageView.layer.cornerRadius = 60.0f;
    self.eventsImageView.clipsToBounds = YES;
  
    
    
    
}
-(void)fillEvent:(NSString*)title eventImage:(UIImage*)image{
    [self.eventTitleLabel setText:title];
    [self.eventsImageView setImage:image];
}




+(NSString*)cell_ID
{
    return @"EventsCell";
}

@end
