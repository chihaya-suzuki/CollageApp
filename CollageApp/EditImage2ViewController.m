//
//  EditImage2ViewController.m
//  CollageApp
//
//  Created by 鈴木千早 on 2015/11/16.
//  Copyright © 2015年 Chihaya Suzuki. All rights reserved.
//

#import "EditImage2ViewController.h"

@interface EditImage2ViewController ()
@property CGRect originalRect;
// 操作前の変換情報
@property CATransform3D originalTransform;

// 画像のあるレイヤー
@property(strong) CALayer *imageLayer;

// 動かすときの作業レイヤー
@property(strong) CALayer *touchLayer;
@property UIImageView *imageView;
@property UIImage *image1;
@property UIImage *image2;

@end

@implementation EditImage2ViewController
{
    enum TAG{CAMERA=100,READ,STYLE};
    enum SLIDERTAG{SIZE=200,ALPHA};
    
    // iPad専用ビューコントローラーを使う
    __strong UIPopoverController *_popoverController;
    
    UIView *_baseView;
    CGFloat _radian;
    CGFloat _alpha;
    UISlider *_alphaSlider;
    UISlider *_sizeSlider;
    UISegmentedControl *_segmentCtrl;
    BoxFrame *_boxDraw;
    CGRect _originalRect;
    CATransform3D _originalTransform;
    CALayer *_imageLayer;
    CALayer *_touchLayer;
    UIImageView *_imageView;
    UIImage *_image1;
    UIImage *_image2;
    CATransform3D _resetTransform;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Image2";
    
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

    // セグメントコントロール
    UISegmentedControl *segmentCtrl = [[UISegmentedControl alloc]initWithItems:@[@"□",@"○"]];
    segmentCtrl.frame = CGRectMake(20,44+20+20,CGRectGetMaxX(self.view.frame)-40,30);
    segmentCtrl.selectedSegmentIndex = 0;
    [segmentCtrl addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    segmentCtrl.tintColor = [UIColor grayColor];
    [self.view  addSubview:segmentCtrl];
    _segmentCtrl = segmentCtrl;
    
    // 円土台View
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake( 0, (CGRectGetMaxY(self.view.frame)-44+44+20)/2-CGRectGetMaxX(self.view.frame)/2, CGRectGetMaxX(self.view.frame), CGRectGetMaxX(self.view.frame))];
    baseView.clipsToBounds = YES;
    [self.view addSubview:baseView];
    _baseView = baseView;

    // アイコンImageView
    UIImage *sizeIcon = [UIImage imageNamed:@"resize.png"];
    UIImageView *sizeIconView = [[UIImageView alloc]initWithFrame:CGRectMake(10,CGRectGetMaxY(self.view.frame)-44-80,30,30)];
    sizeIconView.backgroundColor = [UIColor clearColor];
    sizeIconView.clipsToBounds = YES;
    sizeIconView.contentMode = UIViewContentModeScaleAspectFit;
    sizeIconView.image = sizeIcon;
    [self.view addSubview:sizeIconView];

    UISlider *sizeSlider = [[UISlider alloc]init];
    sizeSlider.frame = CGRectMake(50,CGRectGetMaxY(self.view.frame)-44-90,CGRectGetMaxX(self.view.frame)-60,50);
    // スライダー最小値
    sizeSlider.minimumValue = 20;
    // スライダー最大値
    sizeSlider.maximumValue = CGRectGetMaxX(self.view.frame);
    // 現在値
    sizeSlider.value = CGRectGetMaxX(self.view.frame);
    sizeSlider.tag = SIZE;
    [sizeSlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sizeSlider];
    _sizeSlider = sizeSlider;
    
    // アイコンImageView
    UIImage *alphaIcon = [UIImage imageNamed:@"eye_open.png"];
    UIImageView *alphaIconView = [[UIImageView alloc]initWithFrame:CGRectMake(10,CGRectGetMaxY(self.view.frame)-44-40,30,30)];
    alphaIconView.backgroundColor = [UIColor clearColor];
    alphaIconView.clipsToBounds = YES;
    alphaIconView.contentMode = UIViewContentModeScaleAspectFit;
    alphaIconView.image = alphaIcon;
    [self.view addSubview:alphaIconView];

    UISlider *alphaSlider = [[UISlider alloc]init];
    alphaSlider.frame = CGRectMake(50,CGRectGetMaxY(self.view.frame)-44-50,CGRectGetMaxX(self.view.frame)-60,50);
    // スライダー最小値
    alphaSlider.minimumValue = 0.1;
    // スライダー最大値
    alphaSlider.maximumValue = 1;
    // 現在値
    alphaSlider.value = 1;
    alphaSlider.tag = ALPHA;
    [alphaSlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:alphaSlider];
    _alphaSlider = alphaSlider;

    UIImage *image2;
    CALayer *layer = [CALayer layer];
    _resetTransform = layer.transform;

    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    // 以前保存されたものがあれば読み込み
    if([UIImage imageWithData:[pref dataForKey:@"image2original"]]){
        // オリジナル画像
        image2 = [UIImage imageWithData:[pref dataForKey:@"image2original"]];
        // レイヤー
        NSData *layerData = [pref dataForKey:@"layer"];
        layer = [NSKeyedUnarchiver unarchiveObjectWithData:layerData];
        CGRect image2frame = CGRectFromString([pref stringForKey:@"image2frame"]);
        _baseView.frame = image2frame;
        
        alphaSlider.value = [pref floatForKey:@"image2alpha"];
        layer.opacity = [pref floatForKey:@"image2alpha"];
        sizeSlider.value = [pref floatForKey:@"image2size"];
    }else{
        // 無ければNO PHOTO画像
        image2 = [UIImage imageWithData:[pref dataForKey:@"image2"]];
        
        layer.frame = CGRectMake(0,0,image2.size.width,image2.size.height);
        layer.contents = (id)image2.CGImage;
        
        // レイヤーに名前を付けておく
        layer.name = @"image";
        
        CGFloat scale = _baseView.frame.size.width / image2.size.width;
        self.originalRect = layer.frame;
        
        // 矩形情報を変化させる
        CGRect rect = layer.frame;
        rect.size.width = self.originalRect.size.width * scale;
        rect.size.height = self.originalRect.size.height * scale;
        
        // 変化させたものを反映
        rect.origin.x = 0;
        rect.origin.y = 0;
        layer.frame = rect;
    }
    
    // 枠線描画
    BoxFrame *boxDraw =
    [[BoxFrame alloc] initWithFrame:_baseView.frame];
    boxDraw.backgroundColor = [UIColor clearColor];
    [self.view addSubview:boxDraw];
    _boxDraw = boxDraw;

    _boxDraw.square = [pref boolForKey:@"square"];
    if(_boxDraw.square){
        segmentCtrl.selectedSegmentIndex = 0;
        _baseView.layer.cornerRadius = 0;
        _boxDraw.square = YES;
    }else{
        segmentCtrl.selectedSegmentIndex = 1;
        _baseView.layer.cornerRadius = _sizeSlider.value / 2.0;
        _boxDraw.square = NO;
    }

    _image2 = image2;
    _imageLayer = layer;
    [_baseView.layer addSublayer:layer];
    
    // 土台のレイヤーにも名前をつけておく
    _baseView.layer.name = @"base";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// パン検知したとき
-(void)pan:(UIPanGestureRecognizer*)gesture
{
    // ドラッグで移動した距離を取得する
    CGPoint pointMove = [gesture translationInView:_baseView];
//    CGPoint pointTouch = [gesture locationInView:_baseView];
    
    // タッチした位置にあったレイヤーの取得
//    CALayer *layer = [_baseView.layer hitTest:pointTouch];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    // ここにアニメーションさせるコードを書く
    // 移動した距離だけ、UIImageViewのcenterポジションを移動させる
    CGPoint movedPoint = CGPointMake(_imageLayer.position.x + pointMove.x, _imageLayer.position.y + pointMove.y);
    _imageLayer.position = movedPoint;
    // commitでアニメーション設定完了
    [CATransaction commit];
    
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
    _image2 = newImage;
    _imageLayer.contents = (id)_image2.CGImage;
    
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
    NSData *imageData2 = UIImagePNGRepresentation(_image2);
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    _imageLayer.opacity = 1;
    NSData *layerData = [NSKeyedArchiver archivedDataWithRootObject:_imageLayer];
    [pref setObject:layerData forKey:@"layer"];
    [pref setObject:imageData forKey:@"image2"];
    [pref setObject:NSStringFromCGRect(_baseView.frame) forKey:@"image2frame"];
    
    NSLog(@"%@",NSStringFromCGRect(_baseView.frame));
    
    [pref setObject:imageData2 forKey:@"image2original"];
    [pref setFloat:_alphaSlider.value forKey:@"image2alpha"];
    [pref setFloat:_sizeSlider.value forKey:@"image2size"];
    [pref setBool:_boxDraw.square forKey:@"square"];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // ジェスチャを同時に認識する
    return YES;
}

-(void)sliderChange:(UISlider*)slider
{
    if(slider.tag == ALPHA){
        _imageLayer.opacity = slider.value;
        _alpha = slider.value;
    }else if(slider.tag == SIZE){
        _baseView.frame = CGRectMake(((CGRectGetMaxX(self.view.frame))-slider.value)/2, (CGRectGetMaxY(self.view.frame)-44+44+20)/2-slider.value/2, slider.value, slider.value);
        _boxDraw.frame = _baseView.frame;
        if(_segmentCtrl.selectedSegmentIndex == 1) _baseView.layer.cornerRadius = slider.value / 2.0;
        [_imageLayer setAnchorPoint:CGPointMake(0, 0)];
        [_imageLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
    }
}

-(void)segmentChange:(UISegmentedControl*)segmentCtrl
{
    if(segmentCtrl.selectedSegmentIndex == 0){
        _baseView.layer.cornerRadius = 0;
        _boxDraw.square = YES;
    }else{
        _baseView.layer.cornerRadius = _sizeSlider.value / 2.0;
        _boxDraw.square = NO;
    }
}
@end
