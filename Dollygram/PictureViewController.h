//
//  PictureViewController.h
//  testProjForUsingImages
//
//  Created by Evan Vandenberg on 2/2/15.
//  Copyright (c) 2015 Evan Vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
