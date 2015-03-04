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


-(void)awakeFromNib{
    self.weiboImageCollectionView.dataSource  = self;
    self.weiboImageCollectionView.delegate    = self;
}

//-(void)setWeiboModel:(WeiboModel *)weiboModel{
//
//    
//    for (NSInteger i = 0; i < self.weiboModel.pic_urls.count; i++) {
//        NSString *thumbnailImageUrl = [self.weiboModel.pic_urls[i] objectForKey:@"thumbnail_pic"];
//        thumbnailImageUrl = [thumbnailImageUrl stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"original"];
//        self.weiboModel.pic_urls[i]=thumbnailImageUrl;
//    }
//}


-(void)layoutSubviews{
    [super layoutSubviews];
//    self.weiboText.text = self.weiboModel.text;
    if (self.weiboModel.pic_urls.count > 0) {
//        [self.weiboImageCollectionView removeConstraints:[self constraints]];
        self.weiboImageCollectionView.hidden = NO;
////        self.text_between_imageYES.active = NO;
//        self.text_between_imageNO.active = YES;
//        [self updateConstraintsIfNeeded];
//        self.collectionViewHeight.constant = 0.0f;
    }

    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if (self.weiboModel.pic_urls.count == 0) {
        return 0;
    }
    return [self.weiboModel.pic_urls count];
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.weiboModel.pic_urls.count == 0) {
        return nil;
    }
    NSMutableArray *original_pic_urls = [NSMutableArray arrayWithCapacity:self.weiboModel.pic_urls.count];
    for (NSInteger i = 0; i < self.weiboModel.pic_urls.count; i++) {
        NSString *thumbnailImageUrl = [self.weiboModel.pic_urls[i] objectForKey:@"thumbnail_pic"];
        thumbnailImageUrl = [thumbnailImageUrl stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        NSDictionary *imgdics = [NSDictionary dictionaryWithObjectsAndKeys:thumbnailImageUrl,@"thumbnail_pic", nil];
        [original_pic_urls addObject:imgdics];
    }
    self.weiboModel.pic_urls = original_pic_urls;
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"weibo_image_cell" forIndexPath:indexPath];
    weiboImageView = (UIImageView *)[cell viewWithTag:200];
    NSDictionary *imgDICS = self.weiboModel.pic_urls[indexPath.item];
    NSString *imgUrl = [imgDICS objectForKey:@"thumbnail_pic"];
    [weiboImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGPoint offsetPositioning = CGPointMake(20, 0);
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y , 0.0);
    cell.layer.transform = transform;
    cell.alpha = 0.3;
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.layer.transform = CATransform3DIdentity;
        cell.layer.opacity = 1;
    } completion:nil];

}


@end
