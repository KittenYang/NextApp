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

@interface DetailViewController ()<UITableViewDataSource>

@end

@implementation DetailViewController


-(void)viewWillAppear:(BOOL)animated{
    UIView *detailWeiboView = [[[NSBundle mainBundle]loadNibNamed:@"DetailWeiboView" owner:self options:nil]firstObject];
    detailWeiboView.frame = CGRectMake(0, 0,SCREENWIDTH , 0);
    detailWeiboView.height = 90;
    
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
