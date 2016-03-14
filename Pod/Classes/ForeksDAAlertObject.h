//
//  AlertObject.h
//  AkbankiPhone
//
//  Created by Emre Kocabas on 11/03/16.
//  Copyright © 2016 Foreks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAlertController.h"

@interface ForeksDAAlertObject : NSObject

@property(nonatomic,strong) NSString* alertTitle;
@property(nonatomic,strong) NSString* alertMessage;
@property(nonatomic,strong) NSArray* alertActions;
@property(nonatomic,strong) UIViewController* alertViewController;
@property(nonatomic) int alertStyle;

-(id)initWithTitle:(NSString*)title andMessage:(NSString*)message andViewController:(UIViewController*)viewController andActions:(NSArray*)actions andStyle:(int)style;

@end
