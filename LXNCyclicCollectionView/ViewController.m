//
//  ViewController.m
//  LXNCyclicCollectionView
//
//  Created by Leszek Kaczor on 26/03/15.
//  Copyright (c) 2015 Leszek Kaczor. All rights reserved.
//

#import "ViewController.h"
#import "LXNCyclicCollectionView.h"
#import "CyclicDataSource.h"

@interface ViewController ()

@property (nonatomic, strong) CyclicDataSource * topDataSource;
@property (nonatomic, strong) CyclicDataSource * botDataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topDataSource = [[CyclicDataSource alloc] init];
    self.topDataSource.itemsCount = 5;
    self.topDataSource.desc = @"Top";
    self.topCollectionView.dataSource = self.topDataSource;
    self.topCollectionView.delegate = self.topDataSource;
    
    self.botDataSource = [[CyclicDataSource alloc] init];
    self.botDataSource.itemsCount = 10;
    self.botDataSource.desc = @"Bottom";
    self.botCollectionView.dataSource = self.botDataSource;
    self.botCollectionView.delegate = self.botDataSource;
    
    [self.topCollectionView reloadData];
    [self.botCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
