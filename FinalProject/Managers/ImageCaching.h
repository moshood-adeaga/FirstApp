//
//  ImageCaching.h
//  FinalProject
//
//  Created by Shegz on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageCaching : NSObject
+(ImageCaching*)sharedInstance;
-(void)cacheImage:(UIImage*)image forKey:(NSString*)key;
-(UIImage*)getCachedImageForKey:(NSString*)key;

@property(strong,nonatomic) NSMutableString *userID;

@end
