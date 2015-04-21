//
//  detailWeiboView.h
//  UnNamedWeibo
//
//  Created by Kitten Yang on 4/21/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboView.h"
#import "WeiboModel.h"

@interface DetailWeiboView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *detailView_avatar;
@property (strong, nonatomic) IBOutlet UILabel *detailView_name;
@property (strong, nonatomic) IBOutlet UILabel *detailView_date;
@property (strong, nonatomic) IBOutlet UILabel *detailView_source;


//weiboModel
@property (strong,nonatomic)WeiboModel *weiboModelInDetail;

//微博视图
@property (strong, nonatomic) IBOutlet UIView *detailWeiboView;
@property (strong, nonatomic) IBOutlet MLEmojiLabel *detailWeiboText;
@property (strong, nonatomic) IBOutlet UICollectionView *detailWeiboImageCollectionView;
@property (strong, nonatomic) IBOutlet YLImageView *detailWeiboImage;
@property (strong, nonatomic) IBOutlet UILabel *gifLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailWeiboCollectionHeight;

//转发视图
@property (strong, nonatomic) IBOutlet UIView *detailReWeiboView;
@property (strong, nonatomic) IBOutlet MLEmojiLabel *detailReWeiboText;
@property (strong, nonatomic) IBOutlet UICollectionView *detailReWeiboImageCollectionView;
@property (strong, nonatomic) IBOutlet YLImageView *detailReWeiboImage;
@property (strong, nonatomic) IBOutlet UILabel *gifLabel_re;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailReWeiboCollectionHeight;

-(CGFloat)getDetailWeiboViewHeight;
-(void)setUpDetailData:(WeiboModel *)model;

@end
