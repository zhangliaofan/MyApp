//
//  ViewController.m
//  MyApp
//
//  Created by BGYK on 2021/1/27.
//

#import "ViewController.h"
#import <Flutter/Flutter.h>

typedef void(^blockType)(NSData *);
@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic,strong) FlutterMethodChannel *methodChannel;
@property(nonatomic,strong) FlutterViewController *flutterViewController;
@property(nonatomic,strong) blockType result;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //1. 创建 FlutterViewController
    self.flutterViewController = (FlutterViewController *)[segue destinationViewController];
    //2. 创建 methodChannel
    self.methodChannel = [FlutterMethodChannel methodChannelWithName:@"imageChannel" binaryMessenger:self.flutterViewController.binaryMessenger];
    //3. 响应 Flutter 端发的请求，并回传数据
    __weak typeof(self) weakSelf = self;
    [self.methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            // 1.判断 方法名是否相等
        if([call.method isEqualToString:@"selectImage"]){
            // 2.调用 打开相册方法
            [weakSelf presentImagePickerController];
            // 3.block 赋值
            weakSelf.result = result;
        }
    }];
}

-(void)presentImagePickerController{
        // 1.判断 是否能打开
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
        // 2.创建 相册控制器
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        // 3.设置 相册类型(所有)
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 4.设置 代理
        imagePickerController.delegate = self;
        // 5. modal 相册控制器
        [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark -- <UIImagePickerControllerDelegate>--
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //1.销毁 相册控制器
    [picker dismissViewControllerAnimated:YES completion:^{
        // 2. 选中的图片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        // 3. 图片转 NSData
        NSData *data = UIImagePNGRepresentation(image);
        // 4. 回传 二进制数据
        self.result(data);
    }];
}

@end
