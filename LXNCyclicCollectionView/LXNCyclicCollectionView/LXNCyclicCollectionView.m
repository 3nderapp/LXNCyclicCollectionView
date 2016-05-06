//
//  LXNCyclicCollectionView.m
//  LXNCyclicCollectionView
//
//  Created by Leszek Kaczor on 26/03/15.
//  Copyright (c) 2015 Leszek Kaczor. All rights reserved.
//

#import "LXNCyclicCollectionView.h"
#import <objc/runtime.h>

NSString * const lxn_lastContentOffsetXKey = @"lxn_lastContentOffsetXKey";
NSString * const lxn_lastContentOffsetYKey = @"lxn_lastContentOffsetYKey";

static NSDictionary * swizzledDelegateClasses   = nil;
static NSDictionary * swizzledDataSourceClasses = nil;

@interface UICollectionView (LXNCyclicCollectionView_private)

- (void)lxn_markDelegateAsSwizzled:(id)object;
- (BOOL)lxn_isDelegateSwizzled:(id)object;
- (void)lxn_markDataSourceAsSwizzled:(id)object;
- (BOOL)lxn_isDataSourceSwizzled:(id)object;
- (void)lxn_setLastContentOffsetX:(CGFloat)contentOffsetX;
- (void)lxn_setLastContentOffsetY:(CGFloat)contentOffsetX;
- (void)lxn_scrollViewDidScroll:(LXNCyclicCollectionView *)scrollView;
- (NSInteger)lxn_collectionView:(LXNCyclicCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

@end

@interface LXNCyclicCollectionView()

@property (nonatomic, assign) CGRect lxn_prevBounds;

@end

@implementation LXNCyclicCollectionView

#pragma mark - Initializing
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self lxn_setLastContentOffsetX:FLT_MIN];
    [self lxn_setLastContentOffsetY:FLT_MIN];
}

#pragma mark - Overriding
- (void)setDelegate:(id<UICollectionViewDelegate>)delegate
{
    [self prepareDelegate:delegate];
    [super setDelegate:delegate];
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    [self prepareDataSource:dataSource];
    [super setDataSource:dataSource];
}

- (void)scrollToFirstItem
{
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    if (layout == nil)
        return;
    UICollectionViewScrollPosition position = layout.scrollDirection == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
    if ([self.dataSource collectionView:self numberOfItemsInSection:0] > self.additionalItems + self.displayItemIndex)
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.additionalItems + self.displayItemIndex inSection:0] atScrollPosition:position animated:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (CGRectEqualToRect(self.lxn_prevBounds, CGRectZero) || (self.shouldMoveToFirstElementWhenSizeChanges && !CGSizeEqualToSize(self.bounds.size, self.lxn_prevBounds.size)))
        [self scrollToFirstItem];
    self.lxn_prevBounds = self.bounds;
}

- (void)prepareDelegate:(id<UICollectionViewDelegate>)delegate
{
    if (delegate == nil || [self lxn_isDelegateSwizzled:delegate]) return;
    [self lxn_markDelegateAsSwizzled:delegate];
    [self swizzleMethod:@selector(scrollViewDidScroll:) withMethod:@selector(lxn_scrollViewDidScroll:) forClass:[delegate class]];
    
}

- (void)prepareDataSource:(id<UICollectionViewDataSource>)dataSource
{
    if (dataSource == nil || [self lxn_isDataSourceSwizzled:dataSource]) return;
    [self lxn_markDataSourceAsSwizzled:dataSource];
    [self swizzleMethod:@selector(collectionView:numberOfItemsInSection:) withMethod:@selector(lxn_collectionView:numberOfItemsInSection:) forClass:[dataSource class]];
}

- (void)swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector forClass:(Class)class
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod([UICollectionView class], swizzledSelector);
    
    if (originalMethod == nil)
    {
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
    } else {
        class_addMethod(class,
                        swizzledSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end

@implementation UICollectionView (LXNCyclicCollectionView)

#pragma mark - Public API
- (NSInteger)itemIndexForIndexPath:(NSIndexPath *)indexPath
{
    if (![self isKindOfClass:[LXNCyclicCollectionView class]]) return indexPath.item;
    LXNCyclicCollectionView * cyclicCollectionView = (LXNCyclicCollectionView *)self;
    NSInteger collectionViewCount = [cyclicCollectionView.dataSource collectionView:cyclicCollectionView numberOfItemsInSection:0] - 2 * cyclicCollectionView.additionalItems;
    if (collectionViewCount <= 0) return 0;
    NSInteger item = 0;
    if (indexPath.item < cyclicCollectionView.additionalItems)
        item = collectionViewCount - (cyclicCollectionView.additionalItems - indexPath.item);
    else
        item = indexPath.item - cyclicCollectionView.additionalItems;
    while (item < 0)
        item += collectionViewCount;
    return item % collectionViewCount;
}

#pragma mark - Associated Objects
- (void)lxn_markDelegateAsSwizzled:(id)object
{
    NSMutableDictionary * mutable = swizzledDelegateClasses ? [swizzledDelegateClasses mutableCopy] : [NSMutableDictionary dictionary];
    mutable[NSStringFromClass([object class])] = @YES;
    swizzledDelegateClasses = [mutable copy];
}

- (BOOL)lxn_isDelegateSwizzled:(id)object
{
    NSNumber * isSwizzled = swizzledDelegateClasses[NSStringFromClass([object class])];
    return isSwizzled.boolValue;
}

- (void)lxn_markDataSourceAsSwizzled:(id)object
{
    NSMutableDictionary * mutable = swizzledDataSourceClasses ? [swizzledDataSourceClasses mutableCopy] : [NSMutableDictionary dictionary];
    mutable[NSStringFromClass([object class])] = @YES;
    swizzledDataSourceClasses = [mutable copy];
}

- (BOOL)lxn_isDataSourceSwizzled:(id)object
{
    NSNumber * isSwizzled = swizzledDataSourceClasses[NSStringFromClass([object class])];
    return isSwizzled.boolValue;;
}

- (void)lxn_setLastContentOffsetX:(CGFloat)contentOffsetX
{
    objc_setAssociatedObject(self, (__bridge const void *)(lxn_lastContentOffsetXKey), @(contentOffsetX), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lxn_getLastContentOffsetX
{
    NSNumber * contentOffsetX = objc_getAssociatedObject(self, (__bridge const void *)(lxn_lastContentOffsetXKey));
    return contentOffsetX.floatValue;
}

- (void)lxn_setLastContentOffsetY:(CGFloat)contentOffsetY
{
    objc_setAssociatedObject(self, (__bridge const void *)(lxn_lastContentOffsetYKey), @(contentOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lxn_getLastContentOffsetY
{
    NSNumber * contentOffsetY = objc_getAssociatedObject(self, (__bridge const void *)(lxn_lastContentOffsetYKey));
    return contentOffsetY.floatValue;
}

#pragma mark - Swizzling <UICollectionViewDataSource>
- (NSInteger)lxn_collectionView:(LXNCyclicCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (![collectionView isKindOfClass:[LXNCyclicCollectionView class]])
        return [self lxn_collectionView:collectionView numberOfItemsInSection:section];
    NSInteger count = [self lxn_collectionView:collectionView numberOfItemsInSection:section];
    return count > 0 ? count + 2 * collectionView.additionalItems : count;
}


#pragma mark - Swizzling <UIScrollViewDelegate>
- (void)lxn_scrollViewDidScroll:(LXNCyclicCollectionView *)scrollView
{
    if (![scrollView isKindOfClass:[LXNCyclicCollectionView class]])
    {
        if ([self respondsToSelector:@selector(lxn_scrollViewDidScroll:)])
            [self lxn_scrollViewDidScroll:scrollView];
        return;
    }
    
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)scrollView.collectionViewLayout;
    
    CGFloat lastContentOffset;
    CGFloat currentOffset;
    CGFloat pageSize;
    BOOL updateContentOffset = NO;
    
    CGSize size = layout.itemSize;
    if ([self respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
         size = [(id<UICollectionViewDelegateFlowLayout>)self collectionView:scrollView layout:layout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

    CGFloat spacing = layout.minimumLineSpacing;
    if ([self respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)])
        spacing = [(id<UICollectionViewDelegateFlowLayout>)self collectionView:scrollView layout:layout minimumLineSpacingForSectionAtIndex:0];
    
    if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal)
    {
        lastContentOffset = [scrollView lxn_getLastContentOffsetX];
        currentOffset = scrollView.contentOffset.x;
        pageSize = size.width + spacing;
    } else {
        lastContentOffset = [scrollView lxn_getLastContentOffsetY];
        currentOffset = scrollView.contentOffset.y;
        pageSize = size.height + spacing;
    }

    if (lastContentOffset == FLT_MIN) {
        lastContentOffset = scrollView.contentOffset.x;
        if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal)
            [scrollView lxn_setLastContentOffsetX:lastContentOffset];
        else
            [scrollView lxn_setLastContentOffsetY:lastContentOffset];
        return;
    }
    
    CGFloat offset = pageSize * ([self lxn_collectionView:scrollView numberOfItemsInSection:0]);
    
    if (currentOffset < pageSize && lastContentOffset - currentOffset > FLT_EPSILON) {
        lastContentOffset = currentOffset + offset + 0.1;
        updateContentOffset = YES;
    } else if (currentOffset > offset + scrollView.additionalItems * pageSize  && lastContentOffset - currentOffset < FLT_EPSILON) {
        lastContentOffset = currentOffset - offset - 0.1;
        updateContentOffset = YES;
    } else {
        lastContentOffset = currentOffset;
    }
    
    if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal)
    {
        [scrollView lxn_setLastContentOffsetX:lastContentOffset];
        if (updateContentOffset)
            scrollView.contentOffset = (CGPoint){lastContentOffset, scrollView.contentOffset.y};
    } else {
        [scrollView lxn_setLastContentOffsetY:lastContentOffset];
        if (updateContentOffset)
            scrollView.contentOffset = (CGPoint){scrollView.contentOffset.x, lastContentOffset};
    }

    if ([self respondsToSelector:@selector(lxn_scrollViewDidScroll:)])
        [self lxn_scrollViewDidScroll:scrollView];
}


@end
