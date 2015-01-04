//
//  ViewController.m
//  ExifSample
//
//  Created by keygx on 2015/01/04.
//
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (deviceInput) {
        NSLog(@"%@", deviceInput);
    } else {
        NSLog(@"カメラなし");
    }
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setTextView:nil];
    [super viewDidUnload];
}

// PhotoAlbumボタンが押された時の処理
- (IBAction)photoAlbumButtonAction:(id)sender
{
    UIImagePickerControllerSourceType souceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:souceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = souceType;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

// 取得した画像を表示
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    // アルバムから
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        // PhotoAlbumの場合
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSDictionary *metadataDict = [representation metadata]; // ←ここにExifとかGPSの情報が入ってる
            NSLog(@"%@", metadataDict);
            
            self.textView.text = [metadataDict description];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
        // 画像を書き直す
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.imageView.image = image;
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 写真の保存が完了もしくは失敗した時に呼ばれるメソッド
- (void)savingImageIsFinished:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

// キャンセルボタンが押された時に呼ばれるメソッド
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
