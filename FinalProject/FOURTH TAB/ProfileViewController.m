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
#import "EventsUnderConsiderationController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import <FirebaseStorage/FirebaseStorage.h>

#import <MobileCoreServices/MobileCoreServices.h>
#import "RNDecryptor.h"
#import "RNEncryptor.h"



@interface ProfileViewController ()
{
    NSUserDefaults *standardDefault;
}
@property (copy, nonatomic) NSString *filePath;
@property (strong, nonatomic) ImageCaching *dataTransfer;
@property (strong, nonatomic) NSString *dataBasePath;
@property (strong, nonatomic) NSString *dataBasePath2;
@property (strong, nonatomic) NSString *profilePicDownloadLink;
@property (strong, nonatomic) NSString *profilePicLink;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSUserDefaults *standardUserDefaults;
@property (strong, nonatomic) NSDictionary *colourDict;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.colourDict = @{
                        @"AQUA":[UIColor colorWithRed:0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0],
                        @"BLUE":[UIColor colorWithRed:0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0],
                        @"GREEN":[UIColor colorWithRed:0 green:204.0/255.0 blue:0 alpha:1.0],
                        @"RED":[UIColor colorWithRed:204.0/255.0 green:0 blue:0 alpha:1.0],
                        @"PURPLE":[UIColor colorWithRed:102.0/255.0 green:0 blue:204.0/255.0 alpha:1.0],
                        @"YELLOW":[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:0 alpha:1.0],
                        @"ORANGE":[UIColor colorWithRed:204.0/255.0 green:0 blue:102.0/255.0 alpha:1.0],
                        @"BLACK":[UIColor blackColor]
                        };
    
    
    self.dataTransfer = [ImageCaching sharedInstance];
    self.dataBasePath =@"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/imageupload.php";
    self.dataBasePath2 =@"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/updateprofile.php";
    
    UIColor *borderFrameColour = [self.colourDict objectForKey:[self.standardUserDefaults objectForKey:@"settingsColor"]];
    self.profileImageViewer.image =[UIImage imageNamed:@"addimage"];
    self.profileImageViewer.layer.borderColor =borderFrameColour.CGColor;
    self.profileImageViewer.layer.borderWidth =5.0f;
    self.profileImageViewer.layer.cornerRadius =50.0f;
    self.profileImageViewer.clipsToBounds = YES;
   // self.userName.text = self.dataTransfer.userID;
    
   // [self setupUserDirectory];
   // [self prepareData];
    
    self.userNameTextField.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    self.lastNameTextField.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"lastName"];
    self.firstNameTextField.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"firstName"];
    self.emailTextField.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"email"];
    self.phoneTextField.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"phoneNumber"];
    self.profilePicLink =[[NSUserDefaults standardUserDefaults]objectForKey:@"userImage"];
    
    //Downloading Profile Picture
    if([[ImageCaching sharedInstance] getCachedImageForKey:self.profilePicLink])
    {
        self.profilePicture.image =[[ImageCaching sharedInstance] getCachedImageForKey:self.profilePicLink];
    }else
    {
    
        // download the image asynchronously
        if(![self.profilePicLink isKindOfClass:[NSNull class]])
        {
            NSURL *imageUrl = [NSURL URLWithString:self.profilePicLink];
            [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    // change the image in the cell
                   self.profilePicture.image= image;
                    // cache the image for use later (when scrolling up)
                    [[ImageCaching sharedInstance]cacheImage:image forKey:self.profilePicLink];
                    
                }
            }];
        }
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self appear:YES];
    
}
- (NSArray*) getAllLabels
{
    
    NSArray *labels = [[NSArray alloc] initWithObjects:self.logoutProp, self.editProp, self.bookmarkProp, self.phoneProp, self.emailProp, self.lastnameProp,self.firstnameProp,self.userNameProp, nil];
    
    return labels;
}

- (void) appear:(BOOL)on
{
    for (UILabel *label in [self getAllLabels]) {
        //label.alpha = 0.0;
        label.backgroundColor=[self.colourDict objectForKey:[self.standardUserDefaults objectForKey:@"settingsColor"]];
        label.font =[UIFont fontWithName:[self.standardUserDefaults objectForKey:@"settingsFont"] size:17.0f];
        [self.bookmarkProp.titleLabel setFont:[UIFont fontWithName:[self.standardUserDefaults objectForKey:@"settingsFont"] size:17.0]];
        [self.editProp.titleLabel setFont:[UIFont fontWithName:[self.standardUserDefaults objectForKey:@"settingsFont"] size:17.0]];
        [self.logoutProp.titleLabel setFont:[UIFont fontWithName:[self.standardUserDefaults objectForKey:@"settingsFont"] size:17.0]];

    }
    // more code
}
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
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
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Profile Picture" message:@"Using Your Camera or Gallery" preferredStyle:UIAlertControllerStyleActionSheet];
    
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
    
    // Uploading user Profile pic to datbase//
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    FIRStorageReference *riversRef = [storageRef child:[NSString stringWithFormat:@"images/%@.jpg",self.userNameTextField.text]];
    FIRStorageMetadata *metaData;
    metaData.contentType = @"image/jpg";
    FIRStorageUploadTask *uploadTask = [riversRef putData:imageData metadata:metaData completion:^(FIRStorageMetadata *metadata,NSError *error) {
   if (error != nil)
   {
       NSLog(@"ERROR :%@",[error localizedDescription]);
   } else
   {
   NSLog(@"SUCESS");
   NSURL *downloadURL = metadata.downloadURL;
   NSLog(@"my image download%@",downloadURL);
   self.profilePicDownloadLink =[NSString stringWithFormat:@"%@", downloadURL];
   }
        
        NSDictionary *databaseParameter= @{@"imageLink":self.profilePicDownloadLink,
                                           @"id":[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"]
                                           };
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

        [manager POST:self.dataBasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON Successsss: %@", responseObject);
            NSLog(@"operation Successsss: %@", operation);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error laaa: %@", error);
        }];
   }];
  
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)profileEditButton:(UIButton*)sender
{
   sender.selected=!sender.selected;
   if(sender.selected )
   {
    [self.firstNameTextField setUserInteractionEnabled:YES];
    [self.lastNameTextField setUserInteractionEnabled:YES];
    [self.emailTextField setUserInteractionEnabled:YES];
    [self.phoneTextField setUserInteractionEnabled:YES];
    [self.firstNameTextField becomeFirstResponder];
   [self.editProp setTitle:@"Save Changes" forState:UIControlStateNormal];
   }else
    {
        [self.editProp setTitle:@"Edit Profile" forState:UIControlStateNormal];
        NSDictionary *databaseParameter2= @{@"id":[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"],
                                           @"firstname":self.firstNameTextField.text,
                                           @"lastname":self.lastNameTextField.text,
                                           @"username":self.userNameTextField.text,
                                           @"email":self.emailTextField.text,
                                           @"phone":self.phoneTextField.text
                                           };
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [manager POST:self.dataBasePath2 parameters:databaseParameter2 success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON SUCCESS: %@", responseObject);
            NSLog(@"operation Successsss: %@", operation);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error laaa: %@", error);
        }];
        [self.firstNameTextField setUserInteractionEnabled:NO];
        [self.lastNameTextField setUserInteractionEnabled:NO];
        [self.emailTextField setUserInteractionEnabled:NO];
        [self.phoneTextField setUserInteractionEnabled:NO];
        
        
    }
    

    
}

- (IBAction)bookmarkPageButton:(id)sender
{
    EventsUnderConsiderationController *eventsBookmark = [[EventsUnderConsiderationController alloc]initWithStyle:UITableViewStylePlain];
    
    [self.navigationController pushViewController:eventsBookmark animated:YES];
}
-(void)dismissKeyboard {
    [self.userNameTextField resignFirstResponder];
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    
}

//#pragma Setting Up USER
//- (void)setupUserDirectory {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documents = [paths objectAtIndex:0];
//    self.filePath = [documents stringByAppendingPathComponent:self.userNameTextField.text];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
//    if ([fileManager fileExistsAtPath:self.filePath]) {
//        NSLog(@"Directory already present.");
//
//    } else {
//        NSError *error = nil;
//        [fileManager createDirectoryAtPath:self.filePath withIntermediateDirectories:YES attributes:nil error:&error];
//
//        if (error) {
//            NSLog(@"Unable to create directory for user.");
//        }
//    }
//}
//
//- (void)prepareData {
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
//    NSError *error = nil;
//    NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.filePath error:&error];
//
//    if ([contents count] && !error){
//        NSLog(@"Contents of the user's directory. %@", contents);
//        // Reading USER profile image from Directory //
//        for (NSString *fileName in contents) {
//            if ([fileName rangeOfString:@".securedData"].length > 0) {
//                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
//                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
//                UIImage *image = [UIImage imageWithData:decryptedData];
//                self.profileImageViewer.image = image;
//
//
//            } else {
//                NSLog(@"This file is not secured.");
//            }
//        }
//        // Reading USER First Name from Directory //
//        for (NSString *fileName in contents) {
//            if ([fileName rangeOfString:@".securedFirstName"].length > 0) {
//                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
//                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
//                NSString *firstName = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
//                self.firstNameTextField.text = firstName;
//
//
//            } else {
//                NSLog(@"This file is not secured.");
//            }
//        }
//        // Reading USER Last Name from Directory //
//        for (NSString *fileName in contents) {
//            if ([fileName rangeOfString:@".securedLastName"].length > 0) {
//                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
//                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
//                NSString *lastName = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
//                self.lastNameTextField.text = lastName;
//
//
//            } else {
//                NSLog(@"This file is not secured.");
//            }
//        }
//        // Reading USER Email from Directory //
//        for (NSString *fileName in contents) {
//            if ([fileName rangeOfString:@".securedEmail"].length > 0) {
//                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
//                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
//                NSString *userEmail = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
//                self.emailTextField.text = userEmail;
//
//
//            } else {
//                NSLog(@"This file is not secured.");
//            }
//        }
//        // Reading USER Phone Number from Directory //
//        for (NSString *fileName in contents) {
//            if ([fileName rangeOfString:@".securedPhoneNumber"].length > 0) {
//                NSData *data = [NSData dataWithContentsOfFile:[self.filePath stringByAppendingPathComponent:fileName]];
//                NSData *decryptedData = [RNDecryptor decryptData:data withSettings:kRNCryptorAES256Settings password:@"A_SECRET_PASSWORD" error:nil];
//                NSString *userPhoneNumber = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
//                self.phoneTextField.text = userPhoneNumber;
//
//
//            } else {
//                NSLog(@"This file is not secured.");
//            }
//        }
//
//    } else if (![contents count]) {
//        if (error) {
//            NSLog(@"Unable to read the contents of the user's directory.");
//        } else {
//            NSLog(@"The user's directory is empty.");
//        }
//    }
//}

@end
