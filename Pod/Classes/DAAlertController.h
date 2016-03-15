//
//  DAAlertController.h
//  DAAlertControllerDemo
//
//  Created by Daria Kopaliani on 2/4/15.
//  Copyright (c) 2015 FactoralComplexity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAAlertAction.h"
#import "ForeksDAAlertObject.h"


typedef NS_ENUM(NSInteger, DAAlertControllerStyle) {
    DAAlertControllerStyleActionSheet = 0,
    DAAlertControllerStyleAlert
};


@interface DAAlertController : NSObject

@property (nonatomic, retain)NSMutableArray* alertList;
@property (nonatomic) BOOL showing;
@property (nonatomic) BOOL saveAndDismiss;

/**
 *  Save Existing alert, don't show coming alerts but save in stack
 */
+(void)saveAlertsAndDismissAll;


/**
 *  Show all waiting alerts in stack
 */
+(void)showWaitingAlerts;



+ (void)showAlertOfStyle:(DAAlertControllerStyle)style inViewController:(UIViewController *)viewController withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions;
+ (void)showAlertViewInViewController:(UIViewController *)viewController withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions;

//Not Implemented//

//+ (void)showActionSheetInViewController:(UIViewController *)viewController fromSourceView:(UIView *)sourceView withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;
//+ (void)showActionSheetInViewController:(UIViewController *)viewController fromBarButtonItem:(UIBarButtonItem *)barButtonItem withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;
//+ (void)showAlertViewInViewController:(UIViewController *)viewController withTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions numberOfTextFields:(NSUInteger)numberOfTextFields textFieldsConfigurationHandler:(void (^)(NSArray *textFields))configurationHandler validationBlock:(BOOL (^)(NSArray *textFields))validationBlock;

@end