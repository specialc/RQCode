//
//  CYQRCodeViewController.m
//  testRQCode
//
//  Created by dev on 2018/6/22.
//  Copyright © 2018年 dev. All rights reserved.
//

#import "CYQRCodeViewController.h"
#import "CYQRCodeContentView.h"
#import "CYQRCodeManager.h"
#import "CYCreateQRCodeViewController.h"
#import <Photos/Photos.h>//相册

@interface CYQRCodeViewController () <CYQRCodeContentViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) CYQRCodeContentView *contentView;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, assign) BOOL showOpenCameraTip;
@property (nonatomic, assign) BOOL showNoCameraTip;
@end

@implementation CYQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 细节: 本界面上设置, 下个界面上显示
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.showOpenCameraTip = YES;
    self.showNoCameraTip = YES;
    [self addSubviews]; 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    [self.contentView.scanView startScanAnimation];
    // 判断是否允许打开摄像头
    if ([self canOpenCamera]) {
        [self.contentView.qrCodeManager sessionStartRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.contentView.scanView stopScanAnimation];
    [self.contentView.scanView finishedHandle];
    [self.contentView.scanView showFlashlightButton:NO];
    [self.contentView.qrCodeManager sessionStopRunning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma -- addSubviews

- (void)addSubviews {
    [self.view addSubview:self.contentView];
}

- (CYQRCodeContentView *)contentView {
    if (!_contentView) {
        _contentView = [[CYQRCodeContentView alloc] initWithFrame:self.view.bounds];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.delegate = self;
    }
    return _contentView;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        _imagePickerController.allowsEditing = YES;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePickerController;
}

#pragma mark -- CYQRCodeContentViewDelegate

- (void)qrCodeContentView:(CYQRCodeContentView *)contentView viewDidTouch:(id)sender {
    if (sender == contentView.backButton) {
        [self didClickBackButton:contentView.backButton];
    }
    else if (sender == contentView.photoButton) {
        [self didClickPhotoButton:contentView.photoButton];
    }
}

- (void)qrCodeContentView:(CYQRCodeContentView *)contentView scanView:(CYScanView *)scanView viewDidTouch:(id)sender {
    if (sender == scanView.myQRCodeButton) {
        [self didClickMyQRCodeButton:scanView.myQRCodeButton];
    }
    else if (sender == scanView.flashlightButton) {
        [self didClickFlashlightButton:scanView.flashlightButton contentView:contentView scanView:scanView];
    }
}

- (void)qrCodeContentView:(CYQRCodeContentView *)contentView qrCodeManager:(CYQRCodeManager *)qrCodeManager scanFinished:(NSString *)scanString {
    NSLog(@"qrCodeContentView:qrCodeManager:scanFinished");
    [self.contentView.scanView handlingResultsOfScan];
    [self.contentView.qrCodeManager sessionStopRunning];
    [self.contentView.qrCodeManager openFlashSwitch:NO];
    
    [self playScanFinishedSound];
    [self handleForCreateQRCodeViewController:scanString];
}

#pragma mark -- UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"didFinishPickingMediaWithInfo---------info:%@",info);
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        [UIView animateWithDuration:0.25 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }];
    
    [self.contentView.qrCodeManager scanQRCodeImageWithInfo:info];
}

#pragma mark - TouchEvents

- (void)didClickBackButton:(UIButton *)sender {
    NSLog(@"didClickBackButton");
    if (self.presentingViewController && (self.navigationController.viewControllers.count == 1 || !self.navigationController)) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didClickPhotoButton:(UIButton *)sender {
    NSLog(@"didClickPhotoButton");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
    else {
        NSLog(@"不支持访问相册");
    }
}

- (void)didClickMyQRCodeButton:(UIButton *)sender {
    NSLog(@"didClickMyQRCodeButton");
    CYCreateQRCodeViewController *createQRCodeController = [[CYCreateQRCodeViewController alloc] init];
    createQRCodeController.qrImage =  [CYQRCodeManager createQRCodeImageWithString:@"BEGIN:VCARD\nFN:张春咏\nORG:上海景格科技股份有限公司\nADR;TYPE=WORK:;;上海市嘉定区\nTITLE:移动开发工程师\nTEL;CELL:13323940418\nEMAIL;TYPE=PREF,INTERNET:2248895786@qq.com\nEND:VCARD" andSize:CGSizeMake(250, 250) andBackColor:[UIColor whiteColor] andFrontColor:[UIColor blackColor] andCenterImage:[UIImage imageNamed:@"qrCode_bg"]];
    createQRCodeController.qrString = @"BEGIN:VCARD\nFN:张春咏\nORG:上海景格科技股份有限公司\nADR;TYPE=WORK:;;上海市嘉定区\nTITLE:移动开发工程师\nTEL;CELL:13323940418\nEMAIL;TYPE=PREF,INTERNET:2248895786@qq.com\nEND:VCARD";
    [self.navigationController pushViewController:createQRCodeController animated:YES];
}

- (void)didClickFlashlightButton:(UIButton *)sender contentView:(CYQRCodeContentView *)contentView scanView:(CYScanView *)scanView {
    NSLog(@"didClickFlashlightButton");
    
    scanView.flashlightOpen = !scanView.flashlightOpen;
    [contentView.qrCodeManager openFlashSwitch:scanView.flashlightOpen];
}

#pragma mark - Method

- (void)playScanFinishedSound {
    // 1.获得音效文件的路径
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"scanFinished.mp3" withExtension:nil];
    // 2.加载音效文件，得到对应的音效ID
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
    // 3.播放音效
    AudioServicesPlaySystemSound(soundID);
}

- (void)handleForCreateQRCodeViewController:(NSString *)scanString {
    CYCreateQRCodeViewController *createQRCodeController = [[CYCreateQRCodeViewController alloc] init];
    createQRCodeController.qrImage =  [CYQRCodeManager createQRCodeImageWithString:scanString andSize:CGSizeMake(250, 250) andBackColor:[UIColor whiteColor] andFrontColor:[UIColor blackColor] andCenterImage:[UIImage imageNamed:@"qrCode_bg"]];
    createQRCodeController.qrString = scanString;
    [self.navigationController pushViewController:createQRCodeController animated:YES];
}

- (BOOL)canOpenCamera {
    // 先判断摄像头硬件是否好用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 用户是否允许摄像头使用
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        // 不允许，则弹出提示框
        if (authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied) {
            NSLog(@"摄像头访问受限，前往设置");
            if (self.showOpenCameraTip == NO) {
                return NO;
            }
            //用户未开启权限
            @weakify(self);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"需要访问你的相机" message:@"请在系统设置中开启相机服务(设置>APP>相机>开启)" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"取消");
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"设置");
                @strongify(self);
                [self handleForSystemSetting];
            }]];
            self.showOpenCameraTip = NO;
            [self presentViewController:alertController animated:YES completion:nil];
            return NO;
        }
        else {
            // 这里是摄像头可以使用的处理逻辑
            return YES;
        }
    }
    else {
        // 硬件问题提示
        NSLog(@"请检查手机摄像头设备是否可用");
        if (self.showNoCameraTip == NO) {
            return NO;
        }
        // 摄像头设备不可用
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"摄像头不可用" message:@"请检查手机摄像头设备是否可用" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"关闭提示" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"关闭提示");
        }]];
        self.showNoCameraTip = NO;
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
}

- (void)handleForSystemSetting {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark -

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
