//
//  AlertObject.h
//  AkbankiPhone
//
//  Created by Emre Kocabas on 11/03/16.
//  Copyright © 2016 Foreks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAlertController.h"

@interface AlertObject : NSObject

@property(nonatomic,retain) NSString* alertTitle;
@property(nonatomic,retain) NSString* alertMessage;
@property(nonatomic,retain) NSArray* alertActions;
@property(nonatomic,retain) UIViewController* alertViewController;
@property(nonatomic) DAAlertControllerStyle alertStyle;

-(id)initWithTitle:(NSString*)title andMessage:(NSString*)message andViewController:(UIViewController*)viewController andActions:(NSArray*)actions andStyle:(DAAlertControllerStyle)style;

@end
