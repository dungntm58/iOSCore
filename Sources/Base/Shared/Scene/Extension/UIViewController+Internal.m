//
//  UIViewController+Internal.m
//  CoreBase
//
//  Created by Robert on 7/16/20.
//

#import <UIViewController+Internal.h>
#import <objc/runtime.h>

@implementation UIViewController (CoreBase)

+ (void)load {
    SEL selector = @selector(viewDidLoad);
    Class class = [self class];
    Method m = class_getInstanceMethod(class, selector);

    if (m && [class instancesRespondToSelector:selector]) {
        typedef void (*OriginalIMPBlockType)(id self, SEL _cmd);
        OriginalIMPBlockType originalIMPBlock = (OriginalIMPBlockType)method_getImplementation(m);

        void (^swizzleViewDidLoad)(id) = ^void (id self) {
            [self configAssociation];
            originalIMPBlock(self, _cmd);
        };

        method_setImplementation(m, imp_implementationWithBlock(swizzleViewDidLoad));
    }
}

@end
