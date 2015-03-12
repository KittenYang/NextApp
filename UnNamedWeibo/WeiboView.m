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
#import "CollectionViewCell.h"


@implementation WeiboView{

    CGFloat lastContentOffset;
}


-(void)awakeFromNib{

    self.weiboImageCollectionView.dataSource  = self;
    self.weiboImageCollectionView.delegate    = self;
    self.weiboText.isNeedAtAndPoundSign = YES;
    self.weiboText.disableEmoji = NO;
    self.weiboText.delegate = self;
    self.weiboText.customEmojiPlistName = @"EMOTION.plist";
    self.weiboText.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
}


-(void)layoutSubviews{
    [super layoutSubviews];

}

#pragma  mark  - MLEmojiLabelDelegate
- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type{
    
    switch(type){
        case MLEmojiLabelLinkTypeURL:
            NSLog(@"点击了链接%@",link);
            break;
        case MLEmojiLabelLinkTypePhoneNumber:
            NSLog(@"点击了电话%@",link);
            break;
        case MLEmojiLabelLinkTypeEmail:
            NSLog(@"点击了邮箱%@",link);
            break;
        case MLEmojiLabelLinkTypeAt:
            NSLog(@"点击了用户%@",link);
            break;
        case MLEmojiLabelLinkTypePoundSign:
            NSLog(@"点击了话题%@",link);
            break;
        default:
            NSLog(@"点击了不知道啥%@",link);
            break;
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

    NSMutableArray *original_pic_urls = [NSMutableArray arrayWithCapacity:self.weiboModel.pic_urls.count];
    for (NSInteger i = 0; i < self.weiboModel.pic_urls.count; i++) {
        NSString *thumbnailImageUrl = [self.weiboModel.pic_urls[i] objectForKey:@"thumbnail_pic"];
        thumbnailImageUrl = [thumbnailImageUrl stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        NSDictionary *imgdics = [NSDictionary dictionaryWithObjectsAndKeys:thumbnailImageUrl,@"thumbnail_pic", nil];
        [original_pic_urls addObject:imgdics];
    }
    self.weiboModel.pic_urls = original_pic_urls;
    
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"weibo_image_cell" forIndexPath:indexPath];
    NSLog(@"cell.frame:%@",NSStringFromCGRect(cell.frame));

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *imgDICS = self.weiboModel.pic_urls[indexPath.item];
        NSString *imgUrl = [imgDICS objectForKey:@"thumbnail_pic"];
        NSURL *photoUrl = [NSURL URLWithString:imgUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.weiboImage sd_setImageWithURL:photoUrl];
        });
    });
    
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (self.weiboModel.pic_urls.count == 1) {
//        
//        cell.frame = CGRectMake(0, 5, collectionView.bounds.size.width, 190);
//        
//    }else{
//        if (indexPath.item == 0) {
//            cell.frame = CGRectMake(0, 5, 190, 190);
//        }
//    }

    
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
