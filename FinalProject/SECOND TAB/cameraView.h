//
//  cameraView.h
//  FinalProject
//
//  Created by TheAppExperts on 10/5/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVCaptureSession;
@interface cameraView : UIView
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) AVCaptureSession *session;
@end
