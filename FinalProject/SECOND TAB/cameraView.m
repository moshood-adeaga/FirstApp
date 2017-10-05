//
//  cameraView.m
//  FinalProject
//
//  Created by TheAppExperts on 10/5/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "cameraView.h"
#import <AVFoundation/AVFoundation.h>

@implementation cameraView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session
{
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.videoPreviewLayer.session = session;
}

@end
