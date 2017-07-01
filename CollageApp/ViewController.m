//
//  ViewController.m
//  CollageApp
//
//  Created by 鈴木千早 on 2015/11/16.
//  Copyright © 2015年 Chihaya Suzuki. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    enum TAG{NEW=100,IMAGE1,IMAGE2,PREVIEW,SAVE};
    
    UIView *_baseView;
    UIImage *_saveImage;
    CGRect _image2frame;
    UIImageView *_imageView;
    UIImageView *_imageView2;
    UIImage *_image1;
    UIImage *_image2;
    CALayer *_imageLayer;
    UIView *_layerBaseView;
    BoxFrame *_boxDraw1;
    BoxFrame *_boxDraw2;
    BOOL _preview;
    
    ACAccount *_account;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Main";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _preview = NO;

    // ドラッグ
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];

    // 全部消えてもらう
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    UIImage *image1 = [UIImage imageNamed:@"noimage.png"];
    UIImage *image2 = [UIImage imageNamed:@"noimage.png"];
    _image1 = image1;
    _image2 = image2;
    
    NSData *imageData1 = UIImagePNGRepresentation(image1);
    NSData *imageData2 = UIImagePNGRepresentation(image2);
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:imageData1 forKey:@"image1"];
    [pref setObject:imageData2 forKey:@"image2"];

    // 画像土台UIView
    UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake( 0, (CGRectGetMaxY(self.view.frame)-44+44+20)/2-CGRectGetMaxX(self.view.frame)/2, CGRectGetMaxX(self.view.frame), CGRectGetMaxX(self.view.frame))];
    baseView.backgroundColor = [UIColor whiteColor];
    baseView.clipsToBounds = YES;
    baseView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:baseView];
    _baseView = baseView;
    [pref setObject:NSStringFromCGRect(_baseView.frame) forKey:@"image2frame"];
    [pref setFloat:1.0 forKey:@"image2alpha"];
    
    // 画像表示エリア
    UIImageView *imageView = [[UIImageView alloc]init];
    _imageView = imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.frame = CGRectMake( 0, 0, CGRectGetMaxX(self.view.frame), CGRectGetMaxX(self.view.frame));
    imageView.image = image1;
    [baseView addSubview:imageView];
    
    // レイヤーの作成
    CALayer *layer = [CALayer layer];
    _imageLayer = layer;
    // レイヤーに名前を付けておく
    layer.name = @"image";
    
    layer.frame = CGRectMake(0,0,imageView.frame.size.width, imageView.frame.size.height);
    layer.opacity = 1;
    
    CGRect layerFrame = _imageLayer.frame;
    layerFrame.size = _image1.size;
    layerFrame.origin = CGPointMake(0,0);
    _imageLayer.frame = layerFrame;
    
    [baseView.layer addSublayer:layer];
    layer.contents = (id)image2.CGImage;
    
    // 枠線描画
    BoxFrame *boxDraw1 =
    [[BoxFrame alloc] initWithFrame:imageView.frame];
    boxDraw1.backgroundColor = [UIColor clearColor];
    boxDraw1.square = YES;
    [baseView addSubview:boxDraw1];
    _boxDraw1 = boxDraw1;
    
    BoxFrame *boxDraw2 =
    [[BoxFrame alloc] initWithFrame:imageView.frame];
    boxDraw2.backgroundColor = [UIColor clearColor];
    boxDraw2.square = YES;
    [baseView addSubview:boxDraw2];
    _boxDraw2 = boxDraw2;
    [pref setBool:YES forKey:@"square"];
}

// 画面戻った時
-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    // UserDefaultsからtextというキーの値を文字列で取得
    _image1 = [UIImage imageWithData:[pref dataForKey:@"image1"]];
    _image2 = [UIImage imageWithData:[pref dataForKey:@"image2"]];
    CGFloat alpha = [pref floatForKey:@"image2alpha"];
    
    _image2frame = CGRectFromString([pref objectForKey:@"image2frame"]);
    
    _imageView.image = _image1;
    _imageLayer.contents = (id)_image2.CGImage;
    _imageLayer.opacity = alpha;

    CGRect layerFrame = _imageLayer.frame;
    CGRect boxFrame2 = _boxDraw2.frame;
    CGRect layerBaseFrame = _layerBaseView.frame;
    
    layerFrame.size = _image2frame.size;
    _imageLayer.frame = layerFrame;
    
    boxFrame2.size = _image2frame.size;
    _boxDraw2.frame = boxFrame2;
    _boxDraw2.square = [pref boolForKey:@"square"];
    
    layerBaseFrame.size = _image2frame.size;
    _layerBaseView.frame = layerBaseFrame;
    
    NSLog(@"boxFrameOver:%@",NSStringFromCGRect(_boxDraw2.frame));
    NSLog(@"layerBaseView:%@",NSStringFromCGRect(_layerBaseView.frame));
    NSLog(@"layer:%@",NSStringFromCGRect(_imageLayer.frame));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ジェスチャー操作
-(void)pan:(UIPanGestureRecognizer*)gesture
{
    // ドラッグで移動した距離を取得する
    CGPoint point = [gesture translationInView:_layerBaseView];
    
    // タッチ位置でhitTestをして、さわったレイヤーを得る
//    CALayer *layer = [_layerBaseView.layer hitTest:point];
//    NSLog(@"layer:%@",layer);
    
//    if(layer == _imageLayer){
    if(1){
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        // ここにアニメーションさせるコードを書く
        // 移動した距離だけ、UIImageViewのcenterポジションを移動させる
        CGPoint movedPoint = CGPointMake(_imageLayer.position.x + point.x, _imageLayer.position.y + point.y);
        CGPoint movedPoint2 = CGPointMake(_boxDraw2.frame.origin.x + point.x, _boxDraw2.frame.origin.y + point.y);

//        layer.position = movedPoint;
        _imageLayer.position = movedPoint;
        NSLog(@"%@",NSStringFromCGPoint(_imageLayer.position));
        
        CGRect boxFrameOver = _boxDraw2.frame;
        boxFrameOver.origin = movedPoint2;
        _boxDraw2.frame = boxFrameOver;

        // commitでアニメーション設定完了
        [CATransaction commit];
    }

    [gesture setTranslation:CGPointZero inView:_baseView];
}

#pragma mark - 各ボタン target action
- (IBAction)action:(UIBarButtonItem *)sender
{
    if( sender.tag == IMAGE1 ) {
        [self performSegueWithIdentifier:@"EditImage1" sender:self];
    }else if( sender.tag == IMAGE2 ) {
        [self performSegueWithIdentifier:@"EditImage2" sender:self];
    }else if( sender.tag == NEW ) {
        [self new];
    }else if( sender.tag == PREVIEW ) {
        if(_preview){
            _boxDraw1.hidden = NO;
            _boxDraw2.hidden = NO;
            _preview = NO;
        }else{
            _boxDraw1.hidden = YES;
            _boxDraw2.hidden = YES;
            _preview = YES;
        }
    }else if( sender.tag == SAVE ) {
        [self save];
    }
}

-(void)new
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    UIImage *image1 = [UIImage imageNamed:@"noimage.png"];
    UIImage *image2 = [UIImage imageNamed:@"noimage.png"];
    _image1 = image1;
    _image2 = image2;
    
    NSData *imageData1 = UIImagePNGRepresentation(image1);
    NSData *imageData2 = UIImagePNGRepresentation(image2);
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:imageData1 forKey:@"image1"];
    [pref setObject:imageData2 forKey:@"image2"];
    
    _imageView.image = _image1;
    _imageLayer.contents = (id)_image2.CGImage;
    _imageLayer.opacity = 1;
    
    CGRect layerFrame = _imageLayer.frame;
    layerFrame.size = _baseView.frame.size;
    layerFrame.origin = CGPointMake(0,0);
    _imageLayer.frame = layerFrame;
    
    CGRect boxFrame2 = _boxDraw2.frame;
    boxFrame2.size = _baseView.frame.size;
    boxFrame2.origin = CGPointMake(0,0);
    _boxDraw2.frame = boxFrame2;
    _boxDraw2.square = YES;
    
    [pref setObject:NSStringFromCGRect(_baseView.frame) forKey:@"image2frame"];
    [pref setFloat:1.0 forKey:@"image2alpha"];
    [pref setBool:YES forKey:@"square"];
}

-(void)save
{
    // 枠線非表示
    if(_preview == NO){
        _boxDraw1.hidden = YES;
        _boxDraw2.hidden = YES;
    }
    
    // OpaqueueをNOにすると透過したキャプチャが取れる
    UIGraphicsBeginImageContextWithOptions(_baseView.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [_baseView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // フォトアルバムへの書き込み セレクタで指定するメソッドはドキュメントに書かれているそのままのメソッド名
    UIImageWriteToSavedPhotosAlbum(image, self,@selector(finishExport:didFinishSavingWithError:contextInfo:),NULL);
    _saveImage = image;
    
    // 枠線表示
    if(_preview == NO){
        _boxDraw1.hidden = NO;
        _boxDraw2.hidden = NO;
    }
}

#pragma mark - ファイル書き出し時メソッド群
// 書き込み完了時に呼び出すメソッド　自作メソッドだがメソッドの引数や戻り値は規定に従っている
-(void)finishExport:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if( error == nil ) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"保存完了"
                                                                    message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        // 選択肢１（押したときの動作付き)
        UIAlertAction *sheetAction1 = [UIAlertAction
                                       actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                           [self postTwitter];
                                       }];

        UIAlertAction *sheetAction2 = [UIAlertAction
                                       actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                           [self postFacebook];
                                       }];

        UIAlertAction *sheetAction3 = [UIAlertAction
                                       actionWithTitle:@"閉じる" style:UIAlertActionStyleCancel handler:nil];
        // 選択肢のセット
        [ac addAction:sheetAction1];
        [ac addAction:sheetAction2];
        [ac addAction:sheetAction3];
        
        [self presentViewController:ac animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController
                                 alertControllerWithTitle:@"エラー" message:@"ファイル書き込み失敗しました" preferredStyle:UIAlertControllerStyleAlert];
        // 選択肢１（押したときの動作付き)
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        // 選択肢のセット
        [alertController addAction:alertAction];
        
        // ViewControllerのモーダル表示
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)postTwitter
{
    _account = nil;
    
    // アカウント貯蔵庫を得る
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    // Twitterを指定してアカウントタイプの取得
    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // iOSの保持しているTwitterカウントにアクセス
    [accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        
        // ここは別のスレッドで動作する
        
        if( granted ) {
            // 許可されたのでアカウントの取得
            NSArray *accounts = [accountStore accountsWithAccountType:twitterType];
            if( accounts.count > 0 ) {
                // アカウントが１件でもあれば、先頭のアカウントを利用する
                _account = [accounts objectAtIndex:0];
                return;
            }
        }
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"" message:@"アカウントが登録されていません" preferredStyle:UIAlertControllerStyleAlert];
        // 選択肢１（押したときの動作付き)
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        // 選択肢のセット
        [alertController addAction:alertAction];
        
        // ViewControllerのモーダル表示
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
    SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterViewController setInitialText:@"2Layerで画像を合成しました"];
    [twitterViewController addImage:_saveImage];
    [self presentViewController:twitterViewController animated:YES completion:nil];
}

-(void)postFacebook
{
    _account = nil;
    
    // アカウント貯蔵庫を得る
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    // Twitterを指定してアカウントタイプの取得
    ACAccountType *facebookType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary* option =
  @{
    ACFacebookAppIdKey : @"*****************"
    };
    
    // iOSの保持しているFacebookカウントにアクセス
    [accountStore requestAccessToAccountsWithType:facebookType options:option completion:^(BOOL granted, NSError *error) {
        
        // ここは別のスレッドで動作する
        
        if( granted ) {
            // 許可されたのでアカウントの取得
            NSArray *accounts = [accountStore accountsWithAccountType:facebookType];
            if( accounts.count > 0 ) {
                // アカウントが１件でもあれば、先頭のアカウントを利用する
                _account = [accounts objectAtIndex:0];
                return;
            }
        }
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"" message:@"アカウントが登録されていません" preferredStyle:UIAlertControllerStyleAlert];
        // 選択肢１（押したときの動作付き)
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        // 選択肢のセット
        [alertController addAction:alertAction];
        
        // ViewControllerのモーダル表示
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
    SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookViewController setInitialText:@"2Layerで画像を合成しました"];
    [facebookViewController addImage:_saveImage];
    [self presentViewController:facebookViewController animated:YES completion:nil];
}

@end
