//
//  WeiboView.h
//  UnNamedWeibo
//
//  Created by Kitten Yang on 2/17/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboModel.h"

@interface WeiboView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *weiboText;
@property (strong, nonatomic) IBOutlet UICollectionView *weiboImageCollectionView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *text_between_imageYES;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *text_between_imageNO;

//weiboModel
@property (strong,nonatomic)WeiboModel *weiboModel;


@end
