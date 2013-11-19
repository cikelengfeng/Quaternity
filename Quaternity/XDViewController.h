//
//  XDViewController.h
//  Quaternity
//
//  Created by 徐 东 on 13-10-11.
//  Copyright (c) 2013年 下厨房. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDViewController : UIViewController<UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *pContainers;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *pContentViews;
@property (weak, nonatomic) IBOutlet UIView *pQuaternityContainer;


@end
