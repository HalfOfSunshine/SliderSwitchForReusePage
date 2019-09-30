//
//  KMSwitchButtons.m
//  ScrollerTab
//
//  Created by kkmm on 2018/8/9.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import "SliderSwitch.h"
#define KScreen [UIScreen mainScreen].bounds.size
#define PreSelectedIndex 0
@interface SliderSwitch()<CAAnimationDelegate,UIScrollViewDelegate>// 这里要遵守父类原本的协议，因为继承类时，协议是不会被继承的，所以需要重新声明

@property (nonatomic, weak) id<SliderSwitchDelegate> myDelegate;// 因为父类的delegate对象是self，self的delegate是外部类，所以需要新增一个myDelegate来保存外部类

/*! 当前选中index*/
@property(nonatomic,readwrite) NSInteger selectedIndex;

/** 记录上一次滑动所在位置 */
@property(nonatomic,strong) NSMutableArray<NSNumber *> *titleButtonPoints;
@property(nonatomic) CGFloat toLeftWidth;
@property(nonatomic) CGFloat toRightWidth;


/** 记录上一次滑动所在位置 */
@property(nonatomic,assign) CGFloat lastContentOffset;
/** 记录上一次滑条frame */
@property(nonatomic,assign) CGRect lastSliderFrame;
@end
@implementation SliderSwitch

//因delegate在父类UIScrollView中已经声明过，子类再声明也不会重新生成新的方法。这里我们使用@dynamic告诉系统delegate的setter与getter方法由用户自己实现，不由系统自动生成。
@dynamic delegate;
-(id<SliderSwitchDelegate>)delegate{
    return _myDelegate;
}
-(void)setDelegate:(id<SliderSwitchDelegate>)delegate{
    [super setDelegate:delegate];
    _myDelegate = delegate;
}

- (instancetype)initWithFrame:(CGRect)frame buttonSize:(CGSize)size
{
    self = [super initWithFrame:frame];
    if (self) {
        self.toLeftWidth = 0.0f;
        self.toRightWidth = 0.0f;
        self.visiableVCs = [[NSMutableArray alloc]init];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.visibleCenterOffset = 0;
        self.selectedIndex = 0;
        self.selectedFontBlod = NO;
        self.isFirstSlide = YES;
        self.sliderFlexibleWidthEnable = YES;
        self.animationStop = YES;
        self.buttonSize = CGSizeMake(size.width, size.height);
        self.normalTitleColor = [UIColor grayColor];
        self.selectedTitleColor = [UIColor blackColor];
        _sliderLayer = [CAGradientLayer layer];
        self.sliderBottomMargin = 2;
        _sliderLayer.frame = CGRectMake(0, frame.size.height-self.sliderBottomMargin-4, 10, 4);
        self.lastSliderFrame = _sliderLayer.frame;
        self.sliderSize = _sliderLayer.frame.size;
        _sliderLayer.masksToBounds = YES;
        _sliderLayer.cornerRadius = self.sliderLayer.frame.size.width<self.sliderLayer.frame.size.height?self.sliderLayer.frame.size.width/2.:self.sliderLayer.frame.size.height/2.;
        [self.layer addSublayer:_sliderLayer];
    }
    return self;
}

#pragma mark CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.animationStop = YES;
}

#pragma mark SliderAction And Animated
-(void)clickEvent:(UIButton *)sender
{
    NSInteger index = sender.tag-9000;
    if(index == self.selectedIndex&&!self.isFirstSlide){
        return;
    }
    [self anchorScrollViewPoint:self.containerScroll];
    self.animationStop = NO;
    self.sliderFlexibleWidthEnable = NO;
    if(self.dataArray[_selectedIndex].VC&&[self.dataArray[_selectedIndex].VC respondsToSelector:@selector(sliderSwitchWillBeginDragging)]){
        [self.dataArray[_selectedIndex].VC sliderSwitchWillBeginDragging];
    }
    [self slideToIndex:sender.tag-9000 animated:YES];
}

-(void)sw_reloadData{
    
}

-(void)slideToIndex:(NSInteger)idx{
    [self slideToIndex:idx animated:YES];
}

-(void) slideToIndex:(NSInteger)idx animated:(BOOL)animated;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.visiableVCs.count) {
            [self PreSetCisiableVC];
        }
        UIButton *button=(UIButton *)[self viewWithTag:idx+9000];
        
        [button setTitleColor:self.selectedTitleColor forState:UIControlStateNormal];
        
        UIButton *lastbutton=(UIButton *)[self viewWithTag:(NSInteger)(self.selectedIndex+9000)];
        
        NSInteger index = button.tag-9000;
        if(index == self.selectedIndex&&!self.isFirstSlide){
            return;
        }
        [lastbutton setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
        float xx = index*KScreen.width;
        int rate = round(xx/KScreen.width);

        if (rate != self.selectedIndex||self.isFirstSlide) {
            if (rate<0||rate>self.dataArray.count) {
                return;
            }
            [self reuseVCInIndex:rate];//减少cpu负担
        }
        if (self.isFirstSlide) {
            self.isFirstSlide = NO;
            self.selectedIndex = rate;
        }
        if (animated){
            //滑动
            [self scrollRectToVisible:CGRectMake(button.center.x-self.frame.size.width/2-self.visibleCenterOffset,0, self.frame.size.width, self.frame.size.height) animated:YES];
            [self.containerScroll scrollRectToVisible:CGRectMake(index*KScreen.width,0, KScreen.width, 1) animated:YES];

            self.sliderLayer.frame = CGRectMake(button.frame.origin.x+button.frame.size.width/2-self.sliderSize.width/2, self.lastSliderFrame.origin.y, self.sliderSize.width, self.sliderSize.height);
            //    长短
            CABasicAnimation *sliderAnimation = [CABasicAnimation animation];
            sliderAnimation.keyPath = @"transform.scale.x";
            sliderAnimation.toValue = [NSNumber numberWithFloat:1.];
            sliderAnimation.speed = 3;
            sliderAnimation.autoreverses = YES;
            sliderAnimation.delegate = self;
            [self.sliderLayer addAnimation:sliderAnimation forKey:@"sliderAnimation"];
            [self.dataArray[_selectedIndex].VC setValue:@0 forKey:@"isVisiableVC"];
            if (self.dataArray[_selectedIndex].VC&&[self.dataArray[_selectedIndex].VC respondsToSelector:@selector(viewDidScrollToUnVisiableArea)]) {
                [self.dataArray[_selectedIndex].VC viewDidScrollToUnVisiableArea];
            }
            self.selectedIndex = index;
        }else{

            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self scrollRectToVisible:CGRectMake(button.center.x-self.frame.size.width/2-self.visibleCenterOffset,0, self.frame.size.width, self.frame.size.height) animated:NO];
            [self.containerScroll scrollRectToVisible:CGRectMake(index*KScreen.width,0, KScreen.width, 1) animated:NO];

            self.sliderLayer.frame = CGRectMake(button.frame.origin.x+button.frame.size.width/2-self.sliderSize.width/2, self.lastSliderFrame.origin.y, self.sliderSize.width, self.sliderSize.height);
            [button.layer removeAllAnimations];
            [lastbutton.layer removeAllAnimations];
            [CATransaction commit];
            [self.dataArray[_selectedIndex].VC setValue:@0 forKey:@"isVisiableVC"];
            if (self.dataArray[_selectedIndex].VC&&[self.dataArray[_selectedIndex].VC respondsToSelector:@selector(viewDidScrollToUnVisiableArea)]) {
                [self.dataArray[_selectedIndex].VC viewDidScrollToUnVisiableArea];
            }
            self.selectedIndex = index;
        }
        
        [self reuseVCInIndex:rate];
        if (self.delegate && [self.delegate respondsToSelector:@selector(sliderSwitch:didSelectedIndex:)]) {
            [self.delegate sliderSwitch:self didSelectedIndex:index];
        }
        if(self.dataArray[_selectedIndex].VC&&[self.dataArray[_selectedIndex].VC respondsToSelector:@selector(sliderSwitchDidEndDecelerating)]){
            [self.dataArray[_selectedIndex].VC sliderSwitchDidEndDecelerating];
        }
    });
}

#pragma mark - UIScrollViewDelegate
- (void)calcWidthLeftAndRight
{
    self.lastContentOffset = self.containerScroll.contentOffset.x;//判断左右滑动时
    int rate = round(self.containerScroll.contentOffset.x/KScreen.width);
    
    CGFloat selectedPoint = [_titleButtonPoints[rate] floatValue];
    CGFloat selectedPointLeft = rate == 0 ? 0 : [_titleButtonPoints[rate - 1] floatValue];
    CGFloat selectedPointRight = rate == _titleButtonPoints.count - 1 ? 0 : [_titleButtonPoints[rate + 1] floatValue];
    
    _toLeftWidth = selectedPointLeft == 0 ? 0 : selectedPoint - selectedPointLeft;
    _toRightWidth = selectedPointRight == 0 ? 0 : selectedPointRight - selectedPoint;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self calcWidthLeftAndRight];
    
    if ([_myDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_myDelegate scrollViewWillBeginDragging:self];
    }
    if(self.dataArray[_selectedIndex].VC&&[self.dataArray[_selectedIndex].VC respondsToSelector:@selector(sliderSwitchWillBeginDragging)]){
        [self.dataArray[_selectedIndex].VC sliderSwitchWillBeginDragging];
    }
    if (scrollView == self.containerScroll) {
        //全局变量记录滑动前的contentOffset
        [self anchorScrollViewPoint:scrollView];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.containerScroll&&self.sliderFlexibleWidthEnable&&!_isFirstSlide) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        CGFloat scrollDistance = scrollView.contentOffset.x - self.lastContentOffset;
        if (scrollDistance>=0) {//👉
            if (scrollDistance <= KScreen.width/2){
//                CGFloat sliderFlexibleWidth = scrollDistance * sliderScan * 2;
                CGFloat sliderFlexibleWidth = _toRightWidth * (scrollDistance / (KScreen.width/2));
                self.sliderLayer.frame = CGRectMake(self.lastSliderFrame.origin.x, self.lastSliderFrame.origin.y, self.lastSliderFrame.size.width+sliderFlexibleWidth, self.lastSliderFrame.size.height);
            }else if (scrollDistance > KScreen.width/2&&scrollDistance < KScreen.width) {
                CGFloat xMoveDistance = _toRightWidth * (scrollDistance * 2 / KScreen.width - 1);
                CGFloat sliderFlexibleWidth = _toRightWidth - xMoveDistance;

                self.sliderLayer.frame = CGRectMake(self.lastSliderFrame.origin.x+xMoveDistance, self.lastSliderFrame.origin.y, self.lastSliderFrame.size.width+sliderFlexibleWidth, self.lastSliderFrame.size.height);
            }else if (scrollDistance >= KScreen.width) {
                [self anchorScrollViewPoint:scrollView];
                int rate = round(self.containerScroll.contentOffset.x/KScreen.width);
                UIButton *button = [self viewWithTag:rate+9000];
                [self scrollRectToVisible:CGRectMake(button.center.x-self.frame.size.width/2-self.visibleCenterOffset,0, self.frame.size.width, self.frame.size.height) animated:YES];
                NSLog(@"VisibleX=%f",(40+(round(scrollView.contentOffset.x/KScreen.width))*self.buttonSize.width+self.buttonSize.width/2-self.frame.size.width/2-self.visibleCenterOffset));
                
            }
        }else if (scrollDistance<0){//👈
            if (scrollDistance >= -KScreen.width/2){
//                CGFloat sliderFlexibleWidth = scrollDistance*sliderScan*2;
                CGFloat sliderFlexibleWidth = _toLeftWidth * (scrollDistance / (KScreen.width/2));
                self.sliderLayer.frame = CGRectMake(self.lastSliderFrame.origin.x+sliderFlexibleWidth, self.lastSliderFrame.origin.y, self.lastSliderFrame.size.width-sliderFlexibleWidth, self.lastSliderFrame.size.height);
                
            }else if (scrollDistance < -KScreen.width/2 && scrollDistance > -KScreen.width) {
//                CGFloat sliderFlexibleWidth = (KScreen.width+scrollDistance)*sliderScan*2;
//                CGFloat xMoveDistance = KScreen.width*sliderScan;
                CGFloat xMoveDistance = _toLeftWidth * (scrollDistance * 2 / KScreen.width + 1);
                CGFloat sliderFlexibleWidth = _toLeftWidth + xMoveDistance;
                self.sliderLayer.frame = CGRectMake(self.lastSliderFrame.origin.x - _toLeftWidth, self.lastSliderFrame.origin.y, self.lastSliderFrame.size.width+sliderFlexibleWidth, self.lastSliderFrame.size.height);
            }else if (scrollDistance <= -KScreen.width) {
                [self anchorScrollViewPoint:scrollView];
                int rate = round(self.containerScroll.contentOffset.x/KScreen.width);
                UIButton *button = [self viewWithTag:rate+9000];
                [self scrollRectToVisible:CGRectMake(button.center.x-self.frame.size.width/2-self.visibleCenterOffset,0, self.frame.size.width, self.frame.size.height) animated:YES];
            }
        }
    }
    [CATransaction commit];
    if ([_myDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_myDelegate scrollViewDidScroll:self];
    }
}

-(void)anchorScrollViewPoint:(UIScrollView *)scrollView{
    if (self.animationStop) {
        self.sliderFlexibleWidthEnable = YES;
    }
    int rate = round(scrollView.contentOffset.x/KScreen.width);
    self.lastContentOffset = scrollView.contentOffset.x;//判断左右滑动时
    UIButton *button=(UIButton *)[self viewWithTag:rate+9000];
    
    self.lastSliderFrame = CGRectMake(button.frame.origin.x+button.frame.size.width/2-self.sliderSize.width/2, self.lastSliderFrame.origin.y, self.sliderSize.width, self.sliderSize.height);
    [self calcWidthLeftAndRight];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.containerScroll) {
        float xx = scrollView.contentOffset.x;
        int rate = round(xx/KScreen.width);
        if (rate != self.selectedIndex ||(self.selectedIndex==PreSelectedIndex&&self.isFirstSlide)) {
            [self slideToIndex:rate];
        }else{
            if (self.sliderLayer.frame.size.width != self.sliderSize.width) {
                UIButton *button=(UIButton *)[self viewWithTag:self.selectedIndex+9000];
                self.sliderLayer.frame = CGRectMake(button.frame.origin.x+button.frame.size.width/2-self.sliderSize.width/2, self.lastSliderFrame.origin.y, self.sliderSize.width, self.sliderSize.height);
            }
            if(self.dataArray[_selectedIndex].VC&&[self.dataArray[_selectedIndex].VC respondsToSelector:@selector(sliderSwitchDidEndDecelerating)]){
                [self.dataArray[_selectedIndex].VC sliderSwitchDidEndDecelerating];
            }
        }
    }
    if ([_myDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_myDelegate scrollViewDidEndDecelerating:self];
    }
}

#pragma mark - SubVCReuseOpration  实测减少cpu负担
-(void)reuseVCInIndex:(NSInteger)rate{
    if (rate>=0&&rate<self.dataArray.count) {
        if (![self.visiableVCs containsObject:self.dataArray[rate]]) {
            [self addSubVCInIndex:rate];
            [self removeLastVisiableVCBesides:rate];
        }
        if (rate+1<=self.dataArray.count-1) {
            if (![self.visiableVCs containsObject:self.dataArray[rate+1]]) {
                [self addSubVCInIndex:rate+1];
                [self removeLastVisiableVCBesides:rate];
            }
        }
        if (rate-1>=0) {
            if (![self.visiableVCs containsObject:self.dataArray[rate-1]]) {
                [self addSubVCInIndex:rate-1];
                [self removeLastVisiableVCBesides:rate];
            }
        }

    }
}

-(void)addSubVCInIndex:(NSInteger)index{
    if (index>=0&&index<self.dataArray.count) {
        if (!self.dataArray[index].VC) {
            self.dataArray[index].VC = [self.delegate sliderSwitch:self setSubViewControllerInIndex:index];
            //        加入VC后重新设置一次
            self.dataArray[index].VC.showAsPageCard = YES;
        }
        
        if (self.dataArray[index].VC.view.frame.origin.x != index*KScreen.width ||self.dataArray[index].VC.view.frame.size.height != self.containerScroll.frame.size.height) {
            [self.dataArray[index].VC.view setFrame:CGRectMake(index*KScreen.width, 0, KScreen.width, self.containerScroll.frame.size.height)];
        }
        [self.containerScroll addSubview:self.dataArray[index].VC.view];
        
        if (_selectedIndex == index) {
            [self.dataArray[index].VC setValue:@1 forKey:@"isVisiableVC"];
        }else{
            [self.dataArray[index].VC setValue:@0 forKey:@"isVisiableVC"];
        }
        
        if (self.dataArray[index].VC&&[self.dataArray[index].VC respondsToSelector:@selector(viewDidScrollToSideArea)]) {
            [self.dataArray[index].VC viewDidScrollToSideArea];
        }
        
        if (![self.visiableVCs containsObject:self.dataArray[index]]) {
            [self.visiableVCs addObject:self.dataArray[index]];
        }
    }
}

-(void)removeLastVisiableVCBesides:(NSInteger)index{
    if (self.visiableVCs.count>=3) {
        if (self.visiableVCs[0] != self.dataArray[index]) {
            [self.visiableVCs[0].VC.view removeFromSuperview];
            [self.visiableVCs removeObjectAtIndex:0];
        }else{
            [self.visiableVCs[1].VC.view removeFromSuperview];
            [self.visiableVCs removeObjectAtIndex:1];
        }
    }
}

#pragma mark - LazyLoading
-(void)setSelectedIndex:(NSInteger)selectedIndex{
    if (_selectedIndex!= selectedIndex) {
        if (self.titleFont) {
            UIButton *unSelectedBtn = [self viewWithTag:_selectedIndex+9000];
            unSelectedBtn.titleLabel.font = self.titleFont;
        }
        
        _selectedIndex = selectedIndex;
    }
    if (self.selectedTitleFont) {
        UIButton *selectedBtn = [self viewWithTag:_selectedIndex+9000];
        selectedBtn.titleLabel.font = self.selectedTitleFont;
    }
    if (selectedIndex>=0&&selectedIndex<self.dataArray.count) {
        [self.dataArray[_selectedIndex].VC setValue:@1 forKey:@"isVisiableVC"];
        if (self.dataArray[selectedIndex].VC&&[self.dataArray[selectedIndex].VC respondsToSelector:@selector(viewDidScrollToVisiableArea)]) {
            [self.dataArray[selectedIndex].VC viewDidScrollToVisiableArea];
        }
    }
}

-(void)setContainerScroll:(UIScrollView *)containerScroll{
    if (_containerScroll!=containerScroll) {
        _containerScroll = containerScroll;
    }
    _containerScroll.delegate = self;
    [_containerScroll scrollRectToVisible:CGRectMake(self.selectedIndex*KScreen.width,0, KScreen.width, 1) animated:NO];
    if (!self.visiableVCs.count) {
        [self PreSetCisiableVC];
    }
    if (self.selectedIndex==PreSelectedIndex&&self.isFirstSlide){
        [self slideToIndex:PreSelectedIndex animated:NO];
    }
}
-(void)PreSetCisiableVC{
    if (!self.visiableVCs.count) {
        if(self.selectedIndex<=1){
            [self addSubVCInIndex:0];
            [self addSubVCInIndex:1];
            [self addSubVCInIndex:2];
        }else if (self.selectedIndex >= self.dataArray.count-2){
            [self addSubVCInIndex:(self.dataArray.count-3)];
            [self addSubVCInIndex:(self.dataArray.count-2)];
            [self addSubVCInIndex:(self.dataArray.count-1)];
        }else{
            [self addSubVCInIndex:(self.selectedIndex-1)];
            [self addSubVCInIndex:(self.selectedIndex)];
            [self addSubVCInIndex:(self.selectedIndex+1)];
        }
    }
}
//获取字符串的宽度
- (float) calcFontWidth:(NSString *)value fontSize:(float)fontSize
{
    CGSize sizeToFit = [value sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize] }];
    return sizeToFit.width;
}

-(void)setDataArray:(NSMutableArray <SWModel *>*)dataArray{
    if (_dataArray != dataArray) {
        _dataArray = dataArray;
        
        if (!_titleButtonPoints) {
            _titleButtonPoints = [[NSMutableArray alloc] init];
        }
        [_titleButtonPoints removeAllObjects];
    }
    for (UIButton *btn in self.subviews) {
        if (btn.tag>=9000) {
            [btn removeFromSuperview];
        }
    }
     __block CGFloat contentWidth = 40.0f;
    __block CGFloat mStartLeft = 40.0f;
    CGFloat mSpase = 0.0f;
    CGFloat mButtonSpaseLR = 15.0f;
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat mFontWidth = [self calcFontWidth:dataArray[idx].title fontSize:13.0] + mButtonSpaseLR * 2;
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(mStartLeft, (self.frame.size.height-self.buttonSize.height)/2, mFontWidth, self.buttonSize.height)];
        [_titleButtonPoints addObject:[NSNumber numberWithFloat:mStartLeft + mFontWidth / 2]];
        mStartLeft += mFontWidth + mSpase;
        contentWidth += (mFontWidth + mSpase);

        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = self.buttonSize.width<self.buttonSize.height?self.buttonSize.width/2.:self.buttonSize.height/2.;
        [button addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:dataArray[idx].title forState:UIControlStateNormal];
        if (self.selectedIndex != idx) {
            [button setTitleColor:self.selectedTitleColor forState:UIControlStateNormal];
            //     缩小
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
//            button.layer.transform = CATransform3DMakeScale(UnSelectedScale, UnSelectedScale, 1);
            [CATransaction commit];
        }else{
            [button setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
        }
        if (_titleFont&&idx!=_selectedIndex) {
            button.titleLabel.font = _titleFont;
        }
        if (_selectedTitleFont&&idx==_selectedIndex) {
            button.titleLabel.font = _selectedTitleFont;
        }
        button.tag = idx+9000;
        [self addSubview:button];
    }];
    self.contentSize = CGSizeMake(40+contentWidth,self.frame.size.height);
    
//    self.contentSize = CGSizeMake(40+contentWidth,1);
}

-(void)setTitleFont:(UIFont *)titleFont{
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
    }
    for (NSObject *btn in self.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)btn;
            if (button.tag-9000 != _selectedIndex) {
                button.titleLabel.font = _titleFont;
            }else{
                if (_selectedTitleFont) {
                    button.titleLabel.font = _selectedTitleFont;
                }
            }
        }
    }
}

- (void)setSelectedTitleFont:(UIFont *)selectedTitleFont{
    if (_selectedTitleFont != selectedTitleFont) {
        _selectedTitleFont = selectedTitleFont;
        UIButton *selectedBtn = [self viewWithTag:_selectedIndex+9000];
        selectedBtn.titleLabel.font = self.selectedTitleFont;
    }
}

-(void)setNormalTitleColor:(UIColor *)normalTitleColor{
    if (_normalTitleColor != normalTitleColor) {
        _normalTitleColor = normalTitleColor;
    }
    for (NSObject *btn in self.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)btn;
            if (button.tag != self.selectedIndex+9000) {
                [button setTitleColor:normalTitleColor forState:UIControlStateNormal];
            }
        }
    }
}

-(void)setSelectedTitleColor:(UIColor *)selectedTitleColor{
    if (_selectedTitleColor != selectedTitleColor) {
        _selectedTitleColor = selectedTitleColor;
    }
    UIButton *button=(UIButton *)[self viewWithTag:self.selectedIndex+9000];
    [button setTitleColor:selectedTitleColor forState:UIControlStateNormal];
}

-(void)setSelectedButtonColor:(UIColor *)selectedButtonColor{
    if (_selectedButtonColor != selectedButtonColor) {
        _selectedButtonColor = selectedButtonColor;
    }
    _sliderLayer.backgroundColor = selectedButtonColor.CGColor;
}

-(void)setSelectedButtonColors:(NSArray *)selectedButtonColors{
    _sliderLayer.colors = selectedButtonColors;  // 设置渐变颜色
    //    （0，0）为左上角、（1，0）为右上角、（0，1）为左下角、（1，1）为右下角，默认是值是（0.5，0）和（0.5，1）
    //    gradientLayer.locations = @[@0.0, @0.2];
    _sliderLayer.startPoint = CGPointMake(0., 0.5);   //
    _sliderLayer.endPoint = CGPointMake(1., 0.5);     //
    _sliderLayer.masksToBounds = YES;
}
-(void)requestRefreshCurrentPage{
    
    if (self.dataArray[_selectedIndex].VC&&[self.dataArray[_selectedIndex].VC respondsToSelector:@selector(sliderSwitchRequestRefresh)]) {
        [self.dataArray[_selectedIndex].VC sliderSwitchRequestRefresh];
    }
}
-(void)distory{
    for (SWModel *model in self.dataArray) {
        if (model.VC != nil) {
            [model.VC removeFromParentViewController];
        }
    }
}
-(void)setSliderSize:(CGSize)sliderSize{
    if (_sliderSize.width!=sliderSize.width||_sliderSize.height!=sliderSize.height) {
        _sliderSize = sliderSize;
        _sliderLayer.frame = CGRectMake(0, self.frame.size.height-self.sliderBottomMargin-sliderSize.height, sliderSize.width, sliderSize.height);
        self.lastSliderFrame = _sliderLayer.frame;
        _sliderLayer.cornerRadius = self.sliderLayer.frame.size.width<self.sliderLayer.frame.size.height?self.sliderLayer.frame.size.width/2.:self.sliderLayer.frame.size.height/2.;
    }
}
- (void)setSliderBottomMargin:(CGFloat)sliderBottomMargin{
    if (_sliderBottomMargin != sliderBottomMargin) {
        _sliderBottomMargin = sliderBottomMargin;
        _sliderLayer.frame = CGRectMake(0, self.frame.size.height-self.sliderBottomMargin-self.sliderSize.height, self.sliderSize.width, self.sliderSize.height);
        self.lastSliderFrame = _sliderLayer.frame;
    }
}
- (void)setVisibleCenterOffset:(CGFloat)visibleCenterOffset{
    if (_visibleCenterOffset != visibleCenterOffset) {
        _visibleCenterOffset = visibleCenterOffset;
    }
}
@end
