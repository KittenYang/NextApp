//
//  detailWeiboView.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 4/21/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import "DetailWeiboView.h"
#import "UIImageView+WebCache.h"
#import "Utils.h"

@implementation DetailWeiboView


//-(id)initWithFrame:(CGRect)frame weiboModel:(WeiboModel *)model{
//    
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.weiboModelInDetail = model;
//        [self setUpDetailData];
//    }
//    return self;
//}


-(void)setUpDetailData:(WeiboModel *)model{

    self.weiboModelInDetail = model;
    //-----头像-------
    NSString *imgURL = self.weiboModelInDetail.user.avatar_large;
    NSURL *avatorUrl = [NSURL URLWithString:imgURL];
    if (avatorUrl != nil) {
        [self.detailView_avatar sd_setImageWithURL:avatorUrl];
    }
    
    //-----昵称-------
    self.detailView_name.text = self.weiboModelInDetail.user.screen_name;
    
    
    //-----------创建日期---------------
    NSString *createDate =  self.weiboModelInDetail.createDate;
    NSString *dateString = [Utils fomateString:createDate];
    
    if (createDate != nil ) {
        self.detailView_date.text = dateString;
    }
    
    
    //----------微博来源---------------
    NSString *ret = [Utils parseSource: self.weiboModelInDetail.source];
    if (ret != nil) {
        self.detailView_source.text = [NSString stringWithFormat:@"来自 %@",ret];
        
    }
    
    
    //------图片视图-------
    if (self.weiboModelInDetail.pic_urls.count > 0) {
        
        self.detailView_weiboView.collectionViewHeight.constant = 130.0f;
        
    }else {
        
        self.detailView_weiboView.weiboModel.pic_urls = 0;
        self.detailView_weiboView.collectionViewHeight.constant = 0.0f;
    }
    
    //------转发视图-------
    if (self.weiboModelInDetail.retWeibo) {
        
        self.detailView_weiboView.reWeiboView.reWeiboModel = self.weiboModelInDetail.retWeibo;
        NSString *nickName = self.weiboModelInDetail.retWeibo.user.screen_name;
        
        self.detailView_weiboView.reWeiboView.reWeiboText.text = [NSString stringWithFormat:@"@%@:%@",nickName,self.weiboModelInDetail.retWeibo.text];
        self.detailView_weiboView.reWeiboView.reWeiboText.lineBreakMode = NSLineBreakByWordWrapping;
        self.detailView_weiboView.reWeiboView.reWeiboText.numberOfLines = 0;
        
        CGRect oldFrame = self.detailView_weiboView.reWeiboView.reWeiboText.frame;
        CGSize size = [self.detailView_weiboView.reWeiboView.reWeiboText sizeThatFits:CGSizeMake([[UIScreen mainScreen]bounds].size.width - 15, MAXFLOAT)];
        
        
        self.detailView_weiboView.reWeiboView.reWeiboText.frame =CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, size.height);
        
        
        if (!(self.weiboModelInDetail.retWeibo.pic_urls.count > 0)) {
            
            if (self.detailView_weiboView.reWeiboView.reCollectionViewHeight.constant != 0.0f) {
                self.detailView_weiboView.reWeiboView.reCollectionViewHeight.constant = 0.0f;
            }
        }else{
            if (self.detailView_weiboView.reWeiboView.reCollectionViewHeight.constant != 130.0f) {
                self.detailView_weiboView.reWeiboView.reCollectionViewHeight.constant = 130.0f;
            }
        }
        
        self.detailView_weiboView.reWeiboView.reWeiboHeight.constant = self.detailView_weiboView.reWeiboView.reWeiboText.frame.size.height + self.detailView_weiboView.reWeiboView.reCollectionViewHeight.constant + 5 + 5 + 5;
        
    }else{
        
        self.detailView_weiboView.reWeiboView.reWeiboModel = nil;
        self.detailView_weiboView.reWeiboView.reWeiboText.text = nil;
        self.detailView_weiboView.reWeiboView.reCollectionViewHeight.constant = 0.0f;
        self.detailView_weiboView.reWeiboView.reWeiboHeight.constant = 0;
    }
    
    //----------微博内容--------------
    self.detailView_weiboView.weiboText.text = self.weiboModelInDetail.text;
    
    self.detailView_weiboView.weiboText.lineBreakMode = NSLineBreakByWordWrapping;
    self.detailView_weiboView.weiboText.numberOfLines = 0;
    
    CGRect oldFrame = self.detailView_weiboView.weiboText.frame;
    CGSize size = [self.detailView_weiboView.weiboText sizeThatFits:CGSizeMake([[UIScreen mainScreen]bounds].size.width - 15, MAXFLOAT)];
    
    self.detailView_weiboView.weiboText.frame =CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, size.height);
    
    [self.detailView_weiboView setNeedsUpdateConstraints];
    [self.detailView_weiboView layoutIfNeeded];
    
    //高度
    self.detailView_weiboView_height.constant = self.detailView_weiboView.frame.size.height;

}

-(CGFloat)getDetailWeiboViewHeight{
    
//    CGSize cellSize = [self systemLayoutSizeFittingSize:CGSizeMake(self.frame.size.width, 0) withHorizontalFittingPriority:1000.0 verticalFittingPriority:50.0];
    return self.detailView_weiboView_height.constant + 20 + 50 + 8 + 20;
    
}

@end
