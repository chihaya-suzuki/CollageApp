//
//  EditImageViewController.m
//  CollageApp
//
//  Created by 鈴木千早 on 2015/11/16.
//  Copyright © 2015年 Chihaya Suzuki. All rights reserved.
//

#import "EditImageViewController.h"

@interface EditImageViewController ()
@property CGRect originalRect;
// 操作前の変換情報
@property CATransform3D originalTransform;

// 画像のあるレイヤー
@property(strong) CALayer *imageLayer;

// 動かすときの作業レイヤー
@property(strong) CALayer *touchLayer;

@end

@implementation EditImageViewController
{
    enum TAG{CAMERA=100,READ};

    // iPad専用ビューコントローラーを使う
    __strong UIPopoverController *_popoverController;
    
    UIView *_baseView;
    CGFloat _radian;
    
    CATransform3D _resetTransform;
    CGRect _resetRect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Image1";
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    
    // ピンチジェスチャー
    UIPinchGestureRecognizer *pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pgr.delegate = self;
    [self.view addGestureRecognizer:pgr];
    
    // ローテーション
    UIRotationGestureRecognizer *rgr = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotation:)];
    rgr.delegate = self;
    [self.view addGestureRecognizer:rgr];

    // ドラッグ
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];

    // 画像土台UIView
    UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake( 0, (CGRectGetMaxY(self.view.frame)-44+44+20)/2-CGRectGetMaxX(self.view.frame)/2, CGRectGetMaxX(self.view.frame), CGRectGetMaxX(self.view.frame))];
    baseView.backgroundColor = [UIColor whiteColor];
    baseView.clipsToBounds = YES;
    baseView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:baseView];
    _baseView = baseView;
    
    // 画像読み込み
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    UIImage *image1 = [UIImage imageWithData:[pref dataForKey:@"image1"]];
    _image1 = image1;

    // レイヤーの作成
    CALayer *layer = [CALayer layer];
    _resetTransform = layer.transform;
    
    layer.frame = CGRectMake(0,0,image1.size.width,image1.size.height);
    layer.contents = (id)image1.CGImage;
    
    // レイヤーに名前を付けておく
    layer.name = @"image";
    _imageLayer = layer;
    [baseView.layer addSublayer:layer];

    CGFloat scale = baseView.frame.size.width / image1.size.width;
    self.originalRect = layer.frame;
    
    // 矩形情報を変化させる
    CGRect rect = layer.frame;
    rect.size.width = self.originalRect.size.width * scale;
    rect.size.height = self.originalRect.size.height * scale;
    
    // 変化させたものを反映
    rect.origin.x = 0;
    rect.origin.y = 0;
    layer.frame = rect;
    
    // 土台のレイヤーにも名前をつけておく
    baseView.layer.name = @"base";
    
    // 枠線描画
    BoxFrame *boxDraw =
    [[BoxFrame alloc] initWithFrame:baseView.frame];
    boxDraw.backgroundColor = [UIColor clearColor];
    boxDraw.square = YES;
    [self.view addSubview:boxDraw];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ローテーション検知したとき
-(void)pan:(UIPanGestureRecognizer*)gesture
{
    // ドラッグで移動した距離を取得する
    CGPoint point = [gesture translationInView:_baseView];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    // ここにアニメーションさせるコードを書く
    // 移動した距離だけ、UIImageViewのcenterポジションを移動させる
    CGPoint movedPoint = CGPointMake(_imageLayer.position.x + point.x, _imageLayer.position.y + point.y);
    _imageLayer.position = movedPoint;
    // commitでアニメーション設定完了
    [CATransaction commit];

    // ドラッグで移動した距離を初期化する
    // これを行わないと、[sender translationInView:]が返す距離は、ドラッグが始まってからの蓄積値となるため、
    // 今回のようなドラッグに合わせてImageを動かしたい場合には、蓄積値をゼロにする
    [gesture setTranslation:CGPointZero inView:_baseView];
}

// ピンチ、ズームの処理
-(void)pinch:(UIPinchGestureRecognizer*)gesture
{
    CGFloat scale = gesture.scale;
    
    NSLog(@"scale=%f",scale);
    
    CALayer *layer = _imageLayer;
    
    // ジェスチャー開始したとき
    if( gesture.state == UIGestureRecognizerStateBegan ) {
        // 元々の画像の矩形情報を保存しておく
        self.originalRect = layer.bounds;
    }
    
    // 矩形情報を変化させる
    CGRect rect = layer.bounds;
    rect.size.width = self.originalRect.size.width * scale;
    rect.size.height = self.originalRect.size.height * scale;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    // ここにアニメーションさせるコードを書く
    // 変化させたものを反映
    layer.bounds = rect;
    // commitでアニメーション設定完了
    [CATransaction commit];

}

// ローテーション検知したとき
-(void)rotation:(UIRotationGestureRecognizer*)gesture
{
    CALayer *layer = _imageLayer;
    
    if( gesture.state == UIGestureRecognizerStateBegan ) {
        // 元々の変換情報を保存する
        self.originalTransform = layer.transform;
    }
    
    // 回転はラジアンで得られる
    CGFloat radian = gesture.rotation;
    
    // NSLog表示用にラジアンから角度に戻す
    float angle = radian / (M_PI/180);
    NSLog(@"角度%d radian=%f",(int)angle,radian);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    // ここにアニメーションさせるコードを書く
    // 回転をZ軸方向へ適用する
    layer.transform = CATransform3DRotate(self.originalTransform, radian, 0, 0, 1);
    // commitでアニメーション設定完了
    [CATransaction commit];

    _radian = radian;
}

- (IBAction)action:(UIBarButtonItem *)sender
{
    if( sender.tag == CAMERA ) {
        [self openPicker:UIImagePickerControllerSourceTypeCamera tag:sender.tag];
    }else if( sender.tag == READ ) {
        [self openPicker:UIImagePickerControllerSourceTypePhotoLibrary tag:sender.tag];
    }
}

-(void)openPicker:(UIImagePickerControllerSourceType)sourceType tag:(NSInteger)tag
{
    if( ![UIImagePickerController isSourceTypeAvailable:sourceType] ) {
        return;
    }
    
    // 次の画面となるイメージピッカーコントローラーの作成
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    
    // 吹き出しを出すため押されたボタンを得ておく
    UIView *view = [self.view viewWithTag:tag];
    
    // iOS8以上ならUIPopoverPresentationControllerを使う
    if( [[UIDevice currentDevice].systemVersion floatValue] >= 8) {
        // UIPopoverPresentationControllerが使える
        
        // まずmodalPresentationStyleをPopoverで設定する
        picker.modalPresentationStyle = UIModalPresentationPopover;
        
        // 遷移させたい画面からUIPopoverPresentationControllerインスタンスを得る
        UIPopoverPresentationController *presentationController = [picker popoverPresentationController];
        
        // デリゲート設定
        presentationController.delegate = self;
        
        // 吹き出しを出す方向の指定
        presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        // 吹き出しを出すビューの画面部品の指定
        presentationController.sourceView = view;
        presentationController.sourceRect = view.bounds;
        // 独自の矩形で指定したい場合はこちら
        //    presentationController.sourceRect = CGRectMake(300,300,50,50);
        
        // 画面遷移
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        // そうでない場合はUIPopoverControllerしか存在しない(iPad専用)
        
        /* iPadかどうか調べる */
        
        // iPadか？
        if( [[UIDevice currentDevice].model rangeOfString:@"iPad"].location == NSNotFound ) {
            
            /* iPhone(iPod含む) */
            [self presentViewController:picker animated:YES completion:nil];
            
        } else {
            /* Pad */
            
            //PopOverコントローラーの作成
            _popoverController = [[UIPopoverController alloc]initWithContentViewController:picker];
            // popOverコントローラーの表示
            [_popoverController presentPopoverFromRect:view.bounds inView:view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            _popoverController.delegate = self;
        }
    }
}

// 画像が選ばれたとき
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _imageLayer.transform = _resetTransform;
    _radian = 0;

    // 画像を得る
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    // イメージビューのサイズで新しいグラフィックスの作成開始
    UIGraphicsBeginImageContext(image.size);
    // 一つ目の画像を描く
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height) blendMode:kCGBlendModeNormal alpha:1];
    
    // 合成された画像の取得
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    _image1 = newImage;
    _imageLayer.contents = (id)_image1.CGImage;

    // グラフィックス作成おしまい
    UIGraphicsEndImageContext();
    
    CGFloat scale;
    
    _imageLayer.frame = CGRectMake(0,0,image.size.width,image.size.height);
//    _imageLayer.contents = (id)image.CGImage;
    
    if(newImage.size.width > newImage.size.height){
        scale = _baseView.frame.size.width / newImage.size.width;
    }else{
        scale = _baseView.frame.size.height / newImage.size.width;
    }
    
    self.originalRect = _imageLayer.frame;
    
    // 矩形情報を変化させる
    CGRect rect = _imageLayer.frame;
    rect.size.width = self.originalRect.size.width * scale;
    rect.size.height = self.originalRect.size.height * scale;
    
    // 変化させたものを反映
    rect.origin.x = 0;
    rect.origin.y = 0;
    _imageLayer.frame = rect;
    
    // 画面隠れる
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    // OpaqueueをNOにすると透過したキャプチャが取れる
    UIGraphicsBeginImageContextWithOptions(_baseView.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [_baseView.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    NSData *imageData = UIImagePNGRepresentation(image);
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:imageData forKey:@"image1"];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // ジェスチャを同時に認識する
    return YES;
}

@end
