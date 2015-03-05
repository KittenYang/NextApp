//
//  WeiboView.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 2/17/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;



#import "WeiboView.h"
#import "UIImageView+WebCache.h"



@implementation WeiboView{
    UIImageView *weiboImageView;
    CGFloat lastContentOffset;
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

//    if (self.weiboModel.pic_urls.count > 0) {
//        self.weiboImageCollectionView.hidden = NO;
//        self.collectionViewHeight.constant = 175.0f;
//    }else {
//            self.collectionViewHeight.constant = 0.0f;
//    }

    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if (self.weiboModel.pic_urls.count == 0) {
        return 0;
    }
    return [self.weiboModel.pic_urls count];
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    NSMutableArray *original_pic_urls = [NSMutableArray arrayWithCapacity:self.weiboModel.pic_urls.count];
    for (NSInteger i = 0; i < self.weiboModel.pic_urls.count; i++) {
        NSString *thumbnailImageUrl = [self.weiboModel.pic_urls[i] objectForKey:@"thumbnail_pic"];
        thumbnailImageUrl = [thumbnailImageUrl stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        NSDictionary *imgdics = [NSDictionary dictionaryWithObjectsAndKeys:thumbnailImageUrl,@"thumbnail_pic", nil];
        [original_pic_urls addObject:imgdics];
    }
    self.weiboModel.pic_urls = original_pic_urls;
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"weibo_image_cell" forIndexPath:indexPath];
    NSLog(@"cell.frame:%@",NSStringFromCGRect(cell.frame));
    weiboImageView = (UIImageView *)[cell viewWithTag:200];
    NSDictionary *imgDICS = self.weiboModel.pic_urls[indexPath.item];
    NSString *imgUrl = [imgDICS objectForKey:@"thumbnail_pic"];
    [weiboImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    
    UICollectionViewFlowLayout * flowLayout =(UICollectionViewFlowLayout*)collectionView.collectionViewLayout;

    if (self.weiboModel.pic_urls.count == 1) {
//        if (indexPath.item == 0) {
            cell.frame = CGRectMake(0, 0, collectionView.bounds.size.width, 150);
//        }
//        cell.bounds = CGRectMake(0, 0, collectionView.bounds.size.width, 150);
//        flowLayout.sectionInset = UIEdgeInsetsMake(0, 80, 0, 0);
    }else{
        if (indexPath.item == 0) {
            cell.frame = CGRectMake(0, 0, 150, 150);
        }
//        cell.bounds = CGRectMake(0, 0, 150, 150);
//        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ScrollDirection scrollDirection;
    if (lastContentOffset > collectionView.contentOffset.x)
        scrollDirection = ScrollDirectionLeft;
    else if (lastContentOffset < collectionView.contentOffset.x)
        scrollDirection = ScrollDirectionRight;
    lastContentOffset = collectionView.contentOffset.x;

    
    if (scrollDirection == ScrollDirectionRight && collectionView.contentOffset.x > 0) {
        CGPoint offsetPositioning = CGPointMake(40, 0);
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y , 0.0);
        cell.layer.transform = transform;
        
        [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.layer.transform = CATransform3DIdentity;
            
        } completion:nil];
    }else{
        return;
    }

}


@end
