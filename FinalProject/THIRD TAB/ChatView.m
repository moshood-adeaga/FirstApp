//
//  ChatView.m
//  FinalProject
//
//  Created by Moshood Adeaga on 09/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "ChatView.h"
#import "ImageCaching.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import <JSQMessagesViewController.h>
#import <JSQMessage.h>
#import <JSQMessagesCollectionViewCell.h>
#import <JSQMessagesBubbleImage.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <JSQMessageBubbleImageDataSource.h>
#import <JSQMediaItem.h>
#import <JSQMessageMediaData.h>
#import <JSQPhotoMediaItem.h>
#import <JSQVideoMediaItem.h>
#import <JSQMessageMediaData.h>
#import <JSQMessageData.h>
#import <JSQSystemSoundPlayer.h>
#import <JSQMessagesTimestampFormatter.h>
#import <JSQSystemSoundPlayer+JSQMessages.h>
#import <JSQMessagesAvatarImageFactory.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <math.h>
#import "FriendProfileViewController.h"


@interface ChatView()
{
    FIRDatabaseHandle refHandle;
    NSUserDefaults *standardDefault;
}
@property (nonatomic, strong) NSMutableArray<JSQMessage*> *messages;
@property (nonatomic, strong) JSQMessagesBubbleImage *sendingBubble;
@property (nonatomic, strong) JSQMessagesBubbleImage *receivingBubble;
@property (nonatomic, strong) JSQMessagesAvatarImage *outgoing;
@property (nonatomic, strong) JSQMessagesAvatarImage *incoming;
@property (nonatomic, strong) JSQMessagesBubbleImageFactory *colorBubble;
@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (nonatomic, strong) NSString *imageDownloadLink;
@property (nonatomic, strong) NSString *dataBasePath;
@end
@implementation ChatView

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate =self;
    self.collectionView.dataSource= self;
    self.messages =[NSMutableArray new];
    self.navigationItem.title =[[ImageCaching sharedInstance]selectedUsersName];
    standardDefault = [NSUserDefaults standardUserDefaults];
    
    
    //Declaring Senders ID & Username for Chat
    self.senderId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    self.senderDisplayName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    
    //Bar Button for View the Profile of who the User is currently chatting to.
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(optionButton:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    //Creating A Unique ID for a database, chatting this is done so that users can chat with each other provately
    // this works by creating a database between two specific users and only both of them can access the data.
    NSString *currentUser = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSString *selectedUser =[[ImageCaching sharedInstance]selectedUsersName];
    NSString *chatIdentifier;
    
    if(![selectedUser  isEqual: @"0"])
    {
        //Creating Unique ID for private Chat.
        NSInteger String = [currentUser hash];
        NSInteger String2 = [selectedUser hash];
        
        NSInteger uniqueIDComp = (String)*(String2);
        NSInteger uniqueID = uniqueIDComp/100;
        chatIdentifier = [NSString stringWithFormat:@"%ld",(long)uniqueID];
    }
    else
    {
        //Creating An ID for Global, this will make it a global chat which is accessible by all users.
        chatIdentifier = @"0";
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.title =@"GLOBAL CHAT";
    }
    self.ref = [[[FIRDatabase database] reference] child:chatIdentifier];
    
    // Creating a Bubble for Messages, two bubble types one for OUTGOING messages and the other  for INCOMING messages.
    _colorBubble =[[JSQMessagesBubbleImageFactory alloc]init];
    _sendingBubble = [_colorBubble outgoingMessagesBubbleImageWithColor:[self.navigationController.navigationBar barTintColor]];
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:[standardDefault objectForKey:@"settingsFont"] size:17];
    _receivingBubble = [_colorBubble incomingMessagesBubbleImageWithColor:[UIColor grayColor]];
    
    // Creating an avatar image for User.
    if( [[ImageCaching sharedInstance]getCachedImageForKey:[[NSUserDefaults standardUserDefaults]objectForKey:@"userImage"]])
    {
        UIImage *outGoingAvatar = [[ImageCaching sharedInstance]getCachedImageForKey:[[NSUserDefaults standardUserDefaults]objectForKey:@"userImage"]];
        _outgoing=[ JSQMessagesAvatarImageFactory  avatarImageWithImage:outGoingAvatar diameter:70 ];
    }else
    {
        UIImage *outGoingAvatar = [UIImage imageNamed:@"outgoing"];
        _outgoing=[ JSQMessagesAvatarImageFactory  avatarImageWithImage:outGoingAvatar diameter:70 ];
        // Downloading the image asynchronously
        if(![[[NSUserDefaults standardUserDefaults]objectForKey:@"userImage"] isKindOfClass:[NSNull class]])
        {
            NSURL *imageUrl = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults]objectForKey:@"userImage"]];
            [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    // Change the image in the chat Bubble image.
                    UIImage *outGoingAvatar = image;
                    _outgoing=[ JSQMessagesAvatarImageFactory  avatarImageWithImage:outGoingAvatar diameter:70 ];
                    
                    // Cache the image for use later
                    [[ImageCaching sharedInstance]cacheImage:image forKey:[[NSUserDefaults standardUserDefaults]objectForKey:@"userImage"]];
                    
                }
            }];
        }
    }
    
    // Creating an avatar image for Who User is chatting to.
    if( [[ImageCaching sharedInstance]getCachedImageForKey:[[ImageCaching sharedInstance]selectedImageLink]])
    {
        UIImage *incomingAvatar = [[ImageCaching sharedInstance]getCachedImageForKey:[[ImageCaching sharedInstance]selectedImageLink]];
        _incoming=[ JSQMessagesAvatarImageFactory  avatarImageWithImage:incomingAvatar diameter:70];
    }else
    {
        UIImage *incomingAvatar = [ UIImage imageNamed:@"incoming"];
        _incoming=[ JSQMessagesAvatarImageFactory  avatarImageWithImage:incomingAvatar diameter:70];
        
        // Downloading the image asynchronously
        if(![[[ImageCaching sharedInstance]selectedImageLink] isKindOfClass:[NSNull class]])
        {
            NSURL *imageUrl = [NSURL URLWithString:[[ImageCaching sharedInstance]selectedImageLink]];
            [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    // change the image in the chat Bubble image.
                    UIImage *incomingAvatar = image;
                    _incoming=[ JSQMessagesAvatarImageFactory  avatarImageWithImage:incomingAvatar diameter:70];
                    
                    // cache the image for use later
                    [[ImageCaching sharedInstance]cacheImage:image forKey:[[ImageCaching sharedInstance]selectedImageLink]];
                    
                }
            }];
        }
    }
    if([selectedUser  isEqual: @"0"])
    {
        UIImage *incomingAvatar = [ UIImage imageNamed:@"incoming"];
        _incoming=[ JSQMessagesAvatarImageFactory  avatarImageWithImage:incomingAvatar diameter:70];
        
    }
    //Database Path to update last message from/to user.
    self.dataBasePath= @"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/lastmessage.php";

    // Function to observe Incoming & Outgoing messages.
       [self observeMessages];
}


#pragma - JSQMessages CollectionView DataSource & Delegate

// The will print the messages being sent and being received onto the collectionview
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [self.messages objectAtIndex:indexPath.item];
}

// This will determine the number of secetions for the collection view.
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

// This will work by using the message bubble variable created in the view did load, and it will help to
//determine  which side to show the incoming and outgoing messages bubbles and it will use the sender id attached
//to each movie to differentiate if the message is an outgoing or incoming.
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    if (message.senderId == self.senderId) {
        return self.sendingBubble;
    }
    
    return self.receivingBubble;
}

// This will also help the users to differentiate between the messages being sent and the message they are
// sending , it works by showing the avatar image of the users on their respective messages they have sent,
// it uses the sender id as well to differentiate between the users aswell.
-  (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView*)collectionView
                     avatarImageDataForItemAtIndexPath:(NSIndexPath*)indexPath {
    
    JSQMessage *message = [ _messages objectAtIndex:indexPath.item];
    if  (message.senderId == self.senderId)
    {
        return  _outgoing ;
    }
    return  _incoming ;
    
}

// This will show the username of the who ever the user is chatting to on the message that the person sends
// this is also to differentiate between users on what message is theres and which isnt.
-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    
    if (currentMessage.senderId == self.senderId)
    {
        return nil;
    }
    if(indexPath.item > 0) {
        JSQMessage *prevMessage = [self.messages objectAtIndex:indexPath.item-1];
        if(prevMessage.senderId == currentMessage.senderId)
            return nil;
    }
    return [[NSAttributedString alloc] initWithString:_messages[indexPath.item].senderDisplayName];
    
}
// This allows the height of the cell to be adjusted so that the username can be shown.
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    if(message.senderId ==self.senderId)
    {
        return 0.0f;
    }
    if (indexPath.item > 0)
    {
        JSQMessage *prevMessage = [self.messages objectAtIndex:indexPath.item-1];
        if(prevMessage.senderId == message.senderId)
            return 0.0f;
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}
// This will allow the messages to be print a time stamp of the time that they were sent.
// This is another function which is peurpose is to enhance the user experience.
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if (indexPath.item == 0) {
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        
        if ([message.date timeIntervalSinceDate:previousMessage.date] / 60 > 1) {
            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
        }
    }
    
    return nil;
}
// This allows the height of the cell to be adjusted so that the Time Stamp can be shown.
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        
        if ([message.date timeIntervalSinceDate:previousMessage.date] / 60 > 1) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    }
    
    return 0.0f;
}

#pragma  Action Buttons and Functions

// This function is call when the accessory button is pressed, its function is self explanatory, it helps to allow
// the users to attach ,media in their library and also the functionality to be able to record new video or take a new phot0.
-(void)didPressAccessoryButton:(UIButton *)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Media" message:@"Using Your Library" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take New Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *actionSheet2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            // Present action sheet.
            [self presentViewController:actionSheet2 animated:YES completion:nil];
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
#if TARGET_IPHONE_SIMULATOR
#else
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeMovie, nil];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take New Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *actionSheet2 = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
            [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            // Present action sheet.
            [self presentViewController:actionSheet2 animated:YES completion:nil];
            
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        
#if TARGET_IPHONE_SIMULATOR
#else
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
#endif
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    // iPad Adaptation to allow the action sheet to show up as a popover controller as this the way
    // that the iPad can present the action sheet.
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    actionSheet.popoverPresentationController.delegate =self;
    actionSheet.preferredContentSize = CGSizeMake(480, 400);
    actionSheet.popoverPresentationController.sourceRect = sender.bounds;
    actionSheet.popoverPresentationController.sourceView =self.view;
    
    UIPopoverPresentationController *popoverController = actionSheet.popoverPresentationController;
    popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverController.delegate = self;
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}


// Main function of the program, this function helps to observe the messsages on the server both being recieved,
// and also sent messages, the messages is being observed form the firebase server and the snapshot of the data
// is taken be the observer function and then visulaised by  storing the data in an array and then, the array is
// is then made the data source for the collection view to view both the incoming and outgoing messages.
-(void)observeMessages
{
    [_ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        if(!snapshot.exists){return;}
        NSLog(@"%@",snapshot.value);
        
        // Text Messages is acquired  and then inserted in to the jsq messages array.
        if ([snapshot.value[@"Data-Type"] isEqual:@"TEXT"])
        {
            JSQMessage *messageContent = [[JSQMessage alloc]initWithSenderId:snapshot.value[@"userId"] senderDisplayName:snapshot.value[@"user"]  date:[NSDate dateWithTimeIntervalSince1970:[snapshot.value[@"Time"]intValue]] text:snapshot.value[@"message"]];
            NSDictionary *databaseParameter= @{@"username":[[ImageCaching sharedInstance]selectedUsersName],
                                               @"lastMessage":snapshot.value[@"message"]
                                               };
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

            [manager POST:self.dataBasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON Successsss: %@", responseObject);
                NSLog(@"operation Successsss: %@", operation);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error laaa: %@", error);
            }];
            [self.messages addObject:messageContent];
        }else
            // Photo Messages is acquired  and then inserted in to the jsq messages array.
            if ([snapshot.value[@"Data-Type"] isEqual:@"PHOTO"])
            {
                NSString *urlString = snapshot.value[@"Image"];
                NSURL *urlWithString = [NSURL URLWithString:urlString];
                UIImage *imageFromServer = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:urlWithString]];
                JSQPhotoMediaItem *jsqImage = [[JSQPhotoMediaItem alloc]initWithImage:imageFromServer];
                JSQMessage *messageContent =[[JSQMessage alloc]initWithSenderId:[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"] senderDisplayName:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"] date:[NSDate dateWithTimeIntervalSince1970:[snapshot.value[@"Time"]intValue]] media:jsqImage];
                NSDictionary *databaseParameter= @{@"username":[[ImageCaching sharedInstance]selectedUsersName],
                                                   @"lastMessage":@"Image"
                                                   };
                
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

                [manager POST:self.dataBasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON Successsss: %@", responseObject);
                    NSLog(@"operation Successsss: %@", operation);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error laaa: %@", error);
                }];
                [self.messages addObject:messageContent];
                
            }else
                // Video Messages is acquired  and then inserted in to the jsq messages array.
                if ([snapshot.value[@"Data-Type"] isEqual:@"VIDEO"])
                {
                    NSString *urlString = snapshot.value[@"Video"];
                    NSURL *urlWithString = [NSURL URLWithString:urlString];
                    JSQVideoMediaItem *jsqVideo =  [[JSQVideoMediaItem alloc]initWithFileURL:urlWithString isReadyToPlay:YES];
                    JSQMessage *messageContent =[[JSQMessage alloc]initWithSenderId:[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"] senderDisplayName:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"] date:[NSDate dateWithTimeIntervalSince1970:[snapshot.value[@"Time"]intValue]] media:jsqVideo];
                    NSDictionary *databaseParameter= @{@"username":[[ImageCaching sharedInstance]selectedUsersName],
                                                       @"lastMessage":@"Video"
                                                       };
                    
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                    
                    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
                    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
                    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

                    [manager POST:self.dataBasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"JSON Successsss: %@", responseObject);
                        NSLog(@"operation Successsss: %@", operation);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error laaa: %@", error);
                    }];
                    [self.messages addObject:messageContent];
                }
        [self finishReceivingMessageAnimated:YES];
        [self.collectionView reloadData];
        
        
        
        
    }];
}

//This function is called by the Send button, the button is self explanatory, and its purpose is to send text messages to the server.
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    FIRDatabaseReference *messageRef = _ref.childByAutoId;
    NSDictionary *post = @{@"userId": senderId,
                           @"user": senderDisplayName,
                           @"message": text,
                           @"Time":[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]],
                           @"Data-Type":@"TEXT"
                           };
    [messageRef setValue:post];
    
    [self finishSendingMessageAnimated:YES];
}

// This is the Fuction which sends Media Data ( PHOTO & VIDEO), this function works by using he fuctionality
// of an image picker and then the data is then stored onto the firebase storage , then the data is then downloaded
// from the server where it is required from in the application. Each Data is stored with unique identifier to differentiate
// between them and a folder is created on firebase storage for both video and image dat being stored from the application.
-(void)sendingMedia:(NSData*)imageData videoData:(NSURL*)video
{
    if (imageData != nil && video == nil)
    {
        FIRStorageReference *storageRef = [[FIRStorage storage] reference];
        NSString *filepath = [[NSUUID UUID] UUIDString];
        FIRStorageReference *directoryRef = [storageRef child:[NSString stringWithFormat:@"sendingAndReceivin/%@",filepath]];
        FIRStorageMetadata *metaData;
        metaData.contentType = @"image/jpg";
        FIRStorageUploadTask *uploadTask = [directoryRef putData:imageData metadata:metaData completion:^(FIRStorageMetadata *metadata,NSError *error) {
            if (error != nil)
            {
                NSLog(@"ERROR :%@",[error localizedDescription]);
            } else
            {
                NSLog(@"SUCESS");
                NSURL *downloadURL = metadata.downloadURL;
                NSLog(@"my image download%@",downloadURL);
                self.imageDownloadLink = [NSString stringWithFormat:@"%@",downloadURL];
                FIRDatabaseReference *messageRef = _ref.childByAutoId;
                NSDictionary *post = @{@"userId": [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"],
                                       @"user": [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"],
                                       @"Image": self.imageDownloadLink,
                                       @"Time":[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]],
                                       @"Data-Type":@"PHOTO"
                                       };
                [messageRef setValue:post];
                
            }
        }];
    } else if (video != nil && imageData == nil)
    {
        NSData *videoData = [NSData dataWithContentsOfURL:video];
        FIRStorageReference *storageRef = [[FIRStorage storage] reference];
        NSString *filepath = [[NSUUID UUID] UUIDString];
        FIRStorageReference *directoryRef = [storageRef child:[NSString stringWithFormat:@"sendingAndReceivin/%@",filepath]];
        FIRStorageMetadata *metaData;
        metaData.contentType = @"image/mp4";
        FIRStorageUploadTask *uploadTask = [directoryRef putData:videoData metadata:metaData completion:^(FIRStorageMetadata *metadata,NSError *error) {
            if (error != nil)
            {
                NSLog(@"ERROR :%@",[error localizedDescription]);
            } else
            {
                NSLog(@"SUCESS");
                NSURL *downloadURL = metadata.downloadURL;
                NSLog(@"my image download%@",downloadURL);
                self.imageDownloadLink = [NSString stringWithFormat:@"%@",downloadURL];
                FIRDatabaseReference *messageRef = _ref.childByAutoId;
                NSDictionary *post = @{@"userId": [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"],
                                       @"user": [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"],
                                       @"Video": self.imageDownloadLink,
                                       @"Time":[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]],
                                       @"Data-Type":@"VIDEO"
                                       };
                [messageRef setValue:post];
                
            }
        }];
    }
}
// In the case that a video is sent, a user might want to watch the video and if thats the case this fuction is call when
// a message bubble containing a video is tapped, this function uses the AVPlayerViewController to play the Video.
-(void) collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *tapMessage = [ self.messages objectAtIndex:indexPath.item];
    JSQVideoMediaItem *videoItem;
    if(tapMessage.isMediaMessage)
    {
        id<JSQMessageMediaData> mediaItem = tapMessage.media;
        if ([mediaItem isKindOfClass:[JSQVideoMediaItem class]]) {
            videoItem = (JSQVideoMediaItem*)mediaItem;
        }
        AVPlayerViewController *avView = [[AVPlayerViewController alloc]init];
        AVPlayer *player = [[AVPlayer alloc]initWithURL:videoItem.fileURL];
        avView.player =player;
        [self presentViewController:avView animated:YES completion:nil];
        
    }
}
// Image Picker delegate, this is a delagate used when the user wants to send any type of media.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    
    
    if(chosenImage == info[UIImagePickerControllerOriginalImage])
    {
        [self sendingMedia:imageData videoData:nil];
        
    }
    NSURL *video = info[UIImagePickerControllerMediaURL];
    if (video == info[UIImagePickerControllerMediaURL]) {
        
        [self sendingMedia:nil videoData:video];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
//Function to Show the profile of the user your Currently chatting to.
-(void)optionButton:(UIBarButtonItem*)sender
{
    FriendProfileViewController *friendView = [[FriendProfileViewController alloc]initWithNibName:@"FriendProfileViewController" bundle:nil];
    [self.navigationController pushViewController:friendView animated:YES];
    
}
// This function is used to download contents using its url and downloaded asynchronously.
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

@end



