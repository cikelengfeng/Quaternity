//
//  XDViewController.m
//  Quaternity
//
//  Created by 徐 东 on 13-10-11.
//  Copyright (c) 2013年 下厨房. All rights reserved.
//

#import "XDViewController.h"

@interface XDViewController ()

- (void)onPan:(UIPanGestureRecognizer *)recognizer;
- (void)onRotate:(UIRotationGestureRecognizer *)recognizer;
- (void)onTap:(UITapGestureRecognizer *)recognizer;

- (void)relayoutContent:(UIView *)content;
- (void)relayoutAllContents;
- (void)rotateContent:(UIView *)content;
- (void)rotateAllContents;


@end

@implementation XDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPan:)];
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(onRotate:)];
    pan.delegate = self;
    rotate.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
    [self.pQuaternityContainer addGestureRecognizer:pan];
    [self.pQuaternityContainer addGestureRecognizer:rotate];
    [self.pQuaternityContainer addGestureRecognizer:tap];
    [self.pQuaternityContainer addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:NULL];
    [self.pQuaternityContainer addObserver:self forKeyPath:@"transform" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.pQuaternityContainer removeObserver:self forKeyPath:@"center"];
    [self.pQuaternityContainer removeObserver:self forKeyPath:@"transform"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"center"] && object == self.pQuaternityContainer) {
        NSLog(@"new center %@",change);
        [self relayoutAllContents];
    }else if ([keyPath isEqualToString:@"transform"] && object == self.pQuaternityContainer) {
        NSLog(@"new transform %@",change);
        [self rotateAllContents];
        [self relayoutAllContents];
    }
}

#pragma mark - gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return ![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && ![otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
}

#pragma mark - gesture callback

- (void)onPan:(UIPanGestureRecognizer *)recognizer
{
    static CGPoint beginCenter;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        beginCenter = self.pQuaternityContainer.center;
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint transition = [recognizer translationInView:self.view];
        CGPoint finalCenter = self.pQuaternityContainer.center;
        finalCenter.x = beginCenter.x + transition.x;
        finalCenter.y = beginCenter.y + transition.y;
        self.pQuaternityContainer.center = finalCenter;
    }
}

- (void)onRotate:(UIRotationGestureRecognizer *)recognizer
{
    static CGAffineTransform beginContainerTransform;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        beginContainerTransform = self.pQuaternityContainer.transform;
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGAffineTransform containerRotation = CGAffineTransformMakeRotation(recognizer.rotation);
        CGAffineTransform finalContainerTransform = CGAffineTransformConcat(beginContainerTransform, containerRotation);
        self.pQuaternityContainer.transform = finalContainerTransform;
    }
}

- (void)onTap:(UITapGestureRecognizer *)recognizer
{
    NSTimeInterval duration = 0.5;
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        int frameCount = duration * 1000 / 30;
        
        CGFloat angleInRadians = atan2(self.pQuaternityContainer.transform.b, self.pQuaternityContainer.transform.a);
        CGFloat anglePerFrameInRadians = angleInRadians/frameCount;
        
        CGPoint beginCenter = self.pQuaternityContainer.center;
        CGFloat translationXPerFrame = (self.view.bounds.size.width - self.pQuaternityContainer.center.x)/frameCount;
        CGFloat translationYPerFrame = (self.view.bounds.size.height - self.pQuaternityContainer.center.y)/frameCount;
        
        for (int i = 1 ; i <= frameCount; i++) {
            CGFloat currentAngle = angleInRadians - anglePerFrameInRadians * i;
            CGAffineTransform currentTransform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeRotation(currentAngle));
            CGPoint currentCenter = CGPointMake(beginCenter.x + translationXPerFrame * i, beginCenter.y + translationYPerFrame * i);
            [UIView addKeyframeWithRelativeStartTime:(i - 1) * 1.0f/frameCount relativeDuration:1.0f/frameCount animations:^{
                self.pQuaternityContainer.transform = currentTransform;
                self.pQuaternityContainer.center = currentCenter;
            }];
        }
    } completion:nil];
}

#pragma mark - keeping content position related to self.view

- (void)relayoutContent:(UIView *)content
{
    CGPoint center = [self.view convertPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2) toView:content.superview];
    content.center = center;

}

- (void)relayoutAllContents
{
    for (UIView *content in self.pContentViews) {
        [self relayoutContent:content];
    }
}

- (void)rotateContent:(UIView *)content
{
    CGFloat angleInRadians = atan2(self.pQuaternityContainer.transform.b, self.pQuaternityContainer.transform.a);
    content.transform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeRotation(-angleInRadians));
}

- (void)rotateAllContents
{
    for (UIView *content in self.pContentViews) {
        [self rotateContent:content];
    }
}







@end
