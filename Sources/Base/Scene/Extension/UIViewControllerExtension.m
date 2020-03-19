//
//  UIViewControllerExtension.m
//  RxCoreBase
//
//  Created by Robert on 2/17/20.
//

#import <UIViewControllerExtension.h>

@implementation UIViewController (RxCoreBase)

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)canPerformSegueWithIdentifier:(nonnull NSString *)identifier {
    NSArray *segues = [self valueForKey:@"storyboardSegueTemplates"];
    if (!segues) {
        return NO;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    NSArray *filteredArray = [segues filteredArrayUsingPredicate:predicate];
    return filteredArray.count > 0;
}

@end
