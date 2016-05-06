//
//  CyclicDataSource.m
//  LXNCyclicCollectionView
//
//  Created by Leszek Kaczor on 26/03/15.
//  Copyright (c) 2015 Leszek Kaczor. All rights reserved.
//

#import "CyclicDataSource.h"
#import "LXNCyclicCollectionView.h"

@implementation CyclicDataSource

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"testCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:(56 + arc4random()%200)/255.0f green:(56 + arc4random()%200)/255.0f blue:(56 + arc4random()%200)/255.0f alpha:1.0f];
    UILabel * label = (UILabel *)[cell viewWithTag:1];
    label.text = [NSString stringWithFormat:@"%ld", (long)[collectionView itemIndexForIndexPath:indexPath]];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 50;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%@ %@", self.desc, NSStringFromCGPoint(scrollView.contentOffset));
}


@end
