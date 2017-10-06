//
//  CoreDataManager.h
//  FinalProject
//
//  Created by TheAppExperts on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject
+(instancetype)sharedManager;
@property(readonly,strong) NSPersistentContainer *persistentContainer;
-(void)saveContext;

@end
