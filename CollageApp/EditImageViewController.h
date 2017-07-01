//
//  EditImageViewController.h
//  CollageApp
//
//  Created by 鈴木千早 on 2015/11/16.
//  Copyright © 2015年 Chihaya Suzuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxFrame.h"

@interface EditImageViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate,UIGestureRecognizerDelegate>
@property UIImageView *imageView;
@property UIImage *image1;
@property UIImage *image2;

@end
