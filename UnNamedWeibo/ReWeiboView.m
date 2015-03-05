//
//  ReWeiboView.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 3/6/15.
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



#import "ReWeiboView.h"
#import "UIImageView+WebCache.h"
#import "ReWeiboImgCollectionViewCell.h"

@implementation ReWeiboView{

    CGFloat lastContentOffset;
    
}

-(void)awakeFromNib{
    self.reWeiboImageCollectionView.dataSource  = self;
    self.reWeiboImageCollectionView.delegate    = self;

}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (self.reWeiboModel.pic_urls.count == 0) {
        return 0;
    }
    return [self.reWeiboModel.pic_urls count];
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray *original_pic_urls = [NSMutableArray arrayWithCapacity:self.reWeiboModel.pic_urls.count];
    for (NSInteger i = 0; i < self.reWeiboModel.pic_urls.count; i++) {
        NSString *thumbnailImageUrl = [self.reWeiboModel.pic_urls[i] objectForKey:@"thumbnail_pic"];
        thumbnailImageUrl = [thumbnailImageUrl stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        NSDictionary *imgdics = [NSDictionary dictionaryWithObjectsAndKeys:thumbnailImageUrl,@"thumbnail_pic", nil];
        [original_pic_urls addObject:imgdics];
    }
    self.reWeiboModel.pic_urls = original_pic_urls;
    
    ReWeiboImgCollectionViewCell *cell = (ReWeiboImgCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"reWeibo_image_cell" forIndexPath:indexPath];

    
    NSDictionary *imgDICS = self.reWeiboModel.pic_urls[indexPath.item];
    NSString *imgUrl = [imgDICS objectForKey:@"thumbnail_pic"];
    [cell.reWeiboImage sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.reWeiboModel.pic_urls.count == 1) {
        
        cell.frame = CGRectMake(0, 5, collectionView.bounds.size.width, 120);
        
    }else{
        if (indexPath.item == 0) {
            cell.frame = CGRectMake(0, 5, 120, 120);
        }
    }
    
    
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
