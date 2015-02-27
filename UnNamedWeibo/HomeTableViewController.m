//
//  HomeTableViewController.m
//  UnNamedWeibo
//
//  Created by Kitten Yang on 2/13/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

//关于未读提示
#define BubbleWidth  30
#define BubbleX      18
#define BubbleY      500
#define BubbleColor  [UIColor redColor];
//[UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];



#import "HomeTableViewController.h"
#import "KYCell.h"
#import "Utils.h"
#import "SKSplashIcon.h"
#import "KYLoadingHUD.h"
#import "JellyButton.h"



@interface HomeTableViewController ()

@property (strong, nonatomic) SKSplashView *splashView;
@property (nonatomic,copy   ) NSString     *topWeiboId;// 最新一条微博的ID
@property (nonatomic,copy   ) NSString     *lastWeiboId;// 最久一条微博的ID

@end

@implementation HomeTableViewController{
    NSArray *array;
    KYLoadingHUD *hud;
    
    //--------关于未读提示----------
    UIBezierPath *cutePath;
    UIColor *fillColorForCute;
    UIDynamicAnimator *animator;
    UISnapBehavior  *snap;
    
    CADisplayLink *displayLinkToFeed;
    
    UILabel *updatedNumberforTabbar;//tabbar上更新数字的label
    UILabel *updatedNumberforBanner;//顶部滑下来更新数字的label
    UIView *frontView;
    UIView *backView;
    CGFloat r1; // backView
    CGFloat r2; // frontView
    CGFloat x1;
    CGFloat y1;
    CGFloat x2;
    CGFloat y2;
    CGFloat centerDistance;
    CGFloat cosDigree;
    CGFloat sinDigree;
    
    CGPoint pointA; //A
    CGPoint pointB; //B
    CGPoint pointD; //D
    CGPoint pointC; //C
    CGPoint pointO; //O
    CGPoint pointP; //P
    
    CGRect oldBackViewFrame;
    CGPoint oldBackViewCenter;
    CAShapeLayer *shapeLayer;
    //----------------------------
    
    //刷新了几条微博的视图
    JellyButton *refreshNumberView;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prepareToLoadWeibo) name:kWeiboAuthSuccessNotification object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kWeiboAuthSuccessNotification object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self twitterSplash];

//    hud = [[KYLoadingHUD alloc]initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 50, self.view.bounds.size.height / 2 -100, 100, 100)];
//    [self.view addSubview:hud];

    
    //登录按钮
    UIButton *authBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    authBtn.frame = CGRectMake(260, 20, 50, 30);
    [authBtn setTitle:@"登录" forState:UIControlStateNormal];
    [authBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [authBtn addTarget:self action:@selector(authWeibo) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *authItem =[[UIBarButtonItem alloc]initWithCustomView:authBtn];
    self.navigationItem.rightBarButtonItem=authItem;

    
    //下拉加载更多
    super.loademoredelegate = self;
    
    
    //数据持久化
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreData"];
    NSDictionary *weiboDataFromKeyedUnarchiver = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.data = [weiboDataFromKeyedUnarchiver objectForKey:@"WEIBOS"];
    self.topWeiboId = [weiboDataFromKeyedUnarchiver objectForKey:@"topWeiboId"];
    self.weibos = self.data;

    if (self.data.count == 0) {
        [self loadWeibo];
    }else{
        [self.tableView reloadData];
    }
    
//    UIView *new_feed_view = [[UIView alloc]initWithFrame:CGRectMake(10, 568-100, 30, 30)];
//    new_feed_view.backgroundColor = [UIColor redColor];
//    [self.tabBarController.view addSubview:new_feed_view];
    
    
    //获取未读微博数的定时器
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(fetchToUnread) userInfo:nil repeats:YES];
    
 }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 定时获取未读微博数
-(void)fetchToUnread{
    NSString *uid = [[[NSUserDefaults standardUserDefaults]objectForKey:@"WeiboAuthData"]objectForKey:@"hostUserID"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uid", nil];

    [WBHttpRequest requestWithAccessToken:[Utils WEIBOTOKEN] url:WB_unRead httpMethod:@"GET" params:params delegate:self withTag:@"unRead"];
}

#pragma mark -- 启动动画
- (void) twitterSplash
{
    //Twitter style splash
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"twitter.png"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = [UIColor colorWithRed:0.25098 green:0.6 blue:1.0 alpha:1.0];
    _splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon backgroundColor:twitterColor animationType:SKSplashAnimationTypeBounce];
    _splashView.delegate = self; //Optional -> if you want to receive updates on animation beginning/end
    _splashView.animationDuration = 2; //Optional -> set animation duration. Default: 1s
    [self.tabBarController.view addSubview:_splashView];
    [_splashView startAnimation];
}

#pragma mark -- splashView animation delegate
- (void) splashView:(SKSplashView *)splashView didBeginAnimatingWithDuration:(float)duration
{
    NSLog(@"Started animating from delegate");
    
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    KYCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiboCell" forIndexPath:indexPath];
    
    WeiboModel *model = [self.data objectAtIndex:indexPath.row];
    cell.weiboModel = model;
    [self updateCellContentView:cell withWeiboModel:model];
    
    return cell;
}


//填充数据
-(void)updateCellContentView:(KYCell *)cell withWeiboModel:(WeiboModel *)model{

    //----------微博内容--------------
    cell.cellView.weiboView.weiboText.text = model.text;
        
}

#pragma  mark - 微博登录
-(void)authWeibo{

    WBAuthorizeRequest *authrequest = [WBAuthorizeRequest request];
    authrequest.redirectURI = kWeiboRedirectURI;
    authrequest.scope = @"all";
    authrequest.userInfo = @{@"SSO_From": @"HomeTableViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:authrequest];

}


-(void)prepareToLoadWeibo{
    if (self.data.count != 0) {
        return;
    }else{
        if ( [Utils WEIBOTOKEN] == nil || [[Utils WEIBOTOKEN]  isEqualToString:@""]) {
        }else{
            NSDate *nowDate = [NSDate date];
            if([nowDate compare:[Utils WEIBOEXDATE]] == NSOrderedAscending){
                
                [self loadWeibo];
                
            }else{
            }
        }
    }
}


-(void)loadWeibo{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"100" forKey:@"count"];
    
    [WBHttpRequest requestWithAccessToken:[Utils WEIBOTOKEN] url:WB_home  httpMethod:@"GET" params:params delegate:self withTag:@"load"];
}

#pragma mark  - loadMoreDelegate
//下拉
- (void)pullDown{
    if (self.topWeiboId.length == 0) {
        NSLog(@"最新一条微博的ID为空");
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"25",@"count",self.topWeiboId,@"since_id",nil];
    [WBHttpRequest requestWithAccessToken:[Utils WEIBOTOKEN] url:WB_home  httpMethod:@"GET" params:params delegate:self withTag:@"pullDown"];

}
//上拉
- (void)pullUp{
    
}
//选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark  - WBHttpRequestDelegate
- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data{
    if ([request.tag isEqual: @"load"]) {
//        [hud dismissHUD];

        NSError *error;
        NSDictionary *WEIBOJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]; // 100条JSON，一个statuses对应一个WeiboModel
        NSDictionary *WEIBOMODELS = [WEIBOJSON objectForKey:@"statuses"]; //100条微博
        NSMutableArray *WEIBOS = [NSMutableArray arrayWithCapacity:WEIBOMODELS.count];
        for (NSDictionary *_wbmodel in WEIBOMODELS) {
            WeiboModel *wbmodel = [[WeiboModel alloc]initWithWeiboDic:_wbmodel];
            [WEIBOS addObject:wbmodel];
        }
        
        self.data = WEIBOS;
        self.weibos = WEIBOS;
        
        if (WEIBOS.count > 0) {
            //记下最新的微博ID
            WeiboModel *topWeibo= [WEIBOS objectAtIndex:0];     //取出最新的一条微博
            self.topWeiboId = [topWeibo.weiboId stringValue];   //把最新的微博ID赋值给我们定义的这个topWeiboId变量
            //同理，记下最久的微博ID
            WeiboModel *lastWeibo = [WEIBOS lastObject];  //取出最久的一条微博
            self.lastWeiboId = [lastWeibo.weiboId stringValue];//把最久的微博ID复制给我们定义的这个lastWeiboId变量
        }
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.data,@"WEIBOS",self.topWeiboId,@"topWeiboId",nil];
        NSData *StoreData = [NSKeyedArchiver archivedDataWithRootObject:dic];
        [[NSUserDefaults standardUserDefaults] setObject:StoreData forKey:@"StoreData"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
        [self.tableView reloadData];
    }
    
    if ([request.tag isEqual:@"pullDown"]) {
        NSError *error;
        NSDictionary *WEIBOJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]; // 100条JSON，一个statuses对应一个WeiboModel
        NSDictionary *WEIBOMODELS = [WEIBOJSON objectForKey:@"statuses"]; //100条微博
        //更新的条数
        int updateCount = (int)[WEIBOMODELS count];
        if (updateCount == 0) {
            [self backToTop];
            return;
        }
        
        NSMutableArray *WEIBOS = [NSMutableArray arrayWithCapacity:WEIBOMODELS.count];
        for (NSDictionary *_wbmodel in WEIBOMODELS) {
            WeiboModel *wbmodel = [[WeiboModel alloc]initWithWeiboDic:_wbmodel];
            [WEIBOS addObject:wbmodel];
        }
        
        [WEIBOS addObjectsFromArray:self.weibos];
        NSRange overHundredRange;
        overHundredRange.location = 100;
        overHundredRange.length   = [WEIBOS count]-100;
        [WEIBOS removeObjectsInRange:overHundredRange];
        self.data   = WEIBOS;
        self.weibos = WEIBOS;
        
        if (WEIBOS.count > 0) {
            WeiboModel *topWeibo= [WEIBOS objectAtIndex:0];
            self.topWeiboId = [topWeibo.weiboId stringValue];
        }
        
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.data,@"WEIBOS",self.topWeiboId,@"topWeiboId",nil];
        NSData *StoreData = [NSKeyedArchiver archivedDataWithRootObject:dic];
        [[NSUserDefaults standardUserDefaults] setObject:StoreData forKey:@"StoreData"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
        [self.tableView reloadData];
        [self backToTop];
        [self showNumberOfRefresh:updateCount];
        //刷新之后移除未读提示
        frontView.hidden = YES;
        
        
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:updateCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    }
    
    if ([request.tag isEqual:@"unRead"]) {
        NSError *error;
        NSDictionary *WEIBOJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSNumber *unReadNum = [WEIBOJSON objectForKey:@"status"];
        int n = [unReadNum intValue];
        if (frontView == nil) {
            NSLog(@"提示框+1");
            [self setUp:n];
            [self addGesture];
        }

        if (n > 0){
            if (n > 25) {
                frontView.hidden = NO;
                updatedNumberforTabbar.text = @"...";
            }else{
                frontView.hidden = NO;
                updatedNumberforTabbar.text = [NSString stringWithFormat:@"%d",n];
            }
        }
    
    }
}

#pragma mark - 刷新之后提示刷新几条
-(void)showNumberOfRefresh:(int)updatedNum{
    if (refreshNumberView == nil) {
        refreshNumberView = [[JellyButton alloc]initWithFrame:CGRectMake(5, -120, [[UIScreen mainScreen]bounds].size.width - 10, 50)
                                                jellyViewSize:CGSizeMake(self.view.bounds.size.width - 10, 50)
                                                    fillColor:[UIColor redColor]
                                                   elasticity:3
                                                      density:1
                                                      damping:0.6
                                                    frequency:8];
        
        updatedNumberforBanner = [[UILabel alloc]initWithFrame:refreshNumberView.frame];
        [refreshNumberView addSubview:updatedNumberforBanner];
        [self.view addSubview:refreshNumberView];
    }
    
    updatedNumberforBanner.text = [NSString  stringWithFormat:@"更新%d条微博",updatedNum];

    
    [UIView animateWithDuration:1.5 delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        refreshNumberView.frame = CGRectMake(5, 5, [[UIScreen mainScreen]bounds].size.width - 10, 50);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.5 delay:1 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            refreshNumberView.frame = CGRectMake(5, -120, [[UIScreen mainScreen]bounds].size.width - 10, 50);
        } completion:nil];
    }];
    [refreshNumberView show];

}

#pragma mark - 关于tabbar未读提示
//每隔一帧刷新屏幕的定时器
-(void)displayLinkActionToFeed:(CADisplayLink *)dis{
    
    self.view.backgroundColor = [UIColor whiteColor];
    x1 = backView.center.x;
    y1 = backView.center.y;
    x2 = frontView.center.x;
    y2 = frontView.center.y;
    
    centerDistance = sqrtf((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
    if (centerDistance == 0) {
        cosDigree = 1;
        sinDigree = 0;
    }else{
        cosDigree = (y2-y1)/centerDistance;
        sinDigree = (x2-x1)/centerDistance;
    }
    r1 = oldBackViewFrame.size.width / 2 - centerDistance/25;
    
    pointA = CGPointMake(x1-r1*cosDigree, y1+r1*sinDigree);  // A
    pointB = CGPointMake(x1+r1*cosDigree, y1-r1*sinDigree); // B
    pointD = CGPointMake(x2-r2*cosDigree, y2+r2*sinDigree); // D
    pointC = CGPointMake(x2+r2*cosDigree, y2-r2*sinDigree);// C
    pointO = CGPointMake(pointA.x + (centerDistance / 2)*sinDigree, pointA.y + (centerDistance / 2)*cosDigree);
    pointP = CGPointMake(pointB.x + (centerDistance / 2)*sinDigree, pointB.y + (centerDistance / 2)*cosDigree);
    
    [self drawRect];
}

-(void)drawRect{
    
    backView.center = oldBackViewCenter;
    backView.bounds = CGRectMake(0, 0, r1*2, r1*2);
    backView.layer.cornerRadius = r1;
    
    cutePath = [UIBezierPath bezierPath];
    [cutePath moveToPoint:pointA];
    [cutePath addQuadCurveToPoint:pointD controlPoint:pointO];
    [cutePath addLineToPoint:pointC];
    [cutePath addQuadCurveToPoint:pointB controlPoint:pointP];
    [cutePath moveToPoint:pointA];
    
    
    if (backView.hidden == NO) {
        shapeLayer.path = [cutePath CGPath];
        shapeLayer.fillColor = [fillColorForCute CGColor];
        [self.tabBarController.view.layer addSublayer:shapeLayer];
    }
}


-(void)setUp:(int)n{
    shapeLayer = [CAShapeLayer layer];
    
    self.view.backgroundColor = [UIColor clearColor];
    frontView = [[UIView alloc]initWithFrame:CGRectMake(BubbleX,BubbleY, BubbleWidth, BubbleWidth)];
    
    r2 = frontView.bounds.size.width / 2;
    frontView.layer.cornerRadius = r2;
    frontView.backgroundColor = BubbleColor;
    
    backView = [[UIView alloc]initWithFrame:frontView.frame];
    r1 = backView.bounds.size.width / 2;
    backView.layer.cornerRadius = r1;
    backView.backgroundColor = BubbleColor;
    
    if (n > 0) {
        updatedNumberforTabbar = [[UILabel alloc]init];
        updatedNumberforTabbar.frame = CGRectMake(0, 0, frontView.bounds.size.width, frontView.bounds.size.height);
        updatedNumberforTabbar.textColor = [UIColor whiteColor];
        updatedNumberforTabbar.font = [UIFont systemFontOfSize:13.0f];
        updatedNumberforTabbar.textAlignment = NSTextAlignmentCenter;
        
        [frontView insertSubview:updatedNumberforTabbar atIndex:0];
    }

    
    [self.tabBarController.view addSubview:backView];
    [self.tabBarController.view addSubview:frontView];
    
    
    x1 = backView.center.x;
    y1 = backView.center.y;
    x2 = frontView.center.x;
    y2 = frontView.center.y;
    
    
    pointA = CGPointMake(x1-r1,y1);   // A
    pointB = CGPointMake(x1+r1, y1);  // B
    pointD = CGPointMake(x2-r2, y2);  // D
    pointC = CGPointMake(x2+r2, y2);  // C
    pointO = CGPointMake(x1-r1,y1);
    pointP = CGPointMake(x2+r2, y2);
    
    oldBackViewFrame = backView.frame;
    oldBackViewCenter = backView.center;
    
    backView.hidden = YES;//为了看到frontView的气泡晃动效果，需要展示隐藏backView
    [self AddAniamtionLikeGameCenterBubble];
}


-(void)addGesture{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragMe:)];
    [frontView addGestureRecognizer:pan];
    
}


-(void)dragMe:(UIPanGestureRecognizer *)ges{
    CGPoint dragPoint = [ges locationInView:self.tabBarController.view];
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        backView.hidden = NO;
        fillColorForCute = BubbleColor;
        [self RemoveAniamtionLikeGameCenterBubble];
        if (displayLinkToFeed == nil) {
            displayLinkToFeed = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkActionToFeed:)];
            [displayLinkToFeed addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
        
    }else if (ges.state == UIGestureRecognizerStateChanged){
        frontView.center = dragPoint;
        
        if (r1 <= 6) {
            
            fillColorForCute = [UIColor clearColor];
            backView.hidden = YES;
            [shapeLayer removeFromSuperlayer];
            [displayLinkToFeed invalidate];
            displayLinkToFeed = nil;
        }
        
    }else if (ges.state == UIGestureRecognizerStateEnded || ges.state ==UIGestureRecognizerStateCancelled || ges.state == UIGestureRecognizerStateFailed){
        
        backView.hidden = YES;
        fillColorForCute = [UIColor clearColor];
        [shapeLayer removeFromSuperlayer];
        [UIView animateWithDuration:0.5 delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            frontView.center = oldBackViewCenter;
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                [self AddAniamtionLikeGameCenterBubble];
                [displayLinkToFeed invalidate];
                displayLinkToFeed = nil;
            }
        }];
    }
}


//----类似GameCenter的气泡晃动动画------
-(void)AddAniamtionLikeGameCenterBubble{
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = INFINITY;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 5.0;
    
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer = CGRectInset(frontView.frame, frontView.bounds.size.width / 2 - 3, frontView.bounds.size.width / 2 - 3);
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    [frontView.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
    
    
    CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleX.duration = 1;
    scaleX.values = @[@1.0, @1.1, @1.0];
    scaleX.keyTimes = @[@0.0, @0.5, @1.0];
    scaleX.repeatCount = INFINITY;
    scaleX.autoreverses = YES;
    
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [frontView.layer addAnimation:scaleX forKey:@"scaleXAnimation"];
    
    
    CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleY.duration = 1.5;
    scaleY.values = @[@1.0, @1.1, @1.0];
    scaleY.keyTimes = @[@0.0, @0.5, @1.0];
    scaleY.repeatCount = INFINITY;
    scaleY.autoreverses = YES;
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [frontView.layer addAnimation:scaleY forKey:@"scaleYAnimation"];
}

-(void)RemoveAniamtionLikeGameCenterBubble{
    [frontView.layer removeAllAnimations];
}



@end
