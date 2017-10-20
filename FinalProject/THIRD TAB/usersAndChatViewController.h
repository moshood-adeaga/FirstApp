//
//  usersAndChatViewController.h
//  FinalProject
//
//  Created by Moshood Adeaga on 11/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface usersAndChatViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
@property(strong, nonatomic) NSMutableArray *firstName;
@property(strong, nonatomic) NSMutableArray *lastName;
@property(strong, nonatomic) NSMutableArray *userName;
@property(strong, nonatomic) NSMutableArray *imageLink;
@property(strong, nonatomic) NSMutableArray *idOfSelectedUser;
@property(strong, nonatomic) NSMutableArray *emailOfSelectedUser;
@property(strong, nonatomic) NSMutableArray *phoneNumberOfSelectedUser;
@property(strong, nonatomic) NSDictionary *usersDataFromServer;
@end
