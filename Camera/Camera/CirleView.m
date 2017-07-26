//
//  CirleView.m
//  Camera
//
//  Created by iMac on 17/7/24.
//  Copyright © 2017年 kangbing. All rights reserved.
//

#import "CirleView.h"

@implementation CirleView


- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    CGPoint center = CGPointMake(55, 55);;
    CGFloat radius = 45;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;  //圆终点位置
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextSetLineWidth(ctx, 10); //设置线条宽度
    [[UIColor colorWithRed:90.0 / 255.0 green:200 / 255.0 blue:33 / 255.0 alpha:0.7] setStroke]; //设置描边颜色
    
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    
    CGContextStrokePath(ctx);  //渲染
}

- (void)setProgress:(CGFloat)progress{

    
    _progress = progress;
    
    [self setNeedsDisplay];



}



@end
