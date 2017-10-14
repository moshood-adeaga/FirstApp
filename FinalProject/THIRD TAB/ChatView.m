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
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>



@interface ChatView ()
{
    FIRDatabaseHandle refHandle;

}
@property (strong,nonatomic)NSMutableArray  <JSQMessage*> *messages;
@property (nonatomic, strong) JSQMessagesBubbleImage *sendingBubble;
@property (nonatomic, strong) JSQMessagesBubbleImage *receivingBubble;
@property (nonatomic, strong) JSQMessagesBubbleImageFactory *colorBubble;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong,nonatomic) NSString *imageDownloadLink;


@end

@implementation ChatView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.senderId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    self.senderDisplayName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    //self.inputToolbar.contentView.leftBarButtonItem =nil;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize =CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize =CGSizeZero;
    self.collectionView.delegate =self;
    self.collectionView.dataSource= self;
    self.messages =[NSMutableArray new];
    self.ref = [[[FIRDatabase database] reference] child:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"]];
    _colorBubble =[[JSQMessagesBubbleImageFactory alloc]init];
    _sendingBubble = [_colorBubble outgoingMessagesBubbleImageWithColor:[UIColor grayColor]];
    _receivingBubble = [_colorBubble incomingMessagesBubbleImageWithColor:[UIColor blueColor]];
    
    
    [self observeMessages];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

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

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return nil;
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
-(CGFloat)collectionView :(JSQMessagesCollectionView*)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.item].senderId == self.senderId ? 0 : 15;
}
-(void)observeMessages
{
    //FIRDatabaseQuery *recentPostsQuery = [[self.ref child:@"posts"] queryLimitedToFirst:10];
    [_ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        if(!snapshot.exists){return;}
        NSLog(@"%@",snapshot.value);
       
        
        if ([snapshot.value[@"Data-Type"] isEqual:@"TEXT"])
        {
            JSQMessage *messageContent = [JSQMessage messageWithSenderId:snapshot.value[@"userId"] displayName:snapshot.value[@"user"]  text:snapshot.value[@"message"]];
            [self.messages addObject:messageContent];
        }else
        if ([snapshot.value[@"Data-Type"] isEqual:@"PHOTO"])
        {
            NSString *urlString = snapshot.value[@"Image"];
            NSURL *urlWithString = [NSURL URLWithString:urlString];
            UIImage *imageFromServer = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:urlWithString]];
            JSQPhotoMediaItem *jsqImage = [[JSQPhotoMediaItem alloc]initWithImage:imageFromServer];
            JSQMessage *messageContent = [JSQMessage messageWithSenderId:snapshot.value[@"userId"] displayName:snapshot.value[@"user"] media:jsqImage];
            [self.messages addObject:messageContent];
            
        }else
        if ([snapshot.value[@"Data-Type"] isEqual:@"VIDEO"])
        {
            NSString *urlString = snapshot.value[@"Video"];
            NSURL *urlWithString = [NSURL URLWithString:urlString];
            JSQVideoMediaItem *jsqVideo =  [[JSQVideoMediaItem alloc]initWithFileURL:urlWithString isReadyToPlay:YES];
            JSQMessage *messageContent = [JSQMessage messageWithSenderId:[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"] displayName:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"] media:jsqVideo];
                [self.messages addObject:messageContent];
        }
        [self finishReceivingMessageAnimated:YES];
        [self.collectionView reloadData];
        
        JSQMessage *messageContent = [JSQMessage messageWithSenderId:snapshot.value[@"userId"] displayName:snapshot.value[@"user"]  text:snapshot.value[@"message"]];
        [self.messages addObject:messageContent];
        
        
    }];
}
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    FIRDatabaseReference *messageRef = _ref.childByAutoId;
    NSDictionary *post = @{@"userId": senderId,
                           @"user": senderDisplayName,
                           @"message": text,
                           @"Data-Type":@"TEXT"
                           };
    [messageRef setValue:post];
    
   [self finishSendingMessageAnimated:YES];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
   
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    [self sendingMedia:imageData videoData:nil];

        if(chosenImage == info[UIImagePickerControllerOriginalImage])
        {
       
            NSURL *imageURL = [NSURL URLWithString:self.imageDownloadLink];
            UIImage *imageFromServer = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
            JSQPhotoMediaItem *jsqImage =[[JSQPhotoMediaItem alloc]initWithImage:imageFromServer];
            JSQMessage *messageContent = [JSQMessage messageWithSenderId:[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"] displayName:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"] media:jsqImage];
            [self.messages addObject:messageContent];
            
            
        [self finishSendingMessageAnimated:YES];
        }
        NSURL *video = info[UIImagePickerControllerMediaURL];
    if (video == info[UIImagePickerControllerMediaURL]) {
        JSQVideoMediaItem *videoContent = [[JSQVideoMediaItem alloc]initWithFileURL:video isReadyToPlay:YES];
        JSQMessage *messageContent = [JSQMessage messageWithSenderId:[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"] displayName:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"] media:videoContent];
        [self sendingMedia:nil videoData:video];
        [self.messages addObject:messageContent];
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
                                   @"Data-Type":@"VIDEO"
                                   };
            [messageRef setValue:post];
            
        }
    }];
}
}

@end



