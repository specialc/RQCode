//
//  CYCreateQRCodeViewController.h
//  testRQCode
//
//  Created by dev on 2018/6/22.
//  Copyright © 2018年 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYCreateQRCodeContentView.h"

@interface CYCreateQRCodeViewController : UIViewController
@property (nonatomic, strong) CYCreateQRCodeContentView *contentView;

@property (nonatomic, strong) UIImage * qrImage;
@property (nonatomic, copy) NSString * qrString;
@end
