//
//  ImageCaching.m
//  FinalProject
//
//  Created by Shegz on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "ImageCaching.h"
static ImageCaching *sharedInstance;
@interface ImageCaching ()
@property (nonatomic, strong) NSCache *imageCache;
@end

@implementation ImageCaching
+(ImageCaching*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImageCaching alloc] init];
    });
    return sharedInstance;
}
-(instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
        self.userID = [[NSMutableString alloc]init];
        self.venueID = [[NSMutableString alloc]init];
        self.eventsDescription = [[NSMutableString alloc]init];
        self.ticketUrl = [[NSMutableString alloc]init];
        self.startTime = [[NSMutableString alloc]init];
        self.endTime = [[NSMutableString alloc]init];
        self.eventName = [[NSMutableString alloc]init];
        self.eventPic = [[NSMutableString alloc]init];
         self.eventID = [[NSMutableString alloc]init];

    }
    return self;
}

-(void)cacheImage:(UIImage*)image forKey:(NSString*)key {
    [self.imageCache setObject:image forKey:key];
}

-(UIImage*)getCachedImageForKey:(NSString*)key {
    return [self.imageCache objectForKey:key];
}
@end
