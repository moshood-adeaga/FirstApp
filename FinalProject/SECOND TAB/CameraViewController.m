//
//  CameraViewController.m
//  FinalProject
//
//  Created by Moshood Adeaga on 18/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>
#import "AppDelegate.h"

@interface CameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property AVCaptureDevice *videoDevice;
@property AVCaptureSession *captureSession;
@property dispatch_queue_t captureSessionQueue;
@property  AVCaptureVideoDataOutput *videoDataOutput;

@property GLKView *videoPreviewView;
@property CIContext *ciContext;
@property EAGLContext *eaglContext;
@property CGRect videoPreviewViewBounds;
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UIButton *captureImage;
- (IBAction)imageCaptureButton:(UIButton *)sender;
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIActivityViewController *activityViewController;


@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cancelButton setHidden:YES];
    [self.saveButtonProperty setHidden:YES];
    self.view.backgroundColor = [UIColor clearColor];
    
    // setup the GLKView for video/image preview
    UIView *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _videoPreviewView = [[GLKView alloc] initWithFrame:window.bounds context:_eaglContext];
    _videoPreviewView.enableSetNeedsDisplay = NO;
    
    
    _videoPreviewView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _videoPreviewView.frame = window.bounds;
    
    // we make our video preview view a subview of the window, and send it to the back; this makes ViewController's view (and
    //its UI elements) on top of the video preview, and also makes video preview unaffected by device rotation
    
    [window addSubview:_videoPreviewView];
    [window sendSubviewToBack:_videoPreviewView];
    
   
    [_videoPreviewView bindDrawable];
    _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = _videoPreviewView.drawableWidth;
    _videoPreviewViewBounds.size.height = _videoPreviewView.drawableHeight;
    
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    //Check for Camera Device before starting the camera.
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 0)
    {
        [self _start];
    }
    else
    {
        NSLog(@"No device with AVMediaTypeVideo");
    }
    
}
-(void)_start
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
    
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == position) {
            _videoDevice = device;
            break;
        }
    }
    NSError *error = nil;
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    if (!videoDeviceInput)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Unable to obtain video device input, error: %@", error]);
        return;
    }
    // This will Obtain the preset and validate the preset
    NSString *preset = AVCaptureSessionPresetMedium;
    if (![_videoDevice supportsAVCaptureSessionPreset:preset])
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Capture session preset not supported by video device: %@", preset]);
        return;
    }
    
    // Create the capture session
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = preset;
    
    // CoreImage wants BGRA pixel format
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    
    // create and configure video data output
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOutput.videoSettings = outputSettings;
    
    // Create the dispatch queue for handling capture session delegate method calls
    _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:_captureSessionQueue];
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES;

    // begin configure capture session
    [_captureSession beginConfiguration];
    
    if (![_captureSession canAddOutput:self.videoDataOutput])
    {
        NSLog(@"Cannot add video data output");
        _captureSession = nil;
        return;
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings2 = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, (id)kCVPixelBufferPixelFormatTypeKey,[NSNumber numberWithInteger:kCVPixelFormatType_32BGRA], nil];
    [self.stillImageOutput setOutputSettings:outputSettings2];
    
    // Connect the video device input and video data and still image outputs
    [_captureSession addInput:videoDeviceInput];
    [_captureSession addOutput:self.videoDataOutput];
    [_captureSession addOutput:self.stillImageOutput];
    
    [_captureSession commitConfiguration];
    
    // Start everything
    [_captureSession startRunning];

}
// The Purpose of this function/delegate is to apply the effect to the Pic that is been taken.
// this is done using Core Image effects.
- (void)captureOutput:(AVCaptureStillImageOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
    CGRect sourceExtent = sourceImage.extent;
    
    CIFilter * vignetteFilter = [CIFilter filterWithName:@"CIVignetteEffect"];
    [vignetteFilter setValue:sourceImage forKey:kCIInputImageKey];
    [vignetteFilter setValue:[CIVector vectorWithX:sourceExtent.size.width/2 Y:sourceExtent.size.height/2] forKey:kCIInputCenterKey];
    [vignetteFilter setValue:@(sourceExtent.size.width/2) forKey:kCIInputRadiusKey];
    CIImage *filteredImage = [vignetteFilter outputImage];
    
    CIFilter *effectFilter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    [effectFilter setValue:filteredImage forKey:kCIInputImageKey];
    filteredImage = [effectFilter outputImage];
    
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    CGFloat previewAspect = _videoPreviewViewBounds.size.width  / _videoPreviewViewBounds.size.height;
    
    // This will maintain the aspect radio of the screen size, so we clip the video image
    CGRect drawRect = sourceExtent;
    if (sourceAspect > previewAspect)
    {
        // Use full height of the video image, and center crop the width
        drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
        drawRect.size.width = drawRect.size.height * previewAspect;
    }
    else
    {
        // Use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspect;
    }
    
    [_videoPreviewView bindDrawable];
    
    if (_eaglContext != [EAGLContext currentContext])
        [EAGLContext setCurrentContext:_eaglContext];
    
    // clear eagl view to grey
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // set the blend mode to "source over" so that CI will use that
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if (filteredImage)
        [_ciContext drawImage:filteredImage inRect:_videoPreviewViewBounds fromRect:drawRect];
    
    [_videoPreviewView display];
}



- (IBAction)imageCaptureButton:(UIButton *)sender {
    //Using the still Image Output, a still image is Captured
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", self.stillImageOutput);
  
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             NSLog(@"attachements: %@", exifAttachments);
         } else {
             NSLog(@"no attachments");
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         
         
         self.pictureImageView.image = image;
     }];
    [self.cancelButton setHidden:NO];
    [self.saveButtonProperty setHidden:NO];
    [self.captureImage setHidden:YES];
}
- (IBAction)saveButton:(UIButton *)sender {
    
    //Users can then either share the image taken by social media, email, message or simply save to device
    // this is done witht help of the Activity Controller.
    NSMutableArray *activityItems = [NSMutableArray array];
    [activityItems addObject:self.pictureImageView.image];
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self.activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
    }];
    // Creating An Interface whereby it can be used on an iPad.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.activityViewController animated:YES completion:nil];
    }
    else {
        
        // iPad
        self.activityViewController.modalPresentationStyle = UIModalPresentationPopover;
        self.activityViewController.popoverPresentationController.delegate =self;
        self.activityViewController.preferredContentSize = CGSizeMake(self.view.frame.size.width/2, self.view.frame.size.height/4);
        self.activityViewController.popoverPresentationController.sourceRect =[[sender valueForKey:@"view"] bounds];
        self.activityViewController.popoverPresentationController.sourceView =self.view;
        
        UIPopoverPresentationController *popoverController = self.activityViewController.popoverPresentationController;
        popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popoverController.delegate = self;
  
    }

}
- (IBAction)cancelAction:(UIButton *)sender
{
     self.pictureImageView.image =nil;
    [self.cancelButton setHidden:YES];
    [self.saveButtonProperty setHidden:YES];
    [self.captureImage setHidden:NO];

}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    
    return UIModalPresentationNone;
}
- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
    return navController;
}
@end
