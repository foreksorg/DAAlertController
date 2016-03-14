//
//  DAAlertController.m
//  DAAlertControllerDemo
//
//  Created by Daria Kopaliani on 2/4/15.
//  Copyright (c) 2015 FactoralComplexity. All rights reserved.
//

#import "DAAlertController.h"
#import <objc/runtime.h>


#define itemAt(array, index) ((array.count > index) ? array[index] : nil)


@interface DAAlertController () <UIActionSheetDelegate, UIAlertViewDelegate>

-(void)alertShowed;

@end


@implementation DAAlertController
@synthesize alertList, showing, saveAndDismiss;

+ (instancetype)defaultAlertController {
    
    static dispatch_once_t predicate;
    static DAAlertController *alertController = nil;
    
    dispatch_once(&predicate, ^{
        alertController = [[self alloc] init];
    });
    
    return alertController;
}

-(id)init{
    if(self = [super init]){
        self.alertList= [[NSMutableArray alloc]init];
        self.showing = NO;
    }
    return self;
}



-(void)showAlert{
    if(self.alertList.count >0 && !self.showing && !self.saveAndDismiss){
        ForeksDAAlertObject* alert = [self.alertList objectAtIndex:0];
        switch (alert.alertStyle) {
            case DAAlertControllerStyleAlert: {
                [DAAlertController showAlertViewInViewController:alert.alertViewController withTitle:alert.alertTitle message:alert.alertMessage actions:alert.alertActions numberOfTextFields:0 textFieldsConfigurationHandler:nil validationBlock:nil];
            } break;
            case DAAlertControllerStyleActionSheet: {
                [DAAlertController showActionSheetInViewController:alert.alertViewController fromSourceView:alert.alertViewController.view withTitle:alert.alertTitle message:alert.alertMessage actions:alert.alertActions permittedArrowDirections:0];
            } break;
        }
        self.showing = YES;
    }
}

-(void)alertShowed{
    if(self.alertList.count >0){
        [self.alertList removeObjectAtIndex:0];
        self.showing = NO;
        if(self.alertList.count >0){
            [self showAlert];
        }
    }
}

+(void)saveAlertsAndDismissAll{
    [DAAlertController defaultAlertController].saveAndDismiss = YES;
    [DAAlertController defaultAlertController].showing = NO;
}

+(void)showWaitingAlerts{
    [DAAlertController defaultAlertController].saveAndDismiss = NO;
    [[DAAlertController defaultAlertController] showAlert];
}

+ (void)showAlertOfStyle:(DAAlertControllerStyle)style inViewController:(UIViewController *)viewController withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions {
    NSMutableArray* arr = [[NSMutableArray alloc]initWithArray:actions];
    ForeksDAAlertObject* alert = [[ForeksDAAlertObject alloc] initWithTitle:title andMessage:message andViewController:viewController andActions:arr andStyle:style];
    [[DAAlertController defaultAlertController].alertList addObject:alert];
    [[DAAlertController defaultAlertController]showAlert];
}

+ (void)showActionSheetInViewController:(UIViewController *)viewController fromSourceView:(UIView *)sourceView withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {
    
    if (NSStringFromClass([UIAlertController class])) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        for (DAAlertAction *action in actions) {
            [alertController addAction:[UIAlertAction actionWithTitle:action.title style:(UIAlertActionStyle)action.style handler:^(UIAlertAction *anAction) {
                [self handleActionSelection:action];
            }]];
        }
        [alertController setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popoverPresentationController = [alertController popoverPresentationController];
        if (sourceView) {
            [popoverPresentationController setSourceView:sourceView];
            [popoverPresentationController setSourceRect:sourceView.bounds];
            [popoverPresentationController setPermittedArrowDirections:permittedArrowDirections];
        } else {
            [popoverPresentationController setSourceView:viewController.view];
            [popoverPresentationController setSourceRect:viewController.view.bounds];
            [popoverPresentationController setPermittedArrowDirections:0];
        }
        [viewController presentViewController:alertController animated:YES completion:nil];
    } else {
        NSAssert(title.length || message.length || actions.count, @"DAAlertController must have a title, a message or an action to display");
        [self validateActions:actions];
        UIActionSheet *actionSheet = [self actionSheetWithTitle:title message:message actions:actions];
        if (sourceView) {
            [actionSheet showFromRect:sourceView.bounds inView:sourceView animated:YES];
        } else {
            [actionSheet showInView:viewController.view];
        }
    }
}

+ (void)showActionSheetInViewController:(UIViewController *)viewController fromBarButtonItem:(UIBarButtonItem *)barButtonItem withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {
    
    if (NSStringFromClass([UIAlertController class])) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        for (DAAlertAction *action in actions) {
            [alertController addAction:[UIAlertAction actionWithTitle:action.title style:(UIAlertActionStyle)action.style handler:^(UIAlertAction *anAction) {
                [self handleActionSelection:action];
            }]];
        }
        [alertController setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popoverPresentationController = [alertController popoverPresentationController];
        popoverPresentationController.barButtonItem = barButtonItem;
        popoverPresentationController.permittedArrowDirections = permittedArrowDirections;
        [viewController presentViewController:alertController animated:YES completion:nil];
    } else {
        NSAssert(title.length || message.length || actions.count, @"DAAlertController must have a title, a message or an action to display");
        [self validateActions:actions];
        UIActionSheet *actionSheet = [self actionSheetWithTitle:title message:message actions:actions];
        [actionSheet showFromBarButtonItem:barButtonItem animated:YES];
    }
}

+ (void)showAlertViewInViewController:(UIViewController *)viewController withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions {
    
    ForeksDAAlertObject* alert = [[ForeksDAAlertObject alloc] initWithTitle:title andMessage:message andViewController:viewController andActions:actions andStyle:DAAlertControllerStyleAlert];
    [[DAAlertController defaultAlertController].alertList addObject:alert];
    [[DAAlertController defaultAlertController]showAlert];
}

+ (void)showAlertViewInViewController:(UIViewController *)viewController withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions numberOfTextFields:(NSUInteger)numberOfTextFields textFieldsConfigurationHandler:(void (^)(NSArray *textFields))configurationHandler validationBlock:(BOOL (^)(NSArray *textFields))validationBlock {
    
    if (NSStringFromClass([UIAlertController class])) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        NSMutableSet *disableableActions = [NSMutableSet set];
        __block NSMutableSet *observers = [NSMutableSet set];
        for (DAAlertAction *action in actions) {
            UIAlertAction *actualAction = [UIAlertAction actionWithTitle:action.title style:(UIAlertActionStyle)action.style handler:^(UIAlertAction *anAction) {
                if (observers.count) {
                    for (id observer in observers) {
                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                    }
                    observers = nil;
                }
                if (action.handler) {
                    action.handler();
                    [[DAAlertController defaultAlertController] alertShowed];
                }
            }];
            if (validationBlock) {
                if (action.style != UIAlertActionStyleCancel) {
                    [disableableActions addObject:actualAction];
                }
            }
            [alertController addAction:actualAction];
        }
        if (numberOfTextFields > 0) {
            NSMutableArray *textFields = [NSMutableArray array];
            for (int i = 0; i < numberOfTextFields; i++) {
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *aTextField) {
                    [textFields addObject:aTextField];
                    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:aTextField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                        if (validationBlock) {
                            BOOL textFieldsFilledWithValidData = validationBlock(textFields);
                            for (UIAlertAction *disableableAction in disableableActions) {
                                disableableAction.enabled = textFieldsFilledWithValidData;
                            }
                        }
                    }];
                    [observers addObject:observer];
                }];
            }
            if (configurationHandler) {
                configurationHandler(textFields);
            }
            if (validationBlock) {
                BOOL textFieldsFilledWithValidData = validationBlock(textFields);
                for (UIAlertAction *disableableAction in disableableActions) {
                    disableableAction.enabled = textFieldsFilledWithValidData;
                }
            }
        }
        [viewController presentViewController:alertController animated:YES completion:nil];
    } else {
        NSAssert(numberOfTextFields <= 2, @"DAAlertController can only have up to 2 textfields on iOS 7");
        UIAlertView *alertView = [self alertViewWithTitle:title message:message actions:actions];
        if (validationBlock) {
            objc_setAssociatedObject(alertView, @"validationBlock", validationBlock, OBJC_ASSOCIATION_COPY);
        }
        if (numberOfTextFields > 0) {
            NSArray *textFields = nil;
            switch (numberOfTextFields) {
                case 1: {
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    textFields = @[[alertView textFieldAtIndex:0]];
                } break;
                case 2: {
                    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                    textFields = @[[alertView textFieldAtIndex:0], [alertView textFieldAtIndex:1]];
                } break;
                default: break;
            }
            if (configurationHandler) {
                configurationHandler(textFields);
            }
        }
        [alertView show];
    }
}

#pragma mark - Convenience Methods
#pragma mark -

+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions {
    
    DAAlertAction *cancelAction = nil;
    DAAlertAction *destructiveAction = nil;
    for (DAAlertAction *action in actions) {
        if (action.style == DAAlertActionStyleCancel) {
            cancelAction = action;
        } else if (action.style == DAAlertActionStyleDestructive) {
            destructiveAction = action;
        }
    }
    NSMutableArray *otherActions = [NSMutableArray arrayWithArray:actions];
    if (cancelAction) {
        [otherActions removeObject:cancelAction];
    }
    if (destructiveAction) {
        [otherActions removeObject:destructiveAction];
    }
    
    NSArray *otherButtonTitles = [otherActions valueForKey:@"title"];
    
    /*
     Again, it turns out it's absolutely neccessary to pass `otherButtonTitles` in the designated initializer if any, in case of passing `nil` `UIActionSheet` might be rendered incorrectly (i.e. separators are missing) for some cases.
     */
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:[self defaultAlertController] cancelButtonTitle:cancelAction.title destructiveButtonTitle:destructiveAction.title otherButtonTitles:itemAt(otherButtonTitles, 0), itemAt(otherButtonTitles, 1), itemAt(otherButtonTitles, 2), itemAt(otherButtonTitles, 3), itemAt(otherButtonTitles, 4), itemAt(otherButtonTitles, 5), itemAt(otherButtonTitles, 6), itemAt(otherButtonTitles, 7), itemAt(otherButtonTitles, 8), itemAt(otherButtonTitles, 9), itemAt(otherButtonTitles, 10), nil];
    if (cancelAction) {
        objc_setAssociatedObject(actionSheet, @"cancelAction", cancelAction, OBJC_ASSOCIATION_COPY);
    }
    if (destructiveAction) {
        objc_setAssociatedObject(actionSheet, @"destructiveAction", destructiveAction, OBJC_ASSOCIATION_COPY);
    }
    if (otherActions) {
        objc_setAssociatedObject(actionSheet, @"otherActions", otherActions, OBJC_ASSOCIATION_COPY);
    }
    
    return actionSheet;
}

+ (void)validateActions:(NSArray *)actions {
    
    NSUInteger cancelActionsCount = 0;
    NSUInteger destructiveActionsCount = 0;
    NSUInteger defaultActionsCount = 0;
    for (DAAlertAction *action in actions) {
        switch (action.style) {
            case DAAlertActionStyleCancel: cancelActionsCount++; break;
            case DAAlertActionStyleDefault: defaultActionsCount++; break;
            case DAAlertActionStyleDestructive: destructiveActionsCount++; break;
        }
    }
    NSAssert(cancelActionsCount <= 1, @"DAAlertController can only have one action with a style of DAAlertActionStyleCancel");
    if (!cancelActionsCount) {
        NSLog(@"UIActionSheen might not be rendered properly for iOS 7.* if you do not specify an action with a style of DAAlertActionStyleCancel");
    }
    NSAssert(defaultActionsCount <= 10, @"DAAlertController can have up to 10 actions with a style of DAAlertActionStyleDefault; if you need to have more, please, consider using another control");
    if (destructiveActionsCount > 1) {
        NSMutableString *destructiveActionsString = [NSMutableString string];
        DAAlertAction *firstDestructiveAction = nil;
        for (DAAlertAction *action in actions) {
            if (action.style == DAAlertActionStyleDestructive) {
                if (!firstDestructiveAction) {
                    firstDestructiveAction = action;
                } else {
                    [destructiveActionsString appendFormat:(destructiveActionsString.length) ? @", \"%@\"" : @"\"%@\"", action.title];
                    action.style = DAAlertActionStyleDefault;
                }
            }
        }
        NSLog(@"DAAlertController can only render one action of a style of DAAlertActionStyleDestructive on iOS 7, %@ will be rendered as actions of a styel DAAlertActionStyleDefault", destructiveActionsString);
    }
}

+ (id)itemAtIndex:(NSUInteger)index containedInArray:(NSArray *)array {
    
    return (array.count > index) ? array[index] : nil;
}

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style actions:(NSArray *)actions {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    for (DAAlertAction *action in actions) {
        [alertController addAction:[UIAlertAction actionWithTitle:action.title style:(UIAlertActionStyle)action.style handler:^(UIAlertAction *anAction) {
            [self handleActionSelection:action];
        }]];
    }
    
    return alertController;
}

+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions {
    
    DAAlertAction *cancelAction = nil;
    for (DAAlertAction *action in actions) {
        if (action.style == DAAlertActionStyleCancel) {
            cancelAction = action;
            break;
        }
    }
    NSMutableArray *otherActions = [NSMutableArray arrayWithArray:actions];
    [otherActions removeObject:cancelAction];
    NSArray *otherButtonTitles = [otherActions valueForKey:@"title"];
    
    /*
     okay, I usually do not write code that ugly but in this particular case there is а good reason - buggy `UIAlertView` and just that there is no other way. I myself reported this issue to the radar and know at least of 3 other guys, so may be `UIAlertController` actually happened becasue of us, you are welcome :)
     
     So the issue is that if you pass `nil` as `otherButtonTitles` in `initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles` method regardless wether you add other buttons later (using `addButtonWithTitle:` method) `firstOtherButtonIndex` will always be `-1`. And this results in `alertViewShouldEnableFirstOtherButton` never called which is something we can not afford if we want to disable buttons when there is no text in a textfiled.
     
     Unfortunately `initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles` method uses "nil termintated lists" for `otherButtonTitles` parameter. If you know of a non-crazy way to convert a `NSArray` into "nil terminated strings", please get in touch with me, I'll buy you a beer.
     
     So this is my way of converting a `NSArray` into a `nil-terminated list`:
     */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:[self defaultAlertController] cancelButtonTitle:cancelAction.title otherButtonTitles:itemAt(otherButtonTitles, 0), itemAt(otherButtonTitles, 1), itemAt(otherButtonTitles, 2), itemAt(otherButtonTitles, 3), itemAt(otherButtonTitles, 4), itemAt(otherButtonTitles, 5), itemAt(otherButtonTitles, 6), itemAt(otherButtonTitles, 7), itemAt(otherButtonTitles, 8), itemAt(otherButtonTitles, 9), itemAt(otherButtonTitles, 10), nil];
    
    objc_setAssociatedObject(alertView, @"otherActions", otherActions, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(alertView, @"cancelAction", cancelAction, OBJC_ASSOCIATION_COPY);
    
    return alertView;
}

+ (void)handleActionSelection:(DAAlertAction *)action {
    
    if (action.handler) {
        action.handler();
        [[DAAlertController defaultAlertController] alertShowed];
    }
}

#pragma mark - <UIAlertViewDelegate> methods
#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
    if (buttonIndex == alertView.cancelButtonIndex) {
        [DAAlertController handleActionSelection:objc_getAssociatedObject(alertView, @"cancelAction")];
    } else {
        [DAAlertController handleActionSelection:objc_getAssociatedObject(alertView, @"otherActions")[buttonIndex - alertView.firstOtherButtonIndex]];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    BOOL shouldEnableFirstOtherButton = YES;
    BOOL (^validationBlock)(NSArray *textFields) = objc_getAssociatedObject(alertView, @"validationBlock");
    if (validationBlock) {
        if (alertView.alertViewStyle != UIAlertViewStyleDefault) {
            UITextField *firstTextField = [alertView textFieldAtIndex:0];
            UITextField *secondTextField = (alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput) ? [alertView textFieldAtIndex:1] : nil;
            NSArray *textFields = (secondTextField) ? @[firstTextField, secondTextField] : @[firstTextField];
            shouldEnableFirstOtherButton = validationBlock(textFields);
        }
    }
    
    return shouldEnableFirstOtherButton;
}

#pragma mark - <UIActionSheetDelegate> methods
#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [DAAlertController handleActionSelection:objc_getAssociatedObject(actionSheet, @"cancelAction")];
    } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [DAAlertController handleActionSelection:objc_getAssociatedObject(actionSheet, @"destructiveAction")];
    } else {
        [DAAlertController handleActionSelection:objc_getAssociatedObject(actionSheet, @"otherActions")[buttonIndex - actionSheet.firstOtherButtonIndex]];
    }
}

@end