//
//  CYCreateQRCodeViewController.h
//  QRCode
//
//  Created by dev on 2018/8/2.
//  Copyright © 2018年 chun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYCreateQRCodeContentView.h"

@interface CYCreateQRCodeViewController : UIViewController
@property (nonatomic, strong) CYCreateQRCodeContentView *contentView;

@property (nonatomic, strong) UIImage * qrImage;
@property (nonatomic, copy) NSString * qrString;
@end
