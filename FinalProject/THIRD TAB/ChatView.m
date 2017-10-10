//
//  ChatView.m
//  FinalProject
//
//  Created by Moshood Adeaga on 09/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "ChatView.h"
#import <JSQMessagesViewController.h>
#import <JSQMessage.h>
#import <JSQMessagesBubbleImage.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <FirebaseDatabase/FirebaseDatabase.h>



@interface ChatView ()
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
    self.inputToolbar.contentView.leftBarButtonItem =nil;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize =CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize =CGSizeZero;
    self.ref = [[FIRDatabase database] reference];
    
    _sendingBubble = [_colorBubble outgoingMessagesBubbleImageWithColor:[UIColor grayColor]];
    _receivingBubble = [_colorBubble incomingMessagesBubbleImageWithColor:[UIColor blueColor]];
    
    
    FIRDatabaseQuery *recentPostsQuery = [[self.ref child:@"posts"] queryLimitedToFirst:10];
    [recentPostsQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
      for(FIRDataSnapshot *snap in snapshot )
           {
               NSString *userId = [snap valueForKey:@"userId"];
               NSString *userName = [snap valueForKey:@"user"];
               NSString *textSent = [snap valueForKey:@"message"];
               
               JSQMessage *messageContent = [JSQMessage messageWithSenderId:userId displayName:userName text:textSent];
               [self.messages addObject:messageContent];
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self finishSendingMessageAnimated:YES];
               });
           }
    }];

    
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

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessage *data = [self.messages objectAtIndex:indexPath.row];
    if ([data.senderId isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"]])
    {
        return self.sendingBubble;
    }
    else
    {
        return self.receivingBubble;
    }
    return nil;
}
-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
-(NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([currentMessage.senderId isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"]])
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
//    NSDictionary *messageContent = @{
//                                     @"sender" :senderId,
//                                     @"name"   :senderDisplayName,
//                                     @"text"   :text
//                                     };
    NSString *key = [[_ref child:@"posts"] childByAutoId].key;
    NSDictionary *post = @{@"userId": senderId,
                           @"user": senderDisplayName,
                           @"message": text,
                          };
    NSDictionary *childUpdates = @{[@"/posts/" stringByAppendingString:key]: post,
                                   [NSString stringWithFormat:@"/user-posts/%@/%@/", senderId, key]: post};
    [_ref updateChildValues:childUpdates];
    JSQMessage *messageContent = [JSQMessage messageWithSenderId:senderId displayName:senderDisplayName text:text];
    [self.messages addObject:messageContent];
    dispatch_async(dispatch_get_main_queue(), ^{
            [self finishSendingMessageAnimated:YES];
        });
   
   
    
}
@end



