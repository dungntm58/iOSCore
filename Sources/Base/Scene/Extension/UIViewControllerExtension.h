//
//  UIViewControllerExtension.h
//  RxCoreBase
//
//  Created by Robert on 2/17/20.
//

#ifndef UIViewControllerExtension_h
#define UIViewControllerExtension_h

#import <UIKit/UIKit.h>

@interface UIViewController (RxCoreBase)

- (void)dismissKeyboard;
- (BOOL)canPerformSegueWithIdentifier:(nonnull NSString *)id;

@end

#endif /* UIViewControllerExtension_h */
