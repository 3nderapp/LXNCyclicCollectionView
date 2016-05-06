//
//  CyclicDataSource.h
//  LXNCyclicCollectionView
//
//  Created by Leszek Kaczor on 26/03/15.
//  Copyright (c) 2015 Leszek Kaczor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CyclicDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) NSInteger itemsCount;
@property (nonatomic, strong) NSString * desc;

@end
