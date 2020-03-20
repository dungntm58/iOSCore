//
//  UINavigationControllerExtension.m
//  CoreBase
//
//  Created by Robert on 2/17/20.
//

#import <UINavigationControllerExtension.h>

@implementation UINavigationController (CoreBase)

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)flag completion: (void (^ __nullable)(void))completion; {
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    UIViewController *viewController = [self popViewControllerAnimated:flag];
    [CATransaction commit];
    [CATransaction setCompletionBlock:nil];
    return viewController;
}

@end
