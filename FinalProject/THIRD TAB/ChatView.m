//
//  ChatView.m
//  FinalProject
//
//  Created by Moshood Adeaga on 09/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "ChatView.h"
#import "ImageCaching.h"
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



@interface ChatView ()
{
    FIRDatabaseHandle refHandle;
    NSUserDefaults *standardDefault;
    

}
@property (strong,nonatomic)NSMutableArray  <JSQMessage*> *messages;
@property (nonatomic, strong) JSQMessagesBubbleImage *sendingBubble;
@property (nonatomic, strong) JSQMessagesBubbleImage *receivingBubble;
@property (nonatomic, strong) JSQMessagesAvatarImage *outgoing;
@property (nonatomic, strong) JSQMessagesAvatarImage *incoming;

@property (nonatomic, strong) JSQMessagesBubbleImageFactory *colorBubble;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong,nonatomic) NSString *imageDownloadLink;



@end

@implementation ChatView

- (void)viewDidLoad {
    [super viewDidLoad];
    /// π(a,b)=1/2(a+b)(a+b+1)+b///
    self.senderId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    self.senderDisplayName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    //self.inputToolbar.contentView.leftBarButtonItem =nil;
    //self.collectionView.collectionViewLayout.incomingAvatarViewSize =CGSizeZero;
   // self.collectionView.collectionViewLayout.outgoingAvatarViewSize =CGSizeZero;
    self.collectionView.delegate =self;
    self.collectionView.dataSource= self;
    self.messages =[NSMutableArray new];
    NSString *currentUser = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSString *selectedUser =[[ImageCaching sharedInstance]selectedUsersName];
    NSString *chatIdentifier;
    UIImage *barButtonImage=[[ImageCaching sharedInstance]getCachedImageForKey:[[ImageCaching sharedInstance]selectedImageLink]];
    [barButtonImage drawInRect:CGRectMake(0, 0, 10, 10)];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:barButtonImage
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(optionButton:)];
     self.navigationItem.rightBarButtonItem = barButtonItem;

    self.navigationItem.title =[[ImageCaching sharedInstance]selectedUsersName];
    if(![selectedUser  isEqual: @"0"])
    {
       
        NSInteger String = [currentUser hash];
        NSInteger String2 = [selectedUser hash];
        
        NSInteger uniqueIDComp = (String)*(String2);
        NSInteger uniqueID = uniqueIDComp/100;
        chatIdentifier = [NSString stringWithFormat:@"%ld",(long)uniqueID];
        
        
    } else{
        chatIdentifier = @"0";
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.title =@"GLOBAL CHAT";
    }
    self.ref = [[[FIRDatabase database] reference] child:chatIdentifier];
    _colorBubble =[[JSQMessagesBubbleImageFactory alloc]init];
    
    _sendingBubble = [_colorBubble outgoingMessagesBubbleImageWithColor:[UIColor grayColor]];
    _receivingBubble = [_colorBubble incomingMessagesBubbleImageWithColor:[UIColor blueColor]];
//  UIImage *outGoingAvatar = [[ImageCaching sharedInstance]getCachedImageForKey:[[NSUserDefaults standardUserDefaults]objectForKey:@"userImage"]];
_outgoing=[ JSQMessagesAvatarImageFactory  avatarImageWithImage : [UIImage imageNamed:@"outgoing"] diameter : 64 ];
//    UIImage *incomingAvatar = [[ImageCaching sharedInstance]getCachedImageForKey:[[NSUserDefaults standardUserDefaults]objectForKey:@"userImage"]];
    _incoming=[ JSQMessagesAvatarImageFactory  avatarImageWithImage:[UIImage imageNamed:@"incoming"]  diameter : 64 ];


    [self observeMessages];
    
}
-(void)optionButton:(UIBarButtonItem*)sender
{
    FriendProfileViewController *friendView = [[FriendProfileViewController alloc]initWithNibName:@"FriendProfileViewController" bundle:nil];
    
    [self.navigationController pushViewController:friendView animated:YES];
    
    
}

#pragma - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}
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
        picker.mediaTypes =
        [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
#endif
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
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

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if (message.senderId == self.senderId) {
        return self.sendingBubble;
    }
    
    return self.receivingBubble;
}
-  (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView*)collectionView
                           avatarImageDataForItemAtIndexPath:(NSIndexPath*)indexPath {

    JSQMessage *message = [ _messages objectAtIndex:indexPath.item];
    if  (message.senderId == self.senderId)
    {
        return  _outgoing ;
    }
    return  _incoming ;

}


-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
   
    if (currentMessage.senderId == self.senderId)
    {
        return nil;
    }
    else {
       return [[NSAttributedString alloc] initWithString:_messages[indexPath.item].senderDisplayName];
       
    }
    return nil;
    
}
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


-(void)observeMessages
{
    //FIRDatabaseQuery *recentPostsQuery = [[self.ref child:@"posts"] queryLimitedToFirst:10];
    [_ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        if(!snapshot.exists){return;}
        NSLog(@"%@",snapshot.value);
       
        
        if ([snapshot.value[@"Data-Type"] isEqual:@"TEXT"])
        {
            JSQMessage *messageContent = [[JSQMessage alloc]initWithSenderId:snapshot.value[@"userId"] senderDisplayName:snapshot.value[@"user"]  date:[NSDate dateWithTimeIntervalSince1970:[snapshot.value[@"Time"]intValue]] text:snapshot.value[@"message"]];
            [self.messages addObject:messageContent];
        }else
        if ([snapshot.value[@"Data-Type"] isEqual:@"PHOTO"])
        {
            NSString *urlString = snapshot.value[@"Image"];
            NSURL *urlWithString = [NSURL URLWithString:urlString];
            UIImage *imageFromServer = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:urlWithString]];
            JSQPhotoMediaItem *jsqImage = [[JSQPhotoMediaItem alloc]initWithImage:imageFromServer];
            JSQMessage *messageContent =[[JSQMessage alloc]initWithSenderId:[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"] senderDisplayName:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"] date:[NSDate dateWithTimeIntervalSince1970:[snapshot.value[@"Time"]intValue]] media:jsqImage];
            [self.messages addObject:messageContent];
            
        }else
        if ([snapshot.value[@"Data-Type"] isEqual:@"VIDEO"])
        {
            NSString *urlString = snapshot.value[@"Video"];
            NSURL *urlWithString = [NSURL URLWithString:urlString];
            JSQVideoMediaItem *jsqVideo =  [[JSQVideoMediaItem alloc]initWithFileURL:urlWithString isReadyToPlay:YES];
            JSQMessage *messageContent =[[JSQMessage alloc]initWithSenderId:[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"] senderDisplayName:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"] date:[NSDate dateWithTimeIntervalSince1970:[snapshot.value[@"Time"]intValue]] media:jsqVideo];
                [self.messages addObject:messageContent];
        }
        [self finishReceivingMessageAnimated:YES];
        [self.collectionView reloadData];
        
        
        
        
    }];
}
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
        //JSQVideoMediaItem *mediaItem = tapMessage.media;
        AVPlayerViewController *avView = [[AVPlayerViewController alloc]init];
        AVPlayer *player = [[AVPlayer alloc]initWithURL:videoItem.fileURL];
        avView.player =player;
     [self presentViewController:avView animated:YES completion:nil];
        
    }
}
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

@end



