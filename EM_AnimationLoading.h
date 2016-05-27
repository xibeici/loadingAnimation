//
//  EM_AnimationLoading.h
//  nav
//
//  Created by JaAa on 16/5/24.
//  Copyright © 2016年 SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EM_AnimationLoading : UIView
/**
 *  初始化一个动画图，默认会加载到superView的中间
 *  直接启动动画
 *  @param superView 父视图
 *
 *  @return self
 */
+ (EM_AnimationLoading *)loadingInView:(UIView *)superView;

/**
 *  移除动画
 *
 *  @param animation 是否需要动画 有渐隐效果，0.5s
 */
- (void)dismiss:(BOOL)animation;

@end
