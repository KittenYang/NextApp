//
//  DetailViewController.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 3/15/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#import "DetailViewController.h"
#import "UIView+Extra.h"
#import "CONST.h"
#import "DetailWeiboView.h"

@interface DetailViewController ()<UITableViewDataSource>

@end

@implementation DetailViewController


-(id)initWithModel:(WeiboModel *)model{
    
    self = [super init];
    if (self) {
        
        self.model = model;
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    DetailWeiboView *detailWeiboView = [[[NSBundle mainBundle]loadNibNamed:@"DetailWeiboView" owner:self options:nil]firstObject];
    [detailWeiboView setUpDetailData:self.model];
//    detailWeiboView.frame = CGRectMake(0, 0,SCREENWIDTH , 0);
//    detailWeiboView.height = 90;
    
//    DetailWeiboView *detailWeiboView = [[DetailWeiboView alloc]initWithWeiboModel:self.model];
//    detailWeiboView.frame = CGRectMake(0, 0, SCREENWIDTH, [detailWeiboView getDetailWeiboViewHeight]);
//    
//    self.tableView.dataSource = self;
//    self.isNeedTimeScrollIndicator = NO;
//    
//    self.tableView.tableHeaderView = detailWeiboView;
    
//    DetailWeiboView *detailWeiboView = [[DetailWeiboView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0) weiboModel:self.model];
    detailWeiboView.frame = CGRectMake(0, 0, SCREENWIDTH, 100);
    
    self.isNeedTimeScrollIndicator = NO;
    self.tableView.tableHeaderView = detailWeiboView;

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma  mark -- UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    
    return commentCell;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}



@end
