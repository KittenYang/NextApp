//
//  WeiboView.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 2/17/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import "WeiboView.h"
#import "UIImageView+WebCache.h"

@implementation WeiboView{
    UIImageView *weiboImageView;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
//    self.weiboText.text = self.weiboModel.text;
    if (self.weiboModel.pic_urls.count == 0) {
        [self.weiboImageCollectionView removeConstraints:[self constraints]];
        self.weiboImageCollectionView.hidden = YES;
//        self.text_between_imageYES.active = NO;
        self.text_between_imageNO.active = YES;
        [self updateConstraintsIfNeeded];
    }

    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [self.weiboModel.pic_urls count];
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"weibo_image_cell" forIndexPath:indexPath];
    weiboImageView = (UIImageView *)[cell viewWithTag:200];
    NSDictionary *imgDics = self.weiboModel.pic_urls[indexPath.row];
    NSString *imgUrl = [imgDics objectForKey:@"thumbnail_pic"];
    [weiboImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    
    
    return cell;
    
}


@end
