//
//  CameraViewController.h
//  FinalProject
//
//  Created by Moshood Adeaga on 18/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController <UIPopoverPresentationControllerDelegate>
- (IBAction)saveButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButtonProperty;

- (IBAction)cancelAction:(UIButton *)sender;

@end
