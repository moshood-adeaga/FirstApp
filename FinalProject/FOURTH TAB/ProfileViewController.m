//
//  ProfileViewController.m
//  FinalProject
//
//  Created by TheAppExperts on 10/6/17.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "ProfileViewController.h"
#import "RegisterViewController.h"
#import "ImageCaching.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import <FirebaseStorage/FirebaseStorage.h>

#import <MobileCoreServices/MobileCoreServices.h>
#import "RNDecryptor.h"
#import "RNEncryptor.h"



@interface ProfileViewController ()
@property (copy, nonatomic) NSString *filePath;
@property (strong, nonatomic) ImageCaching *dataTransfer;
@property (strong, nonatomic) NSString *dataBasePath;
@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"username:%@",self.userName.text);
    self.dataTransfer = [ImageCaching sharedInstance];
    
    
    
    self.profileImageViewer.image =[UIImage imageNamed:@"addimage"];
    self.profileImageViewer.layer.borderColor =[UIColor blackColor].CGColor;
    self.profileImageViewer.layer.borderWidth =5.0f;
    self.profileImageViewer.layer.cornerRadius =50.0f;
    self.profileImageViewer.clipsToBounds = YES;
   // self.userName.text = self.dataTransfer.userID;
    
   // [self setupUserDirectory];
   // [self prepareData];
    
    self.userName.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    self.lastName.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"lastName"];
    self.firstName.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"firstName"];
    self.emailLabel.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"email"];
    self.phoneNumberLabel.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"phoneNumber"];
}
- (IBAction)logOutButton:(UIButton *)sender
{
    RegisterViewController *registerControl =[[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    registerControl.title = @"LOG-IN";
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:registerControl];
    nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Arial" size:13.0],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)profileImagePicker:(UIButton *)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Profile Picture" message:@"Using the alert controller" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete Photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        self.profilePicture.image = nil;
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose From Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take New Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
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
    
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}
#pragma ImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    if (!chosenImage) {
        [info objectForKey: UIImagePickerControllerOriginalImage];
    }
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    NSString *imageName =@"profileImage.securedData";
    NSData *encryptedImage = [RNEncryptor encryptData:imageData withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
    [encryptedImage writeToFile:[self.filePath stringByAppendingPathComponent:imageName] atomically:YES];
    self.profilePicture.image = chosenImage;
    
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    FIRStorageReference *riversRef = [storageRef child:@"images/rivers.jpg"];
    FIRStorageUploadTask *uploadTask = [riversRef putData:imageData metadata:nil completion:^(FIRStorageMetadata *metadata,NSError *error) {
   if (error != nil)
   {
       NSLog(@"for fuck sake :%@",[error localizedDescription]);
   } else
   {
     NSLog(@"YAyyyyyyyyy");
   NSURL *downloadURL = metadata.downloadURL;
   NSLog(@"my image download%@",downloadURL);
       
   }
   }];
    

    

    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma Setting Up USER
- (void)setupUserDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    self.filePath = [documents stringByAppendingPathComponent:self.userName.text];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:self.filePath]) {
        NSLog(@"Directory already present.");
        
    } else {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:self.filePath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Unable to create directory for user.");
        }
    }
}

- (void)prepareData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.filePath error:&error];
    
    if ([contents count] && !error){
        NSLog(@"Contents of the user's directory. %@", contents);
        // Reading USER profile image from Directory //
        for (NSString *fileName in contents) {
            if ([fileName rangeOfString:@".securedData"].length > 0) {
                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
                UIImage *image = [UIImage imageWithData:decryptedData];
                self.profileImageViewer.image = image;
                
                
            } else {
                NSLog(@"This file is not secured.");
            }
        }
        // Reading USER First Name from Directory //
        for (NSString *fileName in contents) {
            if ([fileName rangeOfString:@".securedFirstName"].length > 0) {
                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
                NSString *firstName = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
                self.firstName.text = firstName;
                
                
            } else {
                NSLog(@"This file is not secured.");
            }
        }
        // Reading USER Last Name from Directory //
        for (NSString *fileName in contents) {
            if ([fileName rangeOfString:@".securedLastName"].length > 0) {
                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
                NSString *lastName = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
                self.lastName.text = lastName;
                
                
            } else {
                NSLog(@"This file is not secured.");
            }
        }
        // Reading USER Email from Directory //
        for (NSString *fileName in contents) {
            if ([fileName rangeOfString:@".securedEmail"].length > 0) {
                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
                NSString *userEmail = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
                self.emailLabel.text = userEmail;
                
                
            } else {
                NSLog(@"This file is not secured.");
            }
        }
        // Reading USER Phone Number from Directory //
        for (NSString *fileName in contents) {
            if ([fileName rangeOfString:@".securedPhoneNumber"].length > 0) {
                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
                NSString *userPhoneNumber = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
                self.phoneNumberLabel.text = userPhoneNumber;
                
                
            } else {
                NSLog(@"This file is not secured.");
            }
        }
        
    } else if (![contents count]) {
        if (error) {
            NSLog(@"Unable to read the contents of the user's directory.");
        } else {
            NSLog(@"The user's directory is empty.");
        }
    }
}
@end
