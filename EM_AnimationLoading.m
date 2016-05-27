//
//  EM_AnimationLoading.m
//  nav
//
//  Created by JaAa on 16/5/24.
//  Copyright © 2016年 SL. All rights reserved.
//

#import "EM_AnimationLoading.h"
#import "UIView+Extension.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+BKBlockObservation.h"

//动画整体宽度
#define kLoadingWidth 31
//动画整体高度
#define kLoadingHeight 30
//圆圈半径
#define kCircleRadio 3.5
//动画时间
#define kAnimationDuring 1.

#define objc_Nil(a,b) ((a) ? (a) : (b))

typedef struct circle_postion {
    CGPoint start;//开始位置
    CGPoint mid;//中间位置坑
    CGPoint end;//结束为止坑
} circle_postion;

/*****************************    圆球   *****************************/
@interface EM_Circle : UIImageView
- (EM_Circle *)installView:(UIView *)superView positon:(CGPoint)point;
@end

@implementation EM_Circle

- (EM_Circle *)installView:(UIView *)superView positon:(CGPoint)point{
    EM_Circle *circle = [[EM_Circle alloc] initWithFrame:CGRectMake(0, 0 , kCircleRadio * 2, kCircleRadio * 2)];
    circle.centerX = point.x;
    circle.centerY = point.y;
    [superView addSubview:circle];
    [superView bringSubviewToFront:circle];
    return circle;
}
@end

/*****************************    动画   *****************************/

@interface EM_AnimationLoading (){
    circle_postion position ;/** 叁坑位 */
    CGFloat _radio ;/** 旋转半径 */
    BOOL animation_left;//YES旋转左边，NO旋转右边
}
/** 第一个圆球*/
@property (nonatomic, strong) EM_Circle *circle1;
/** 第二个圆球*/
@property (nonatomic, strong) EM_Circle *circle2;
/** 第叁个圆球*/
@property (nonatomic, strong) EM_Circle *circle3;
/** 动画*/
@property (nonatomic, strong) CAKeyframeAnimation *pathAnimation;
@end

@implementation EM_AnimationLoading

+ (EM_AnimationLoading *)loadingInView:(UIView *)superView {
    
    EM_AnimationLoading *loading = [[EM_AnimationLoading alloc]init];
    [superView addSubview:loading];
    [superView bringSubviewToFront:loading];
    loading.width = kLoadingWidth;
    loading.height = kLoadingHeight;
    loading.centerX = superView.width / 2;
    loading.centerY = superView.height / 2;
    //自动开启
    [loading start];
    
    return loading;
}


- (void)start {
    CGFloat posY = kLoadingHeight / 2;
    //设置为第一次旋转
    animation_left = YES;
    //初始化各个位置数据
    position.start = (CGPoint){kCircleRadio, posY};
    position.mid = (CGPoint){kLoadingWidth / 2, posY};
    position.end = (CGPoint){self.width - kCircleRadio, posY};
    //旋转半径
    _radio = (self.width / 2 - kCircleRadio) / 2;
    //添加三个圆圈
    _circle1 = objc_Nil(_circle1, [[EM_Circle alloc]installView:self positon:position.start]);
    _circle1.backgroundColor = [UIColor redColor];
    _circle2= objc_Nil(_circle2, [[EM_Circle alloc]installView:self positon:position.mid]) ;
    _circle2.backgroundColor = [UIColor greenColor];
    _circle3= objc_Nil(_circle3, [[EM_Circle alloc]installView:self positon:position.end]);
    _circle3.backgroundColor = [UIColor blueColor];
    //开始动画
    [self startAnimation:[self getPositionView:position.start] rightCircle:[self getPositionView:position.mid]];
    
}
//移除动画
- (void)dismiss:(BOOL)animation {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animations) object:self];
    if (animation) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self remove];
        }];
    }else {
        [self remove];
    }
}

- (void)remove {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[EM_Circle class]]) {
            [self pauseLayer:obj.layer];
            [obj removeFromSuperview];
        }
    }];
    [self removeFromSuperview];
}

/** 懒加载 动画 */
-(CAKeyframeAnimation *)pathAnimation
{
    if (!_pathAnimation) {
        
        _pathAnimation =  [CAKeyframeAnimation animationWithKeyPath:@"position"];
        _pathAnimation.calculationMode = kCAAnimationCubic;
        _pathAnimation.removedOnCompletion = NO;
        _pathAnimation.fillMode = kCAFillModeForwards;
        _pathAnimation.autoreverses = NO;
        _pathAnimation.duration = kAnimationDuring;
        _pathAnimation.repeatCount = 1;
    }
    return _pathAnimation;
}
//开始
- (void)startAnimation:(EM_Circle *)leftCircle rightCircle:(EM_Circle *)rightCircle {
    [leftCircle.layer removeAllAnimations];
    [rightCircle.layer removeAllAnimations];
    //旋转中心x
    CGFloat pointX = 0;
    //当在左边转圈的时候
    if (animation_left) {
        pointX = _radio + kCircleRadio;
    }else{
        pointX = self.width / 2 + _radio;
    }
    
    //交换两个的中心位置
    CGFloat t = leftCircle.centerX;
    leftCircle.centerX = rightCircle.centerX;
    rightCircle.centerX = t;
    
    //设置左循环圈运转动画的路径
    CGMutablePathRef leftcurvedPath = CGPathCreateMutable();
    CGPathAddArc(leftcurvedPath, NULL, pointX, self.height / 2, _radio, M_PI, M_PI * 2, 0);
    self.pathAnimation.path = leftcurvedPath;
    CGPathRelease(leftcurvedPath);
    //加入动画
    [leftCircle.layer addAnimation:self.pathAnimation forKey:@"left"];
    //设置右循环圈运转动画的路径
    CGMutablePathRef R_curvedPath = CGPathCreateMutable();
    CGPathAddArc(R_curvedPath, NULL, pointX, self.height / 2 , _radio, 0, M_PI , 0);
    self.pathAnimation.path = R_curvedPath;
    CGPathRelease(R_curvedPath);
    //加入动画
    [rightCircle.layer addAnimation:self.pathAnimation forKey:@"right"];
    //每隔kAnimationDuring触发动画
    [self performSelector:@selector(animations) withObject:self afterDelay:kAnimationDuring];
}

/**
 *  根据坑位找circle，每次动画完成后，三个坑位里的view都会变化
 *  不管view的变化，只取坑位里的view进行动画
 *
 *  @param point 三个坑位中的一个
 *
 *  @return point中的view
 */
-(EM_Circle *)getPositionView:(CGPoint)point {
    
    for (UIView *view in self.subviews) {
        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, view.x, view.y);
        CGPathAddLineToPoint(pathRef, NULL, view.x + view.width, view.y);
        CGPathAddLineToPoint(pathRef, NULL, view.x + view.width, view.y + view.height);
        CGPathAddLineToPoint(pathRef, NULL, view.x, view.y + view.height);
        CGPathAddLineToPoint(pathRef, NULL, view.x, view.y);
        CGPathCloseSubpath(pathRef);
        if (CGPathContainsPoint(pathRef, NULL, point, NO)) {
            if ([view isKindOfClass:[EM_Circle class]]) {
                CGPathRelease(pathRef);
                return (EM_Circle *)view;
                break;
            }
        }
        CGPathRelease(pathRef);
    }
    return nil;
}
//开始循环动画
-(void)animations {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animations) object:self];
    animation_left = !animation_left;
    //循环左边
    if (animation_left) {
        [self startAnimation:[self getPositionView:position.start] rightCircle:[self getPositionView:position.mid]];
    }else {
        [self startAnimation:[self getPositionView:position.mid] rightCircle:[self getPositionView:position.end]];
    }
    
}
//停止动画
-(void)pauseLayer:(CALayer*)layer{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}
@end

