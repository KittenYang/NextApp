//
//  JellyView.m
//  KYJellyPullToRefresh
//
//  Created by Kitten Yang on 2/7/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//



#import "JellyView.h"

@implementation JellyView{
    CGRect jellyFrame;
    UIColor *fillColor;
    
    UIDynamicAnimator *animator;
    UICollisionBehavior *coll;
    UISnapBehavior  *snap;
    
    BOOL isFirstTime;
    CGFloat angle;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (id)initWithFrame:(CGRect)frame{
    self.userFrame = frame;
    jellyFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + [UIScreen mainScreen].bounds.size.height);

    self = [super initWithFrame:jellyFrame];
    if (self) {
        self.isLoading = NO;
        isFirstTime = NO;
        
//        self.fillColor = [UIColor blackColor];
//        self.fillColor = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];
//        fillColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
        self.frame = jellyFrame;
        
        //贝塞尔曲线的控制点
        self.controlPoint = [[UIView alloc]initWithFrame:CGRectMake(self.userFrame.size.width / 2 - 5, self.userFrame.size.height - 5, 10, 10)];
        self.controlPoint.backgroundColor = [UIColor clearColor];
        [self addSubview:self.controlPoint];
        
        //小球视图
        _ballView = [[UIImageView alloc]initWithFrame:CGRectMake(self.userFrame.size.width / 3 - 20, self.userFrame.size.height - 100, 40, 40)];
        _ballView.layer.cornerRadius = _ballView.bounds.size.width / 2;
        _ballView.image = [UIImage imageNamed:@"sun"];
        _ballView.backgroundColor = [UIColor clearColor];
        [self addSubview:_ballView];
        
        //UIDynamic
        animator = [[UIDynamicAnimator alloc]initWithReferenceView:self];
        UIGravityBehavior *grv = [[UIGravityBehavior alloc]initWithItems:@[_ballView]];
        grv.magnitude = 2;
        [animator addBehavior:grv];
        coll =  [[UICollisionBehavior alloc]initWithItems:@[_ballView]];
        
        UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc]initWithItems:@[_ballView]];
        item.elasticity = 0;
        item.density = 1;
    

    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    if (self.isLoading == NO) {
        [coll removeBoundaryWithIdentifier:@"弧形"];
        fillColor = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:(self.controlPointOffset)/100];
    }else{

        if (!isFirstTime) {
            isFirstTime = YES;
            snap = [[ UISnapBehavior alloc]initWithItem:_ballView snapToPoint:CGPointMake(self.userFrame.size.width / 2, self.userFrame.size.height - (90+64.5)/2)];
            [animator addBehavior:snap];
            
            [self startLoading];
        }
        fillColor = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];
        
    }
    

    
    self.controlPoint.center = (self.isLoading == NO)?(CGPointMake(self.userFrame.size.width / 2 , self.userFrame.size.height + self.controlPointOffset)) : (CGPointMake(self.userFrame.size.width / 2, self.userFrame.size.height + self.controlPointOffset));
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0,self.userFrame.size.height)];
    [path addQuadCurveToPoint:CGPointMake(self.userFrame.size.width,self.userFrame.size.height) controlPoint:self.controlPoint.center];
    [path addLineToPoint:CGPointMake(self.userFrame.size.width, 0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path closePath];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path.CGPath);
    [fillColor setFill];
    CGContextFillPath(context);
    
    if(self.isLoading == NO){
        [coll addBoundaryWithIdentifier:@"弧形" forPath:path];
        [animator addBehavior:coll];
    }

}

- (void)startLoading
{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _ballView.transform = endAngle;
    } completion:^(BOOL finished) {
        angle += 10;
        [self startLoading];
    }];
    
}


@end
