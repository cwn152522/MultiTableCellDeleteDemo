//
//  UITableViewCell+ReuseID.m
//  SomeUIInfo
//
//  Created by 黄锦祥 on 2018/4/18.
//  Copyright © 2018年 晨曦科技. All rights reserved.
//

#import "UITableViewCell+ReuseID.h"
#import "UITableView+FDTemplateLayoutCell.h"
@implementation UITableViewCell (ReuseID)
+ (__kindof UITableViewCell *)cellFromXibWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if(cell){
        return cell;
    }
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
    [tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass([self class])];
    //    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    UITableViewCell * cell2 = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    return cell2;//height for row
}
+ (__kindof UITableViewCell *)cellFromClassWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if(cell)
        return cell;
    [tableView registerClass:[self class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

+ (__kindof UITableViewCell *)cellLoadNibNamed:(NSString *)name WithTableView:(UITableView *)tableView identifier:(NSString *)identifier{
    id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:name owner:self options:nil];
        for (UITableViewCell *nib_cell in nibs) {
            if([nib_cell.reuseIdentifier isEqualToString:identifier]){
                return nib_cell;
            }
        }
        if (cell == nil) {
            cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        return cell;
    }
    return cell;
}



@end
@implementation UITableViewHeaderFooterView (ReuseID)

+ (__kindof UITableViewHeaderFooterView *)HeaderFooterViewFromXibWithTableView:(UITableView *)tableView{
    UITableViewHeaderFooterView * HFView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([self class])];
    if(HFView)
        return HFView;
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
    [tableView registerNib:nib forHeaderFooterViewReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([self class])];
}
/** 适用于class创建  */
+ (__kindof UITableViewHeaderFooterView *)HeaderFooterViewFromClassWithTableView:(UITableView *)tableView {
    UITableViewHeaderFooterView * HFView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([self class])];
    if(HFView)
        return HFView;
    [tableView registerClass:[self class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([self class])];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.contentView.backgroundColor = backgroundColor;
}
@end
