//
//  KMSwitchButtons.m
//  ScrollerTab
//
//  Created by kkmm on 2018/8/9.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import "NLSliderSwitch.h"
#import "SonViewController.h"

#define SelectedScale 1.5
#define UnSelectedScale (1/1.5)
#define KScreen [UIScreen mainScreen].bounds.size
#define TopBarHeight (([UIScreen mainScreen].bounds.size.height >= 812.0) ? 88.f : 64.f)

@interface NLSliderSwitch()<CAAnimationDelegate,UIScrollViewDelegate>// 这里要遵守父类原本的协议，因为继承类时，协议是不会被继承的，所以需要重新声明

@property (nonatomic, weak) id<NLSliderSwitchDelegate> myDelegate;// 因为父类的delegate对象是self，self的delegate是外部类，所以需要新增一个myDelegate来保存外部类

/*! 当前选中index*/
@property(nonatomic,readwrite) NSInteger selectedIndex;


/** 记录上一次滑动所在位置 */
@property(nonatomic,assign) CGFloat lastContentOffset;
/** 记录上一次滑条位置 */
@property(nonatomic,assign) CGRect lastSliderFrame;
/** 点击滑动时scrollViewDidScroll回调不改变slider.frame */
@property(nonatomic) BOOL sliderFlexibleWidthEnable;
@property(nonatomic) BOOL animationStop;

@end
@implementation NLSliderSwitch

@dynamic delegate;// .h中警告说delegate在父类已经声明过了，子类再声明也不会重新生成新的方法了。我们就在这里使用@dynamic告诉系统delegate的setter与getter方法由用户自己实现，不由系统自动生成
-(id<NLSliderSwitchDelegate>)delegate{
	return _myDelegate;
}
-(void)setDelegate:(id<NLSliderSwitchDelegate>)delegate{
	[super setDelegate:delegate];
	_myDelegate = delegate;
}

- (instancetype)initWithFrame:(CGRect)frame buttonSize:(CGSize)size
{
	self = [super initWithFrame:frame];
	if (self) {
		self.visiableVCs = [[NSMutableArray alloc]init];
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.selectedIndex = 0;
		self.selectedFontBlod = YES;
		self.sliderFlexibleWidthEnable = YES;
		self.animationStop = YES;
		self.buttonSize = CGSizeMake(size.width*SelectedScale, size.height*SelectedScale);
		self.normalTitleColor = [UIColor grayColor];
		self.selectedTitleColor = [UIColor blackColor];
		_sliderLayer = [CALayer layer];

		_sliderLayer.frame = CGRectMake(self.buttonSize.width*self.selectedIndex*UnSelectedScale-(self.buttonSize.width-self.buttonSize.width*UnSelectedScale)/2+self.buttonSize.width/2-4, frame.size.height-6, 10, 4);
		self.lastSliderFrame = _sliderLayer.frame;
		self.sliderSize = _sliderLayer.frame.size;
		_sliderLayer.masksToBounds = YES;
		_sliderLayer.backgroundColor = [UIColor blueColor].CGColor;
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
	[self anchorScrollViewPoint:self.containerScroll];
	self.animationStop = NO;
	self.sliderFlexibleWidthEnable = NO;
	[self slideToIndex:sender.tag-9000 animated:YES];
}


-(void)slideToIndex:(NSInteger)idx{
	[self slideToIndex:idx animated:YES];
}

-(void)slideToIndex:(NSInteger)idx animated:(BOOL)animated;
{
	UIButton *button=(UIButton *)[self viewWithTag:idx+9000];
	
	[button setTitleColor:self.selectedTitleColor forState:UIControlStateNormal];
	
	UIButton *lastbutton=(UIButton *)[self viewWithTag:(NSInteger)(self.selectedIndex+9000)];
	
	NSInteger index = button.tag-9000;
	if(index == self.selectedIndex){
		return;
	}else{
		[lastbutton setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
	}
	
	[self.containerScroll scrollRectToVisible:CGRectMake(index*KScreen.width,0, KScreen.width, 1) animated:YES];
	float xx = index*KScreen.width;
	int rate = round(xx/KScreen.width);
	if (rate != self.selectedIndex) {
		[self reuseVCInIndex:rate];
	}
	if (self.delegate && [self.delegate respondsToSelector:@selector(sliderSwitch:didSelectedIndex:)]) {
		[self.delegate sliderSwitch:self didSelectedIndex:index];
	}
	[self scrollRectToVisible:CGRectMake(index*self.buttonSize.width*UnSelectedScale+self.buttonSize.width/2-[[UIScreen mainScreen] bounds].size.width/2,0, self.frame.size.width, self.frame.size.height) animated:YES];
	if (animated){
		//滑动
		self.sliderLayer.frame = CGRectMake(button.frame.origin.x+button.frame.size.width/2-5, self.lastSliderFrame.origin.y, self.sliderSize.width, self.sliderSize.height);
		//	长短
		CABasicAnimation *sliderAnimation = [CABasicAnimation animation];
		sliderAnimation.keyPath = @"transform.scale.x";
		CGFloat itemInterval = labs(self.selectedIndex-index);
		if (self.sliderFlexibleWidthEnable) {
			sliderAnimation.toValue = [NSNumber numberWithFloat:1.];
			sliderAnimation.speed = 10/itemInterval;
		}else{
			sliderAnimation.toValue = [NSNumber numberWithFloat:self.buttonSize.width/self.sliderSize.width];
			sliderAnimation.speed = 3;
		}
		sliderAnimation.autoreverses = YES;
		sliderAnimation.delegate = self;
		[self.sliderLayer addAnimation:sliderAnimation forKey:@"sliderAnimation"];
		// 	放大
		CABasicAnimation *selectedAnimation = [CABasicAnimation animation];
		selectedAnimation.keyPath = @"transform.scale";
		selectedAnimation.toValue = @1.0;
		selectedAnimation.removedOnCompletion = NO;
		selectedAnimation.fillMode = kCAFillModeForwards;
		[button.layer addAnimation:selectedAnimation forKey:@"selectedAnimation"];
		if (self.selectedFontBlod) button.titleLabel.font = [UIFont boldSystemFontOfSize:[_titleFont pointSize]*SelectedScale];
		//	缩小
		CABasicAnimation *unSelectedAnimation = [CABasicAnimation animation];
		unSelectedAnimation.keyPath = @"transform.scale";
		unSelectedAnimation.toValue = @(UnSelectedScale);
		unSelectedAnimation.removedOnCompletion = NO;
		unSelectedAnimation.fillMode = kCAFillModeForwards;
		[lastbutton.layer addAnimation:unSelectedAnimation forKey:@"unSelectedAnimation"];
		if (self.selectedFontBlod) lastbutton.titleLabel.font = [UIFont systemFontOfSize:[_titleFont pointSize]*SelectedScale];
		self.selectedIndex = index;
	}else{
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		self.sliderLayer.frame = CGRectMake(button.frame.origin.x+button.frame.size.width/2-5, self.lastSliderFrame.origin.y, self.sliderSize.width, self.sliderSize.height);
		[button.layer removeAllAnimations];
		[lastbutton.layer removeAllAnimations];

		button.layer.transform = CATransform3DMakeScale(1, 1, 1);
		if (self.selectedFontBlod) button.titleLabel.font = [UIFont boldSystemFontOfSize:[_titleFont pointSize]*SelectedScale];
		lastbutton.layer.transform = CATransform3DMakeScale(UnSelectedScale, UnSelectedScale, 1);
		if (self.selectedFontBlod) lastbutton.titleLabel.font = [UIFont systemFontOfSize:[_titleFont pointSize]*SelectedScale];
		[CATransaction commit];
		self.selectedIndex = index;
	}
	
	[self reuseVCInIndex:rate];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	if ([_myDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
		[_myDelegate scrollViewWillBeginDragging:self];
	}
	if (scrollView == self.containerScroll) {
		//全局变量记录滑动前的contentOffset
		[self anchorScrollViewPoint:scrollView];
	}
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (scrollView == self.containerScroll&&self.sliderFlexibleWidthEnable) {
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		CGFloat sliderScan = (self.contentSize.width/self.dataArray.count)/KScreen.width;
		CGFloat scrollDistance = scrollView.contentOffset.x - self.lastContentOffset;
		if (scrollDistance>=0) {//👉
			if (scrollDistance <= KScreen.width/2){
				CGFloat sliderFlexibleWidth = scrollDistance*sliderScan*2;
				self.sliderLayer.frame = CGRectMake(self.lastSliderFrame.origin.x, self.lastSliderFrame.origin.y, self.lastSliderFrame.size.width+sliderFlexibleWidth, self.lastSliderFrame.size.height);
			}else if (scrollDistance > KScreen.width/2&&scrollDistance < KScreen.width) {
				CGFloat sliderFlexibleWidth = (KScreen.width-scrollDistance)*sliderScan*2;
				CGFloat xMoveDistance = (KScreen.width/2-scrollDistance)*sliderScan*2;

				self.sliderLayer.frame = CGRectMake(self.lastSliderFrame.origin.x-xMoveDistance, self.lastSliderFrame.origin.y, self.lastSliderFrame.size.width+sliderFlexibleWidth, self.lastSliderFrame.size.height);
			}else if (scrollDistance >= KScreen.width) {
				[self anchorScrollViewPoint:scrollView];
				[self scrollRectToVisible:CGRectMake((round(scrollView.contentOffset.x/KScreen.width))*self.buttonSize.width*UnSelectedScale+self.buttonSize.width/2-[[UIScreen mainScreen] bounds].size.width/2,0, self.frame.size.width, self.frame.size.height) animated:YES];
			}
		}else if (scrollDistance<0){//👈
			if (scrollDistance >= -KScreen.width/2){
				CGFloat sliderFlexibleWidth = scrollDistance*sliderScan*2;
				self.sliderLayer.frame = CGRectMake(self.lastSliderFrame.origin.x+sliderFlexibleWidth, self.lastSliderFrame.origin.y, self.lastSliderFrame.size.width-sliderFlexibleWidth, self.lastSliderFrame.size.height);
			}else if (scrollDistance < -KScreen.width/2 && scrollDistance > -KScreen.width) {
				CGFloat sliderFlexibleWidth = (KScreen.width+scrollDistance)*sliderScan*2;
				CGFloat xMoveDistance = KScreen.width*sliderScan;
				self.sliderLayer.frame = CGRectMake(self.lastSliderFrame.origin.x-xMoveDistance, self.lastSliderFrame.origin.y, self.lastSliderFrame.size.width+sliderFlexibleWidth, self.lastSliderFrame.size.height);
			}else if (scrollDistance <= -KScreen.width) {
				[self anchorScrollViewPoint:scrollView];
				[self scrollRectToVisible:CGRectMake((round(scrollView.contentOffset.x/KScreen.width))*self.buttonSize.width*UnSelectedScale+self.buttonSize.width/2-[[UIScreen mainScreen] bounds].size.width/2,0, self.frame.size.width, self.frame.size.height) animated:YES];

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
	self.lastContentOffset = scrollView.contentOffset.x;//判断左右滑动时
	int rate = round(scrollView.contentOffset.x/KScreen.width);
	UIButton *button=(UIButton *)[self viewWithTag:rate+9000];

	self.lastSliderFrame = CGRectMake(button.frame.origin.x+button.frame.size.width/2-5, self.lastSliderFrame.origin.y, self.sliderSize.width, self.sliderSize.height);;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	if (scrollView == self.containerScroll) {
		float xx = scrollView.contentOffset.x;
		int rate = round(xx/KScreen.width);
		if (rate != self.selectedIndex) {
			[self slideToIndex:rate];
		}else{
			if (self.sliderLayer.frame.size.width != self.sliderSize.width) {
				UIButton *button=(UIButton *)[self viewWithTag:self.selectedIndex+9000];
				self.sliderLayer.frame = CGRectMake(button.frame.origin.x+button.frame.size.width/2-5, self.lastSliderFrame.origin.y, self.sliderSize.width, self.sliderSize.height);
			}
		}
	}
	if ([_myDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
		[_myDelegate scrollViewDidEndDecelerating:self];
	}
}


#pragma mark - SubVCReuseOpration
-(void)reuseVCInIndex:(NSInteger)rate{
	if (![self.visiableVCs containsObject:self.dataArray[rate].VC]) {
		[self addSubVCInIndex:rate];
		[self removeLastVisiableVCBesides:rate];
	}
	if (rate+1<=self.dataArray.count-1) {
		if (![self.visiableVCs containsObject:self.dataArray[rate+1].VC]) {
			[self addSubVCInIndex:rate+1];
			[self removeLastVisiableVCBesides:rate];
		}
	}
	if (rate-1>=0) {
		if (![self.visiableVCs containsObject:self.dataArray[rate-1].VC]) {
			[self addSubVCInIndex:rate-1];
			[self removeLastVisiableVCBesides:rate];
		}
	}
}

-(void)addSubVCInIndex:(NSInteger)index{
	if (!self.dataArray[index].VC) {
		self.dataArray[index].VC = [self.delegate sliderSwitch:self setSubViewControllerInIndex:index];
	}
	[self.containerScroll addSubview:self.dataArray[index].VC.view];
	if (![self.visiableVCs containsObject:self.dataArray[index].VC]) {
		[self.visiableVCs addObject:self.dataArray[index].VC];
	}
}

-(void)removeLastVisiableVCBesides:(NSInteger)index{
	if (self.visiableVCs.count>=3) {
		if (self.visiableVCs[0] != self.dataArray[index].VC) {
			[self.visiableVCs[0].view removeFromSuperview];
			[self.visiableVCs removeObjectAtIndex:0];
		}else{
			
			[self.visiableVCs[1].view removeFromSuperview];
			[self.visiableVCs removeObjectAtIndex:1];
		}
	}
}

#pragma mark - LazyLoading
-(void)setSelectedIndex:(NSInteger)selectedIndex{
	if (_selectedIndex!=selectedIndex) {
		_selectedIndex = selectedIndex;
	}
	if ([self.dataArray[selectedIndex].VC respondsToSelector:@selector(viewDidScrollToVisiableArea)]) {
		[self.dataArray[selectedIndex].VC viewDidScrollToVisiableArea];
	}
}

-(void)setContainerScroll:(UIScrollView *)containerScroll{
	if (_containerScroll!=containerScroll) {
		_containerScroll = containerScroll;
	}
	_containerScroll.delegate = self;
	[_containerScroll scrollRectToVisible:CGRectMake(self.selectedIndex*KScreen.width,0, KScreen.width, 1) animated:NO];
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

-(void)setDataArray:(NSMutableArray <SWModel *>*)dataArray{
	if (_dataArray != dataArray) {
		_dataArray = dataArray;
	}
	self.contentSize = CGSizeMake(_dataArray.count*self.buttonSize.width*UnSelectedScale,self.frame.size.height);
	[dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.buttonSize.width*idx*UnSelectedScale-(self.buttonSize.width-self.buttonSize.width*UnSelectedScale)/2, (self.frame.size.height-self.buttonSize.height)/2, self.buttonSize.width, self.buttonSize.height)];
		button.layer.masksToBounds = YES;
		button.layer.cornerRadius = self.buttonSize.width<self.buttonSize.height?self.buttonSize.width/2.:self.buttonSize.height/2.;
		[button addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
		button.backgroundColor = [UIColor clearColor];
		[button setTitle:dataArray[idx].title forState:UIControlStateNormal];
		if (self.selectedIndex != idx) {
			[button setTitleColor:self.selectedTitleColor forState:UIControlStateNormal];
			// 	缩小
			[CATransaction begin];
			[CATransaction setDisableActions:YES];
			button.layer.transform = CATransform3DMakeScale(UnSelectedScale, UnSelectedScale, 1);
			[CATransaction commit];
		}else{
			[button setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
		}
		button.tag = idx+9000;
		[self addSubview:button];
	}];
}

-(void)setTitleFont:(UIFont *)titleFont{
	if (_titleFont != titleFont) {
		_titleFont = titleFont;
	}
	for (NSObject *btn in self.subviews) {
		if ([btn isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)btn;
			if ((button.tag-9000 == _selectedIndex)&&_selectedFontBlod) {
				button.titleLabel.font = [UIFont boldSystemFontOfSize:[titleFont pointSize]*SelectedScale];
			}else{
				button.titleLabel.font = [UIFont systemFontOfSize:[titleFont pointSize]*SelectedScale];
			}
		}
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

@end
