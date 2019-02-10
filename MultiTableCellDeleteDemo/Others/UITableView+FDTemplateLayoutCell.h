// The MIT License (MIT)
//
// Copyright (c) 2015-2016 forkingdog ( https://github.com/forkingdog )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <UIKit/UIKit.h>

@interface UITableView (FDTemplateLayoutCellDebug)
@property (nonatomic, assign) BOOL fd_debugLogEnabled;
@end

@interface UITableView (FDTemplateLayoutCell)
// 让cell 用"frame layout"而不是"auto layout"。并将通过调用“-sizeThatFits:“得到cell的高度
//!!!!: 控制模版cell的高度计算模式 默认为NO。
@property (nonatomic, assign) BOOL fd_enforceFrameLayout;

/** 返回每个indexPath的高度 */
- (CGFloat)fd_heightForCellForIndexPath:(NSIndexPath *)indexPath;
/** 返回每个indexPath的高度 带缓存 */
- (CGFloat)fd_heightForCellWithCacheByIndexPath:(NSIndexPath *)indexPath;
/** 返回第一个indexPath的高度 带key缓存 */
- (CGFloat)fd_heightForCellWithCacheByKey:(id<NSCopying>)key;

@end
@interface UITableViewCell (FDReuseID)
/** 适用于大多数情况下的cell创建， xib多个cell的情况除外，不需要指定identifier */
+ (__kindof UITableViewCell *)fd_cellFromXibWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath;
/** 适用于class创建  */
+ (__kindof UITableViewCell *)fd_cellFromClassWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath;
/** 适用于xib多个cell (重用的identify为identifier，xib中需要设置)*/
+ (__kindof UITableViewCell *)fd_cellLoadNibNamed:(NSString *)name WithTableView:(UITableView *)tableView identifier:(NSString *)identifier;

@end
@interface UITableViewHeaderFooterView (FDReuseID)
/** 不需要指定identifier */
+ (__kindof UITableViewHeaderFooterView *)fd_HeaderFooterViewFromXibWithTableView:(UITableView *)tableView;
/** 适用于class创建  */
+ (__kindof UITableViewHeaderFooterView *)fd_HeaderFooterViewFromClassWithTableView:(UITableView *)tableView;


@end
