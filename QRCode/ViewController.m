//
//  ViewController.m
//  QRCode
//
//  Created by dev on 2018/8/2.
//  Copyright © 2018年 chun. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CYTempViewController.h"
#import "CYBaseNavigationViewController.h"

//1. 有个素材
@interface ViewController ()
@property (nonatomic, strong) UIButton *qrCodeButton;

/** 2.输入设置 采集摄像头捕捉到的信息 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/** 3.输出设备 解析输入设备采集到的信息 */
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
/** 4. layer (特殊图层 能够展示摄像头采集到的画面) 展示输入设备采集到的信息 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;
/** 5.关联输入设备和输出设备 会话 */
@property (nonatomic, strong) AVCaptureSession *session;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.qrCodeButton];
    NSLog(@"viewDidLoad");
}

- (UIButton *)qrCodeButton {
    if (!_qrCodeButton) {
        _qrCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _qrCodeButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _qrCodeButton.frame = CGRectMake(0, 0, 250, 50);
        _qrCodeButton.center = CGPointMake(self.view.center.x, self.view.center.y);
        [_qrCodeButton setTitle:@"更多" forState:UIControlStateNormal];
        _qrCodeButton.backgroundColor = [UIColor whiteColor];
        [_qrCodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //关键语句
        _qrCodeButton.layer.cornerRadius = 2.0;//2.0是圆角的弧度，根据需求自己更改
        _qrCodeButton.layer.borderColor = [UIColor blackColor].CGColor;//设置边框颜色
        _qrCodeButton.layer.borderWidth = 1.0f;//设置边框颜色
        [_qrCodeButton addTarget:self action:@selector(didClickQRCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qrCodeButton;
}

- (void)didClickQRCodeButton:(UIButton *)sender {
    NSLog(@"didClickQRCodeButton");
    
    CYTempViewController *tempViewController = [[CYTempViewController alloc] init];
    CYBaseNavigationViewController *navController = [[CYBaseNavigationViewController alloc] initWithRootViewController:tempViewController];
    [self presentViewController:navController animated:YES completion:nil];
    
    
    //    // 1.创建输入设备
    //    //     AVMediaTypeVideo 摄像头
    //    //     AVMediaTypeAudio 麦克风
    //    //     AVCaptureDeviceInput  输入设备    default默认后置
    //    //    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //    NSArray *allDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //    self.input = [AVCaptureDeviceInput deviceInputWithDevice:[allDevice firstObject] error:nil];
    //    //2. 创建输出设备
    //    self.output = [[AVCaptureMetadataOutput alloc]init];
    //
    //    //解析 返回的数据
    //    //设置输出设备的代理 返回解析后的数据
    //    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //    //3.创建会话
    //    self.session = [[AVCaptureSession alloc]init];
    //    //4.关联 会话和设备
    //    if ([self.session canAddInput:self.input]) {
    //        [self.session addInput:self.input];
    //    }
    //
    //    if ([self.session canAddOutput:self.output]) {
    //        [self.session addOutput:self.output];
    //    }
    //    //告诉数据类型  AVMetadataObjectTypeQRCode 二维码
    //    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    //    // 扫描框大小  整个屏幕
    //    [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    //    //5.指定layer 的 frame  然后添加到 view上
    //    self.layer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    //    self.layer.frame = self.view.bounds;
    //    [self.view.layer addSublayer:self.layer];
    //
    //    //开启会话
    //    [self.session startRunning];
}

//扫描出结果后就会调用的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    AVMetadataMachineReadableCodeObject *objc = [metadataObjects firstObject];
    NSString *str = objc.stringValue;
    NSLog(@"str:%@",str);
    
    //停止扫描
    [self.session stopRunning];
    
    //移除 layer
    [self.layer removeFromSuperlayer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
