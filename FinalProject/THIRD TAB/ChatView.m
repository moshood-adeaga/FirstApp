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
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>



@interface ChatView ()
{
    FIRDatabaseHandle refHandle;

}
@property(strong,nonatomic)NSMutableArray  <JSQMessage*> *messages;
@property (nonatomic, strong) JSQMessagesBubbleImage *sendingBubble;
@property (nonatomic, strong) JSQMessagesBubbleImage *receivingBubble;
@property (nonatomic, strong) JSQMessagesBubbleImageFactory *colorBubble;
@property (strong, nonatomic) FIRDatabaseReference *ref;


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
    self.ref = [[FIRDatabase database] reference];
    _colorBubble =[[JSQMessagesBubbleImageFactory alloc]init];
    _sendingBubble = [_colorBubble outgoingMessagesBubbleImageWithColor:[UIColor grayColor]];
    _receivingBubble = [_colorBubble incomingMessagesBubbleImageWithColor:[UIColor blueColor]];
    
    
    FIRDatabaseQuery *recentPostsQuery = [[self.ref child:@"posts"] queryLimitedToFirst:10];
    [recentPostsQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
     if(!snapshot.exists){return;}
        NSLog(@"%@",snapshot.value);
        JSQMessage *messageContent = [JSQMessage messageWithSenderId:snapshot.value[@"userId"] displayName:snapshot.value[@"user"]  text:snapshot.value[@"message"]];
        [self.messages addObject:messageContent];
        [self finishReceivingMessageAnimated:YES];
            [self.collectionView reloadData];

       
        
    }];

    
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
    
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeMovie, nil];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
        
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
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    NSString *key = [[_ref child:@"posts"] childByAutoId].key;
    NSDictionary *post = @{@"userId": senderId,
                           @"user": senderDisplayName,
                           @"message": text,
                          };
    NSDictionary *childUpdates = @{[@"/posts/" stringByAppendingString:key]: post,
                                   [NSString stringWithFormat:@"/user-posts/%@/%@/", senderId, key]: post};
    [_ref updateChildValues:childUpdates];
    [_ref setValue:post];
    JSQMessage *messageContent = [JSQMessage messageWithSenderId:senderId displayName:senderDisplayName text:text];
    [self.messages addObject:messageContent];
   [self finishSendingMessageAnimated:YES];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
   
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        
        JSQPhotoMediaItem *jsqImage =[[JSQPhotoMediaItem alloc]initWithImage:chosenImage];
        // NSString *key = [[_ref child:@"posts"] childByAutoId].key;
        JSQMessage *messageContent = [JSQMessage messageWithSenderId:[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"] displayName:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"] media:jsqImage];
        
        [self.messages addObject:messageContent];
        
        [self finishSendingMessageAnimated:YES];
        [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



@end



