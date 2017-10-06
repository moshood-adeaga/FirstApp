//
//  AVCamPhotoCaptureDelegate.h
//  FinalProject
//
//  Created by TheAppExperts on 10/5/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVCamPhotoCaptureDelegate : NSObject<AVCapturePhotoCaptureDelegate>

- (instancetype)initWithRequestedPhotoSettings:(AVCapturePhotoSettings *)requestedPhotoSettings willCapturePhotoAnimation:(void (^)(void))willCapturePhotoAnimation livePhotoCaptureHandler:(void (^)( BOOL capturing ))livePhotoCaptureHandler completionHandler:(void (^)( AVCamPhotoCaptureDelegate *photoCaptureDelegate ))completionHandler;

@property (nonatomic, readonly) AVCapturePhotoSettings *requestedPhotoSettings;

@end
