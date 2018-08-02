//
//  CYCreateQRCodeContentView.h
//  testRQCode
//
//  Created by dev on 2018/6/22.
//  Copyright © 2018年 dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYCreateQRCodeContentView;
@protocol CYCreateQRCodeContentViewDelegate <NSObject>
- (void)createQRCodeContentView:(CYCreateQRCodeContentView *)contentView viewDidTouch:(id)sender;

@optional

@end

@interface CYCreateQRCodeContentView : UIView
@property (nonatomic, weak) id<CYCreateQRCodeContentViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *qrImageView;
@property (nonatomic, strong) UILabel *urlLabel;

@property (nonatomic, strong) UIImage * qrImage;
@property (nonatomic, copy) NSString * qrString;
@end
