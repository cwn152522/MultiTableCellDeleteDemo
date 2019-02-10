//
//  UITableViewCell+ReuseID.h
//  SomeUIInfo
//
//  Created by 黄锦祥 on 2018/4/18.
//  Copyright © 2018年 晨曦科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (ReuseID)
/**
 适用于大多数情况下的cell创建， xib多个cell的情况除外，不需要指定identifier
 */

+ (__kindof UITableViewCell *)cellFromXibWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath;
+ (__kindof UITableViewCell *)cellFromClassWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath;
/**
 适用于xib多个cell (重用的identify为identifier，xib中需要设置)*/
+ (__kindof UITableViewCell *)cellLoadNibNamed:(NSString *)name WithTableView:(UITableView *)tableView identifier:(NSString *)identifier;

@end
@interface UITableViewHeaderFooterView (ReuseID)
/** 不需要指定identifier */
+ (__kindof UITableViewHeaderFooterView *)HeaderFooterViewFromXibWithTableView:(UITableView *)tableView;
/** 适用于class创建  */
+ (__kindof UITableViewHeaderFooterView *)HeaderFooterViewFromClassWithTableView:(UITableView *)tableView;


@end
