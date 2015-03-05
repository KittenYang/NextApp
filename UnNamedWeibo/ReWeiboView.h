//
//  ReWeiboView.h
//  UnNamedWeibo
//
//  Created by Kitten Yang on 3/6/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboModel.h"


@interface ReWeiboView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>


@property (strong, nonatomic) IBOutlet UILabel *reWeiboText;
@property (strong, nonatomic) IBOutlet UICollectionView *reWeiboImageCollectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *reCollectionViewHeight;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *reWeiboHeight;


//weiboModel
@property (strong,nonatomic)WeiboModel *reWeiboModel;

@end
