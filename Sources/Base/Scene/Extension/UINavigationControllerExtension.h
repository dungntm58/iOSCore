//
//  UINavigationControllerExtension.h
//  Pods
//
//  Created by Robert on 2/17/20.
//

#ifndef UINavigationControllerExtension_h
#define UINavigationControllerExtension_h

#import <UIKit/UIKit.h>

@interface UINavigationController (RxCoreBase)

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)flag completion: (void (^ __nullable)(void))completion;

@end

#endif /* UINavigationControllerExtension_h */
