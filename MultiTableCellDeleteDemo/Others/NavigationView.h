//
//  NavigationView.h
//  GuPiaoTong
//
//  Created by songzhaojie on 17/1/12.
//  Copyright © 2017年 songzhaojie. All rights reserved.
//
#import "MYImageButton.h"
#import <UIKit/UIKit.h>

@protocol  NavigationViewLeftDlegate<NSObject>
@optional
-(void)navigationViewLeftDlegate;
-(void)navigationViewReghtDlegate;
-(void)navigationViewRightClick:(UIButton *)btn index:(NSInteger)index;
-(void)navigationViewCenterSegmentControlDelegate:(NSInteger)selectIndex;

-(void)navigationViewLeftChangeDelegate;
-(void)navigationViewRightChangeDelegate;

@end

@interface NavigationView : UIView
@property(nonatomic,strong)MYImageButton *leftBtn;
@property(nonatomic,strong)UILabel *zHongJianlable;
@property(nonatomic,strong)UISegmentedControl *zHongJianSegment;
@property(nonatomic,strong)MYImageButton* reghtBtn;
@property(nonatomic,assign) CGSize leftImageSizeLimited;//在设置图片前设置有效
@property(nonatomic,weak)id  delegate;

@property(nonatomic,strong)UIButton *leftchangeBt;
@property(nonatomic,strong)UIButton *rightchangeBtn;

@property(nonatomic, strong, readonly)NSMutableArray <MYImageButton *>*rightItems;

@property (strong, nonatomic) NSLayoutConstraint *zHongJianlableLeftToSuper;//中间文本框距离父视图左边的约束，默认为30

@property (strong, nonatomic) UIImageView *bgImageView;   // 导航栏渐变图层
- (void)setBackgroundWithImage:(UIImage *)imageView;

@property (assign, nonatomic, readonly) BOOL alphaAutoChange;//alpha渐变
- (void)setAlphaAutoChangeFollowingScrollView:(UIScrollView *)scrollView endChange_position:(CGFloat)endChange_position changeView:(UIView *)view;//根据scrollview滚动设置导航栏alpha渐变，changeView默认为整个导航栏，可传其他目标视图

//左边设置图片
-(void)leftBtnSheZhiImage:(NSString *)image withHidden:(BOOL)hidded DEPRECATED_ATTRIBUTE;//autolayout
-(void)leftBtnSheZhiImage:(NSString *)image withHidden:(BOOL)hidded withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)heightDEPRECATED_ATTRIBUTE DEPRECATED_ATTRIBUTE;

//中间设置lable
-(void)zhongJianLableSheZhiLable:(NSString *)lable withZiShiYing:(BOOL)ZiShiYing  withFont:(float)font DEPRECATED_ATTRIBUTE;//autolayout
-(void)zhongJianLableSheZhiLable:(NSString *)lable withZiShiYing:(BOOL)ZiShiYing  withFont:(float)font withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)height DEPRECATED_ATTRIBUTE;//文本框标题
- (void)zhongJianSegmentSheZhiSegmentItems:(NSArray<NSString *> *)titles withFont:(float)font width:(CGFloat)width DEPRECATED_ATTRIBUTE;//分段控件标题

//右边设置图片
-(void)reghtBtnSheZhiImage:(NSString *)image withText:(NSString *)text withHidden:(BOOL)hidded DEPRECATED_ATTRIBUTE;//autolayout
-(void)reghtBtnSheZhiImage:(NSString *)image withText:(NSString *)text withHidden:(BOOL)hidded withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)height withImageWidth:(float)imageWidth withImageHeight:(float)imageHeight DEPRECATED_ATTRIBUTE;


//左边切换按钮
-(void)leftChangeBtnSheZhiImage:(NSString *)image withText:(NSString *)text withHidden:(BOOL)hidded withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)height withImageWidth:(float)imageWidth withImageHeight:(float)imageHeight ;
//右边切换按钮
-(void)rightChangeBtnSheZhiImage:(NSString *)image withText:(NSString *)text withHidden:(BOOL)hidded withfloatX:(float)floatX withfloatY:(float)floatY withWidth:(float)width withHeight:(float)height withImageWidth:(float)imageWidth withImageHeight:(float)imageHeight ;
/**
 设置文字标题，两标题：xxx-xxx
 
 @param title 标题
 @param leftImg 左图片
 @param rightImg 右图片
 */
-(void)setTitle:(NSString*)title leftBtnImage:(NSString*)leftImg rightBtnImage:(NSString *)rightImg;


/**
 设置segment
 
 @param titles 标题数组
 */
-(void)setSegmentItems:(NSArray<NSString*>*)titles;


/**
 设置segment(适应视频节目 文字多的情况)
 
 @param titles 标题数组
 */
-(void)setSegmentItemsSP:(NSArray<NSString *> *)titles;


/**
 设置文字标题，两标题：xxx-xxx
 
 @param title 标题
 @param leftImg 左图片
 @param rightText 右文字
 */
-(void)setTitle:(NSString*)title leftBtnImage:(NSString*)leftImg rightBtnText:(NSString *)right;

/**
 设置文字标题，多个rightButton（image）
 
 @param title 标题
 @param leftImg 左图片
 @param btnImages 右图片
 */
-(void)setTitle:(NSString*)title leftBtnImage:(NSString*)leftImg rightBtnImages:(NSString *)btnImages, ... NS_REQUIRES_NIL_TERMINATION;

@end
