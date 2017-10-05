//
//  MediaController.m
//  FinalProject
//
//  Created by Shegz on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "MediaController.h"
#import <QuartzCore/QuartzCore.h>


@interface MediaController ()

@end

@implementation MediaController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.propButton setBackgroundColor:[UIColor clearColor]];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];

    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *deviceStatus = [[UIAlertView alloc]initWithTitle:@"No Device" message:@"Camera is not Available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [deviceStatus show];
        
    }
    else {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    }
}
- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
@end
