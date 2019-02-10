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

#import "UITableView+FDTemplateLayoutCell.h"


#import <objc/runtime.h>


@interface FDIndexPathHeightCache : NSObject

// 自动启用驱动高度缓存 (删除，刷新等)
@property (nonatomic, assign) BOOL automaticallyInvalidateEnabled;

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateAllHeightCache;

@end

@interface UITableView (FDIndexPathHeightCache)
/// Height cache by index path. Generally, you don't need to use it directly.
@property (nonatomic, strong, readonly) FDIndexPathHeightCache *fd_indexPathHeightCache;
@end

@interface UITableView (FDIndexPathHeightCacheInvalidation)
@end

typedef NSMutableArray<NSMutableArray<NSNumber *> *> FDIndexPathHeightsBySection;

@interface FDIndexPathHeightCache ()
@property (nonatomic, strong) FDIndexPathHeightsBySection *heightsBySectionForPortrait;
@property (nonatomic, strong) FDIndexPathHeightsBySection *heightsBySectionForLandscape;
@end

@implementation FDIndexPathHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
        self.automaticallyInvalidateEnabled = YES;
    }
    return self;
}

- (FDIndexPathHeightsBySection *)heightsBySectionForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.heightsBySectionForPortrait: self.heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(FDIndexPathHeightsBySection *heightsBySection))block {
    block(self.heightsBySectionForPortrait);
    block(self.heightsBySectionForLandscape);
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
    return ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
#if CGFLOAT_IS_DOUBLE
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        heightsBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)invalidateAllHeightCache {
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths {
    // Build every section array or row array which is smaller than given index path.
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection {
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                heightsBySection[section] = [NSMutableArray array];
            }
        }
    }];
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        NSMutableArray<NSNumber *> *heightsByRow = heightsBySection[section];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= heightsByRow.count) {
                heightsByRow[row] = @-1;
            }
        }
    }];
}

@end

@implementation UITableView (FDIndexPathHeightCache)

- (FDIndexPathHeightCache *)fd_indexPathHeightCache {
    FDIndexPathHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        [self methodSignatureForSelector:nil];
        cache = [FDIndexPathHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

// We just forward primary call, in crash report, top most method in stack maybe FD's,
// but it's really not our bug, you should check whether your table view's data source and
// displaying cells are not matched when reloading.
static void __FD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(void(^callout)(void)) {
    callout();
}
#define FDPrimaryCall(...) do {__FD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(^{__VA_ARGS__});} while(0)

@implementation UITableView (FDIndexPathHeightCacheInvalidation)

+ (void)load {
    // All methods that trigger height cache's invalidation
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(reloadSections:withRowAnimation:),
        @selector(moveSection:toSection:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
        @selector(moveRowAtIndexPath:toIndexPath:)
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"fd_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)fd_reloadData {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
            [heightsBySection removeAllObjects];
        }];
    }
    FDPrimaryCall([self fd_reloadData];);
}

- (void)fd_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.fd_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    FDPrimaryCall([self fd_insertSections:sections withRowAnimation:animation];);
}

- (void)fd_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.fd_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    FDPrimaryCall([self fd_deleteSections:sections withRowAnimation:animation];);
}

- (void)fd_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.fd_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];
            
        }];
    }
    
    FDPrimaryCall([self fd_reloadSections:sections withRowAnimation:animation];);
}

- (void)fd_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildSectionsIfNeeded:section];
        [self.fd_indexPathHeightCache buildSectionsIfNeeded:newSection];
        [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    FDPrimaryCall([self fd_moveSection:section toSection:newSection];);
}

- (void)fd_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[indexPath.section] insertObject:@-1 atIndex:indexPath.row];
            }];
        }];
    }
    FDPrimaryCall([self fd_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)fd_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        
        NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
            if (!mutableIndexSet) {
                mutableIndexSet = [NSMutableIndexSet indexSet];
                mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
            }
            [mutableIndexSet addIndex:indexPath.row];
        }];
        
        [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[key.integerValue] removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    FDPrimaryCall([self fd_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)fd_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                heightsBySection[indexPath.section][indexPath.row] = @-1;
            }];
        }];
    }
    FDPrimaryCall([self fd_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)fd_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
        [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
            NSMutableArray<NSNumber *> *sourceRows = heightsBySection[sourceIndexPath.section];
            NSMutableArray<NSNumber *> *destinationRows = heightsBySection[destinationIndexPath.section];
            NSNumber *sourceValue = sourceRows[sourceIndexPath.row];
            NSNumber *destinationValue = destinationRows[destinationIndexPath.row];
            sourceRows[sourceIndexPath.row] = destinationValue;
            destinationRows[destinationIndexPath.row] = sourceValue;
        }];
    }
    FDPrimaryCall([self fd_moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];);
}

@end

#pragma mark - ************

@interface FDKeyedHeightCache : NSObject

- (BOOL)existsHeightForKey:(id<NSCopying>)key;
- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key;
- (CGFloat)heightForKey:(id<NSCopying>)key;

// Invalidation
- (void)invalidateHeightForKey:(id<NSCopying>)key;
- (void)invalidateAllHeightCache;
@end

@interface UITableView (FDKeyedHeightCache)

/// Height cache by key. Generally, you don't need to use it directly.
@property (nonatomic, strong, readonly) FDKeyedHeightCache *fd_keyedHeightCache;
@end
@interface FDKeyedHeightCache ()
@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *mutableHeightsByKeyForPortrait;
@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *mutableHeightsByKeyForLandscape;
@end

@implementation FDKeyedHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableHeightsByKeyForPortrait = [NSMutableDictionary dictionary];
        _mutableHeightsByKeyForLandscape = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary<id<NSCopying>, NSNumber *> *)mutableHeightsByKeyForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.mutableHeightsByKeyForPortrait: self.mutableHeightsByKeyForLandscape;
}

- (BOOL)existsHeightForKey:(id<NSCopying>)key {
    NSNumber *number = self.mutableHeightsByKeyForCurrentOrientation[key];
    return number && ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key {
    self.mutableHeightsByKeyForCurrentOrientation[key] = @(height);
}

- (CGFloat)heightForKey:(id<NSCopying>)key {
#if CGFLOAT_IS_DOUBLE
    return [self.mutableHeightsByKeyForCurrentOrientation[key] doubleValue];
#else
    return [self.mutableHeightsByKeyForCurrentOrientation[key] floatValue];
#endif
}

- (void)invalidateHeightForKey:(id<NSCopying>)key {
    [self.mutableHeightsByKeyForPortrait removeObjectForKey:key];
    [self.mutableHeightsByKeyForLandscape removeObjectForKey:key];
}

- (void)invalidateAllHeightCache {
    [self.mutableHeightsByKeyForPortrait removeAllObjects];
    [self.mutableHeightsByKeyForLandscape removeAllObjects];
}

@end

@implementation UITableView (FDKeyedHeightCache)

- (FDKeyedHeightCache *)fd_keyedHeightCache {
    FDKeyedHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [FDKeyedHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

















#pragma mark - ************

@implementation UITableView (FDTemplateLayoutCellDebug)
- (BOOL)fd_debugLogEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setFd_debugLogEnabled:(BOOL)debugLogEnabled {
    objc_setAssociatedObject(self, @selector(fd_debugLogEnabled), @(debugLogEnabled), OBJC_ASSOCIATION_RETAIN);
}
- (void)fd_debugLog:(NSString *)message {
    if (self.fd_debugLogEnabled) {
        NSLog(@"** FDTemplateLayoutCell ** %@", message);
    }
}
@end

@implementation UITableView (FDTemplateLayoutCell)
- (BOOL)fd_enforceFrameLayout {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setFd_enforceFrameLayout:(BOOL)enforceFrameLayout {
    objc_setAssociatedObject(self, @selector(fd_enforceFrameLayout), @(enforceFrameLayout), OBJC_ASSOCIATION_RETAIN);
}
- (CGFloat)fd_heightForCellForIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *templateLayoutCell =  [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
    
    //从dequeueReusableCellWithIdentifier取出之后,手动调用,以确保与实际cell(显示在屏幕上)行为一致。
    [templateLayoutCell prepareForReuse];
    
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);
    
    // 如果一个cell有辅助视图或系统配件类型,其内容视图的宽度更小。一些固定的值。
    if (templateLayoutCell.accessoryView) {
        contentViewWidth -= 16 + CGRectGetWidth(templateLayoutCell.accessoryView.frame);
    } else {
        static const CGFloat systemAccessoryWidths[] = {
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48
        };
        contentViewWidth -= systemAccessoryWidths[templateLayoutCell.accessoryType];
    }
    
    CGSize fittingSize = CGSizeZero;
    
    if (self.fd_enforceFrameLayout) {
        // FrameLayout
        SEL selector = @selector(sizeThatFits:);
        BOOL inherited = ![templateLayoutCell isMemberOfClass:UITableViewCell.class];
        BOOL overrided = [templateLayoutCell.class instanceMethodForSelector:selector] != [UITableViewCell instanceMethodForSelector:selector];
        if (inherited && !overrided) {
            //没继承UITableViewCell且覆盖了sizeThatFits
            NSAssert(NO, @"Customized cell must override '-sizeThatFits:' method if not using auto layout.");
        }
        fittingSize = [templateLayoutCell sizeThatFits:CGSizeMake(contentViewWidth, 0)];
    } else {
        // AutoLayout
        if (contentViewWidth > 0) {
            NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:templateLayoutCell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
            [templateLayoutCell.contentView addConstraint:widthFenceConstraint];
            fittingSize = [templateLayoutCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            [templateLayoutCell.contentView removeConstraint:widthFenceConstraint];
        }
    }
    //如果需要分隔线额外加1 px的空间。
    if (self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        fittingSize.height += 1.0 / [UIScreen mainScreen].scale;
    }
    
    if (self.fd_enforceFrameLayout) {
        [self fd_debugLog:[NSString stringWithFormat:@"calculate using frame layout - %@", @(fittingSize.height)]];
    } else {
        [self fd_debugLog:[NSString stringWithFormat:@"calculate using auto layout - %@", @(fittingSize.height)]];
    }
    
    return fittingSize.height;
}

- (CGFloat)fd_heightForCellWithCacheByIndexPath:(NSIndexPath *)indexPath {
    if ( !indexPath) {
        return 0;
    }

    // Hit cache
    if ([self.fd_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        [self fd_debugLog:[NSString stringWithFormat:@"hit cache by index path[%@:%@] - %@", @(indexPath.section), @(indexPath.row), @([self.fd_indexPathHeightCache heightForIndexPath:indexPath])]];
        return [self.fd_indexPathHeightCache heightForIndexPath:indexPath];
    }
    
    CGFloat height = [self fd_heightForCellForIndexPath:indexPath];
    [self.fd_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    [self fd_debugLog:[NSString stringWithFormat: @"cached by index path[%@:%@] - %@", @(indexPath.section), @(indexPath.row), @(height)]];
    
    return height;
}


- (CGFloat)fd_heightForCellWithCacheByKey:(id<NSCopying>)key{
    if ( !key) {
        return 0;
    }
    
    // Hit cache
    if ([self.fd_keyedHeightCache existsHeightForKey:key]) {
        CGFloat cachedHeight = [self.fd_keyedHeightCache heightForKey:key];
        [self fd_debugLog:[NSString stringWithFormat:@"hit cache by key[%@] - %@", key, @(cachedHeight)]];
        return cachedHeight;
    }
    CGFloat height = [self fd_heightForCellForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.fd_keyedHeightCache cacheHeight:height byKey:key];
    [self fd_debugLog:[NSString stringWithFormat:@"cached by key[%@] - %@", key, @(height)]];

    return height;
}



@end
@implementation UITableViewCell (FDReuseID)
+ (__kindof UITableViewCell *)fd_cellFromXibWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
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
+ (__kindof UITableViewCell *)fd_cellFromClassWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if(cell)
        return cell;
    [tableView registerClass:[self class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

+ (__kindof UITableViewCell *)fd_cellLoadNibNamed:(NSString *)name WithTableView:(UITableView *)tableView identifier:(NSString *)identifier{
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
@implementation UITableViewHeaderFooterView (FDReuseID)

+ (__kindof UITableViewHeaderFooterView *)fd_HeaderFooterViewFromXibWithTableView:(UITableView *)tableView{
    UITableViewHeaderFooterView * HFView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([self class])];
    if(HFView)
        return HFView;
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
    [tableView registerNib:nib forHeaderFooterViewReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([self class])];
}
/** 适用于class创建  */
+ (__kindof UITableViewHeaderFooterView *)fd_HeaderFooterViewFromClassWithTableView:(UITableView *)tableView {
    UITableViewHeaderFooterView * HFView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([self class])];
    if(HFView)
        return HFView;
    [tableView registerClass:[self class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([self class])];
}


@end
