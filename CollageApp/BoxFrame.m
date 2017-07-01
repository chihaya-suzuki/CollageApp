//
//  BoxFrame.m
//  CollageApp
//
//  Created by 鈴木千早 on 2015/11/16.
//  Copyright © 2015年 Chihaya Suzuki. All rights reserved.
//

#import "BoxFrame.h"

@implementation BoxFrame

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    [self addObserver:self forKeyPath:@"square" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    return self;
}

-(void)dealloc
{
    // (2) KVO解除、オブジェクトが消える時の後始末
    // 自分自身に対して、自分自身に通知なのでやらなくても問題は無いだろうが、丁寧に解除しておく
    [self removeObserver:self forKeyPath:@"square"];
    [self removeObserver:self forKeyPath:@"frame"];
}

- (void)drawRect:(CGRect)rect
{
    if(_square){
        // 矩形 -------------------------------------
        UIBezierPath *rectangle =
        [UIBezierPath bezierPathWithRect:CGRectMake(0,0,rect.size.width,rect.size.height)];
        [[UIColor blackColor] setStroke];
        [rectangle setLineWidth:1.5f];
        
        // この場合、5px線を描き、7px空白にする
        CGFloat dashPattern[] = {5.0f, 7.0f};
        
        [rectangle setLineDash:dashPattern count:2 phase:0];
        // 始点に移動
        [rectangle moveToPoint:CGPointZero];
        // 以下、→↓←↑の順に点線を描いていく
        [rectangle addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        [rectangle addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [rectangle addLineToPoint:CGPointMake(0, self.frame.size.height)];
        [rectangle addLineToPoint:CGPointMake(0, 0)];
        [rectangle stroke];
    }else{
        UIBezierPath *circle =
        [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [[UIColor blackColor] setStroke];
        circle.lineWidth = 1.0f;
        // この場合、5px線を描き、7px空白にする
        CGFloat dashPattern[] = {5.0f, 7.0f};
        [circle setLineDash:dashPattern count:2 phase:0];
        [circle stroke];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 変更されたプロパティまたは、インスタンス変数名がstrだったら
    if( [keyPath isEqualToString:@"square"]|[keyPath isEqualToString:@"frame"] ) {
        
//        NSLog(@"squareかframeに変更があったので、画面書き換えます");
        
        // テキストの内容が変わったのでdrawRectを呼び出して見た目を更新する
        [self setNeedsDisplay];
    }
}

@end
