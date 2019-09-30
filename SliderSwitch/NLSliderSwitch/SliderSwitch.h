//
//  KMSwitchButtons.h
//  ScrollerTab
//
//  Created by kkmm on 2018/8/9.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWModel.h"
#import "SliderSwitchProtocol.h"
@class SliderSwitch;
@protocol SliderSwitchDelegate <UIScrollViewDelegate>
@required

/**
 设置每个index对应的页面

 @param sliderSwitch 自身
 @param index 索引
 @return 需要返回的VC
 */
- (UIViewController <SliderSwitchProtocol>*)sliderSwitch:(SliderSwitch *)sliderSwitch setSubViewControllerInIndex:(NSInteger)index;

@optional
/*! 选中selectedIndex 回调*/
- (void)sliderSwitch:(SliderSwitch *)sliderSwitch didSelectedIndex:(NSInteger)selectedIndex;

@end


@interface SliderSwitch <T>: UIScrollView
/*! 数据源*/
@property(nonatomic,strong) NSMutableArray <SWModel *>*dataArray;
/*! visiableVCs可见控制器数组*/
@property(nonatomic,strong)NSMutableArray <SWModel *>*visiableVCs;
/*! title的未选中字色*/
@property(nonatomic,strong) UIColor *normalTitleColor;
/*! title的选中字色*/
@property(nonatomic,strong) UIColor *selectedTitleColor;
/*! title字体*/
@property(nonatomic,strong) UIFont *titleFont;
/*! 选中title字体*/
@property(nonatomic,strong) UIFont *selectedTitleFont;
/*! 选中按钮颜色*/
@property(nonatomic,strong) UIColor *selectedButtonColor;
/*! 选中按钮渐变色*/
@property(nonatomic, strong) NSArray *selectedButtonColors;
/*! button宽高*/
@property(nonatomic,assign) CGSize buttonSize;
/*! 滑块*/
@property(nonatomic,strong)CAGradientLayer *sliderLayer;
/*! 选中按钮字体是否变粗，默认变粗*/
@property(nonatomic) BOOL selectedFontBlod;
/*! 选中滑块的放大倍数*/
@property(nonatomic,readonly)CGFloat enlargeScale;
/*! 当前选中index*/
@property(nonatomic,readonly) NSInteger selectedIndex;
/*! 容器ScrollView*/
@property(nonatomic,weak) UIScrollView *containerScroll;
/**
 *可见中心偏移量 ，滑动停止后SliderSwitch中心按钮 悬停位置的偏移量
 
 *通常用作SliderSwitch未处于屏幕中心，而选中项需要悬停在屏幕中心的情形
 
 *默认为0,中心位置
 
 */
@property(nonatomic,assign)CGFloat visibleCenterOffset;
/** 滑条Size */
@property(nonatomic,assign) CGSize sliderSize;
/** 滑条距离底部的边距   default = 2 */
@property(nonatomic,assign) CGFloat sliderBottomMargin;
/** 滑条偏移量 */
@property(nonatomic,assign) CGFloat sliderOffset DEPRECATED_MSG_ATTRIBUTE("考虑以后可能的情形预定义属性，功能未实现");
/** 是否首次加载 */
@property(nonatomic) BOOL isFirstSlide;


/** 动画是否停止 */
@property(nonatomic) BOOL animationStop;

/** 滑条是否可伸缩
 *  点击滑动时scrollViewDidScroll回调不改变slider.frame
 */
@property(nonatomic) BOOL sliderFlexibleWidthEnable;

@property(nonatomic,weak) id<SliderSwitchDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame buttonSize:(CGSize)size;



/** 记录上一次滑动的点  */
-(void)anchorScrollViewPoint:(UIScrollView *)scrollView;

/*! 滑动到idx*/
-(void)slideToIndex:(NSInteger)idx;

/*! 滑动到idx 是否加载动画*/
-(void)slideToIndex:(NSInteger)idx animated:(BOOL)animated;

/*! 请求刷新当前子页面,主要用于点击menubar时调用刷新 */
-(void)requestRefreshCurrentPage;
/**
 重载数据
 */
-(void)sw_reloadData;
/**
 销毁子控制器，pop前调用
 */
-(void)distory;
@end

