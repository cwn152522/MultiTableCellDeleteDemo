//
//  NavigationView.m
//  GuPiaoTong
//
//  Created by songzhaojie on 17/1/12.
//  Copyright © 2017年 songzhaojie. All rights reserved.
//

#import "NavigationView.h"
#import "UIView+CWNView.h"
#define KImageThemeImageName @"导航-16" // [AppDataManager shareInstance].UserInReviewUseEnable?@"导航-16" :@"导航-15"
#define KImageTheme [UIImage imageNamed:KImageThemeImageName]
#define ShiPei(a)  ([UIScreen mainScreen].bounds.size.width/375.0*(a))
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavigationbarHeight (kStatusBarHeight+44.0)
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49) // 适配iPhone x 底栏高度
//#import "UIImage+ImageEffects.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self
#define WeakObj(o) __weak typeof(o) weak##o = o
#define MAIN_WP  [UIScreen mainScreen].bounds.size.width/([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? 667.0 : 375.0)

@interface NavigationView ()
@property (strong, nonatomic) UIScrollView *alphaChangeFollowScrollView;
@property (weak, nonatomic) UIView *changeableView;//alpha渐变视图，默认为自身
@property (assign, nonatomic) CGFloat endChange_position;
@property (copy, nonatomic) void(^block)(UIControl *sender);
@property(nonatomic, strong)NSMutableArray <MYImageButton *>*rightItems;
@end


@implementation NavigationView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


- (void)dealloc{
    if(self.alphaAutoChange == YES){
        [self.alphaChangeFollowScrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)setAlphaAutoChangeFollowingScrollView:(UIScrollView *)scrollView endChange_position:(CGFloat)endChange_position changeView:(UIView *)view{
    if(self.endChange_position == 0){
        _alphaAutoChange = YES;
        @try {
            self.alphaChangeFollowScrollView = scrollView;
            [self.alphaChangeFollowScrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:nil];
        } @catch (NSException *exception) {
            NSLog(@"gewrg");
        } @finally {
            
        }
        self.endChange_position = CGFLOAT_MAX;//默认无穷大
    }
    self.endChange_position = endChange_position;
    
    self.changeableView = view;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"contentOffset"]){
        CGPoint point = [[change valueForKey:@"new"] CGPointValue];
        CGFloat originY = point.y;
        UIView *view = self.changeableView ?: self;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self setBackground];
        _leftBtn=[MYImageButton buttonWithType:UIButtonTypeCustom];
        
        [_leftBtn addTarget:self action:@selector(Leftbtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftBtn];
        _zHongJianlable=[[UILabel alloc]init];
        [self addSubview:_zHongJianlable];
        _reghtBtn=[MYImageButton buttonWithType:UIButtonTypeCustom];
        [_reghtBtn addTarget:self action:@selector(reghtBtn1) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_reghtBtn];
        
        _leftchangeBt =[[UIButton alloc]init];
        [_leftchangeBt addTarget:self action:@selector(leftChange) forControlEvents:UIControlEventTouchUpInside];
        _rightchangeBtn = [[UIButton alloc]init];
        [_rightchangeBtn addTarget:self action:@selector(rightChange) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftchangeBt];
        [self addSubview:_rightchangeBtn];
        
        
        
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self){
        [self setBackground];
        _leftBtn=[MYImageButton buttonWithType:UIButtonTypeCustom];
        
        [_leftBtn addTarget:self action:@selector(Leftbtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftBtn];
        _zHongJianlable=[[UILabel alloc]init];
        [self addSubview:_zHongJianlable];
        _reghtBtn=[MYImageButton buttonWithType:UIButtonTypeCustom];
        [_reghtBtn addTarget:self action:@selector(reghtBtn1) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_reghtBtn];
        
        _leftchangeBt =[[UIButton alloc]init];
        [_leftchangeBt addTarget:self action:@selector(leftChange) forControlEvents:UIControlEventTouchUpInside];
        _rightchangeBtn = [[UIButton alloc]init];
        [_rightchangeBtn addTarget:self action:@selector(rightChange) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftchangeBt];
        [self addSubview:_rightchangeBtn];
        
        
    }
    
    return self;
}



- (void)setBackground{
    [self setBackgroundWithImage:KImageTheme];
    //Base style for 矩形 32
    //    UIView *style = self;
    //    style.alpha = 1;
    //
    //    //Gradient 0 fill for 矩形 32
    //    self.backgroundLayer = [[CAGradientLayer alloc] init];
    //    self.backgroundLayer.frame = style.bounds;
    //    self.backgroundLayer.colors = @[
    //                              (id)[UIColor colorWithRed:203.0f/255.0f green:8.0f/255.0f blue:20.0f/255.0f alpha:1.0f].CGColor,
    //                              (id)[UIColor colorWithRed:203.0f/255.0f green:8.0f/255.0f blue:20.0f/255.0f alpha:1.0f].CGColor];
    //    self.backgroundLayer.locations = @[@0, @1];
    //    [self.backgroundLayer setStartPoint:CGPointMake(1, 1)];
    //    [self.backgroundLayer setEndPoint:CGPointMake(0, 1)];
    //    [style.layer addSublayer:self.backgroundLayer];
}

- (void)setBackgroundWithImage:(UIImage *)imageView{
    [self.bgImageView removeFromSuperview];
    self.bgImageView = [[UIImageView alloc]initWithImage:imageView];
    [self insertSubview:self.bgImageView atIndex:0];
    [self.bgImageView cwn_makeConstraints:^(UIView *maker) {
        maker.edgeInsetsToSuper(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    return;
}


-(void)setTitle:(NSString *)title leftBtnImage:(NSString *)leftImg rightBtnImage:(NSString *)rightImg{
    if (title&&title.length) {
        [self zhongJianLableSheZhiLable:title withZiShiYing:NO withFont:17.0];
        NSArray *titles = [title componentsSeparatedByString:@","];
        if (titles.count==2) {
            NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:titles.firstObject
                                                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:titles.lastObject
                                                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            NSMutableAttributedString *tmp = [[NSMutableAttributedString alloc] initWithString:@"\n"];
            [string1 appendAttributedString:tmp];
            [string1 appendAttributedString:string2];
            _zHongJianlable.attributedText = string1;
        }
    }
    
    if (leftImg&&leftImg.length) {
        [self leftBtnSheZhiImage:leftImg withHidden:NO];
    }
    
    if (rightImg&&rightImg.length) {
        [self reghtBtnSheZhiImage:rightImg withText:nil withHidden:NO];
    }
}


-(void)setTitle:(NSString*)title leftBtnImage:(NSString*)leftImg rightBtnText:(NSString *)right{
    if (title&&title.length) {
        [self zhongJianLableSheZhiLable:title withZiShiYing:NO withFont:17.0];
        NSArray *titles = [title componentsSeparatedByString:@","];
        if (titles.count==2) {
            NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:titles.firstObject
                                                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:titles.lastObject
                                                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            NSMutableAttributedString *tmp = [[NSMutableAttributedString alloc] initWithString:@"\n"];
            [string1 appendAttributedString:tmp];
            [string1 appendAttributedString:string2];
            _zHongJianlable.attributedText = string1;
        }
    }
    
    if (leftImg&&leftImg.length) {
        [self leftBtnSheZhiImage:leftImg withHidden:NO];
    }
    
    if (right&&right.length) {
        [self reghtBtnSheZhiImage:nil withText:right withHidden:NO];
    }
}

-(void)setSegmentItems:(NSArray<NSString *> *)titles{
    
    [self zhongJianSegmentSheZhiSegmentItems:titles withFont:17.0 width:ShiPei(70) * [titles count]];
}


-(void)setSegmentItemsSP:(NSArray<NSString *> *)titles{
    
    [self zhongJianSegmentSheZhiSegmentItems:titles withFont:17.0 width:ShiPei(90) * [titles count]];
}
















- (void)leftBtnSheZhiImage:(NSString *)image withHidden:(BOOL)hidded{
    UIImage *imageView = [UIImage imageNamed:image];
    //    _leftBtn.frame=CGRectMake(floatX, floatY, width, height);
    [_leftBtn cwn_makeConstraints:^(UIView *maker) {
        maker.leftToSuper(2.5).topToSuper(kStatusBarHeight).bottomToSuper(0).width(100);
    }];
    
    [self layoutIfNeeded];
    if(self.leftImageSizeLimited.width > 0){
        _leftBtn.imageBounds=CGRectMake(10, (self.frame.size.height - kStatusBarHeight) / 2 - self.leftImageSizeLimited.height / 2,  self.leftImageSizeLimited.width, self.leftImageSizeLimited.height);
    }else{
        _leftBtn.imageBounds=CGRectMake(10, (self.frame.size.height - kStatusBarHeight) / 2 - imageView.size.height / 2,  imageView.size.width, imageView.size.height);
    }
    [_leftBtn setImage:imageView forState:UIControlStateNormal];
    
    _leftBtn.hidden=hidded;
}
-(void)leftBtnSheZhiImage:(NSString *)image withHidden:(BOOL)hidded withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)height
{
    [self leftBtnSheZhiImage:image withHidden:hidded];
}

- (void)zhongJianLableSheZhiLable:(NSString *)lable withZiShiYing:(BOOL)ZiShiYing withFont:(float)font{
    WeakObj(self);
    [_zHongJianlable cwn_makeConstraints:^(UIView *maker) {
        weakself.zHongJianlableLeftToSuper = maker.centerXtoSuper(0).topToSuper(kStatusBarHeight).bottomToSuper(0).leftToSuper(40).lastConstraint;
    }];
    
    _zHongJianlable.adjustsFontSizeToFitWidth=ZiShiYing;
    _zHongJianlable.textAlignment=NSTextAlignmentCenter;
    _zHongJianlable.font=[UIFont boldSystemFontOfSize:font];
    _zHongJianlable.text=lable;
    _zHongJianlable.textColor=[UIColor whiteColor];
    _zHongJianlable.numberOfLines = 0;
    
}
-(void)zhongJianLableSheZhiLable:(NSString *)lable withZiShiYing:(BOOL)ZiShiYing  withFont:(float)font withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)height
{
    [self zhongJianLableSheZhiLable:lable withZiShiYing:ZiShiYing withFont:font];
}

- (void)zhongJianSegmentSheZhiSegmentItems:(NSArray<NSString *> *)titles withFont:(float)font width:(CGFloat)width{
    if([titles count] == 0)
        return;
    
    static NSLayoutConstraint *segmentWidth =nil;
    
    if(_zHongJianSegment == nil){
        width = width < ShiPei(140) ? ShiPei(140) : width;
        _zHongJianSegment = [[UISegmentedControl alloc] init];
        _zHongJianSegment.tintColor = [UIColor whiteColor];
        [_zHongJianSegment addTarget:self action:@selector(onClickSegmentControl:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_zHongJianSegment];
        [_zHongJianSegment cwn_makeConstraints:^(UIView *maker) {
            segmentWidth =  maker.bottomToSuper(10).centerXtoSuper(0).height(30).width(width).lastConstraint;
        }];
    }
    
    __weak typeof(self) weakSelf = self;
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf.zHongJianSegment insertSegmentWithTitle:obj atIndex:idx animated:NO];
    }];
    
    segmentWidth.constant = width / [titles count] * [titles count];
    
    _zHongJianSegment.selectedSegmentIndex = 0;
}

- (void)reghtBtnSheZhiImage:(NSString *)image withText:(NSString *)text withHidden:(BOOL)hidded{
    [_reghtBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _reghtBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    _reghtBtn.titleLabel.textColor=[UIColor whiteColor];
    
    [_reghtBtn cwn_makeConstraints:^(UIView *maker) {
        maker.rightToSuper(2.5).topToSuper(kStatusBarHeight).bottomToSuper(0).width(100);
    }];
    
    if([image length]){//图片
        //    _reghtBtn.frame=CGRectMake(floatX, floatY, width, height);
        UIImage *imageView = [UIImage imageNamed:image];
        //    _leftBtn.frame=CGRectMake(floatX, floatY, width, height);
        _reghtBtn.imageBounds=CGRectMake(100 - imageView.size.width - 10, (self.frame.size.height - kStatusBarHeight) / 2 - imageView.size.height / 2, imageView.size.width, imageView.size.height);
        [_reghtBtn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    }
    
    if([text length]){//文字
        _reghtBtn.titleBounds = CGRectMake(0, 0, 90, kNavigationbarHeight-kStatusBarHeight);
        [_reghtBtn setTitle:text forState:UIControlStateNormal];
        [_reghtBtn.titleLabel setTextAlignment:NSTextAlignmentRight];
    }
    
    
    _reghtBtn.hidden=hidded;
}
-(void)reghtBtnSheZhiImage:(NSString *)image withText:(NSString *)text withHidden:(BOOL)hidded withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)height withImageWidth:(float)imageWidth withImageHeight:(float)imageHeight
{
    [self reghtBtnSheZhiImage:image withText:text withHidden:hidded];
}

//左边切换按钮
-(void)leftChangeBtnSheZhiImage:(NSString *)image withText:(NSString *)text withHidden:(BOOL)hidded withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)height withImageWidth:(float)imageWidth withImageHeight:(float)imageHeight {
    
    [_leftchangeBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_leftchangeBt cwn_makeConstraints:^(UIView *maker) {
        maker.leftToSuper(100*MAIN_WP).topToSuper(kStatusBarHeight).bottomToSuper(0).width(40*MAIN_WP);
    }];
    //    [_zHongJianlable cwn_makeConstraints:^(UIView *maker) {
    //        maker.centerXtoSuper(0).topToSuper(20).bottomToSuper(0);
    //    }];
    //    _leftchangeBt.frame = CGRectMake(_zHongJianlable.frame.origin.x - 30, _zHongJianlable.frame.origin.y, 30, 30);
    [_leftchangeBt setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    _leftchangeBt.hidden=hidded;
    
    
    
}
//右边切换按钮
-(void)rightChangeBtnSheZhiImage:(NSString *)image withText:(NSString *)text withHidden:(BOOL)hidded withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)height withImageWidth:(float)imageWidth withImageHeight:(float)imageHeight{
    [_rightchangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_rightchangeBtn cwn_makeConstraints:^(UIView *maker) {
        maker.rightToSuper(100*MAIN_WP).topToSuper(kStatusBarHeight).bottomToSuper(0).width(40*MAIN_WP);
    }];
    _rightchangeBtn.frame = CGRectMake(_zHongJianlable.frame.origin.x + 30, _zHongJianlable.frame.origin.y, 30, 30);
    [_rightchangeBtn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    _rightchangeBtn.hidden=hidded;
}

-(void)Leftbtn
{
    if ([_delegate respondsToSelector:@selector(navigationViewLeftDlegate)]) {
        [_delegate navigationViewLeftDlegate];
    }
    
    
}
-(void)reghtBtn1
{
    if ([_delegate respondsToSelector:@selector(navigationViewReghtDlegate)]) {
        [_delegate navigationViewReghtDlegate];
    }
    
    
    
}
- (void)onClickSegmentControl:(UISegmentedControl *)segment{
    if ([_delegate respondsToSelector:@selector(navigationViewCenterSegmentControlDelegate:)]) {
        [_delegate navigationViewCenterSegmentControlDelegate:segment.selectedSegmentIndex];
    }
    
    
}
-(void)leftChange{
    
    if ([_delegate respondsToSelector:@selector(navigationViewLeftChangeDelegate)]) {
        [_delegate navigationViewLeftChangeDelegate];
    }
    
}
-(void)rightChange{
    
    if ([_delegate respondsToSelector:@selector(navigationViewRightChangeDelegate)]) {
        [_delegate navigationViewRightChangeDelegate];
    }
}


-(void)setTitle:(NSString*)title leftBtnImage:(NSString*)leftImg rightBtnImages:(NSString *)btnImages, ... NS_REQUIRES_NIL_TERMINATION {
    if (title&&title.length) {
        [self zhongJianLableSheZhiLable:title withZiShiYing:NO withFont:17.0];
        NSArray *titles = [title componentsSeparatedByString:@","];
        if (titles.count==2) {
            NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:titles.firstObject
                                                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:titles.lastObject
                                                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            NSMutableAttributedString *tmp = [[NSMutableAttributedString alloc] initWithString:@"\n"];
            [string1 appendAttributedString:tmp];
            [string1 appendAttributedString:string2];
            _zHongJianlable.attributedText = string1;
        }
    }
    if (leftImg&&leftImg.length) {
        [self leftBtnSheZhiImage:leftImg withHidden:NO];
    }
    
    NSMutableArray *rightImgArray = [NSMutableArray array];
    va_list args;
    va_start(args, btnImages);
    if (btnImages)
    {
        [rightImgArray addObject:btnImages];
        while (1)
        {
            NSString *  otherButtonTitle = va_arg(args, NSString *);
            if(otherButtonTitle == nil) {
                break;
            } else {
                [rightImgArray addObject:otherButtonTitle];
            }
        }
    }
    va_end(args);
    if (self.rightItems == nil) {
        self.rightItems = [NSMutableArray arrayWithCapacity:0];
    }
    [self.rightItems removeAllObjects];
    WS(weakSelf);
    [rightImgArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MYImageButton * rightIndexL = [MYImageButton buttonWithType:UIButtonTypeCustom];
        [weakSelf addSubview:rightIndexL];
        UIImage *image = [UIImage imageNamed:obj];
        [rightIndexL setImage:image forState:UIControlStateNormal];
        [rightIndexL cwn_makeConstraints:^(UIView *maker) {
            maker.rightToSuper(idx *(20 +image.size.width) +(idx==0?3:0)).topToSuper(kStatusBarHeight).bottomToSuper(0).width(20 +image.size.width +(idx==0?3:0));
        }];
        rightIndexL.tag = 1000 +idx;
        [rightIndexL addTarget:weakSelf action:@selector(navButtonRightsAction:) forControlEvents:UIControlEventTouchUpInside];
        [weakSelf.rightItems addObject:rightIndexL];
    }];
}
- (void)navButtonRightsAction:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(navigationViewRightClick:index:)]) {
        [_delegate navigationViewRightClick:sender index:sender.tag -1000];
    }
}

@end
