//
//  CYCreateQRCodeContentView.m
//  testRQCode
//
//  Created by dev on 2018/6/22.
//  Copyright © 2018年 dev. All rights reserved.
//

#import "CYCreateQRCodeContentView.h"

@interface CYCreateQRCodeContentView ()

@end

@implementation CYCreateQRCodeContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

#pragma mark - UI

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)addSubviews {
    [self addSubview:self.qrImageView];
    [self addSubview:self.urlLabel];
    
    [self addMasonry];
}

- (UIImageView *)qrImageView {
    if (!_qrImageView) {
        _qrImageView = [[UIImageView alloc] init];
        _qrImageView.contentMode = UIViewContentModeScaleAspectFill;
        _qrImageView.clipsToBounds = YES;
        _qrImageView.userInteractionEnabled = YES;
        [_qrImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapQrImageView:)]];
    }
    return _qrImageView;
}

- (UILabel *)urlLabel {
    if (!_urlLabel) {
        _urlLabel = [[UILabel alloc] init];
        _urlLabel.font = [UIFont systemFontOfSize:18];
        _urlLabel.textColor = [UIColor blackColor];
        _urlLabel.textAlignment = NSTextAlignmentCenter;
        _urlLabel.text = @" ";
        _urlLabel.numberOfLines = 0;
        _urlLabel.userInteractionEnabled = YES;
        [_urlLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUrlLabel:)]];
    }
    return _urlLabel;
}

#pragma mark - addMasonry

- (void)addMasonry {
    [self.qrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(120);
        make.centerX.equalTo(self);
        make.width.equalTo(250);
        make.height.equalTo(250);
    }];
    [self.urlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qrImageView.mas_bottom).offset(20);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.bottom.equalTo(self).offset(-15);
    }];
}

#pragma mark - TouchEvents

- (void)didTapQrImageView:(UITapGestureRecognizer *)gesture {
    if ([_delegate respondsToSelector:@selector(createQRCodeContentView:viewDidTouch:)]) {
        [_delegate createQRCodeContentView:self viewDidTouch:gesture.view];
    }
}

- (void)didTapUrlLabel:(UITapGestureRecognizer *)gesture {
    if ([_delegate respondsToSelector:@selector(createQRCodeContentView:viewDidTouch:)]) {
        [_delegate createQRCodeContentView:self viewDidTouch:gesture.view];
    }
}

#pragma mark - Methods

#pragma mark - Setter

- (void)setQrImage:(UIImage *)qrImage {
    _qrImage = qrImage;
    
    self.qrImageView.image = qrImage;
}

- (void)setQrString:(NSString *)qrString {
    _qrString = qrString;
    
    self.urlLabel.text = [NSString stringWithFormat:@"扫描结果：\n%@",qrString];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
