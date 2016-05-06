//
//  LXNCyclicCollectionView.h
//  LXNCyclicCollectionView
//
//  Created by Leszek Kaczor on 26/03/15.
//  Copyright (c) 2015 Leszek Kaczor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (LXNCyclicCollectionView)

- (NSInteger)itemIndexForIndexPath:(NSIndexPath *)indexPath;

@end

@interface LXNCyclicCollectionView : UICollectionView

@property (nonatomic, assign) IBInspectable NSInteger additionalItems;
@property (nonatomic, assign) IBInspectable NSInteger displayItemIndex;
@property (nonatomic, assign) IBInspectable BOOL shouldMoveToFirstElementWhenSizeChanges;

- (void)scrollToFirstItem;

@end
