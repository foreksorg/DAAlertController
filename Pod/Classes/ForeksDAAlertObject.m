//
//  AlertObject.m
//  AkbankiPhone
//
//  Created by Emre Kocabas on 11/03/16.
//  Copyright © 2016 Foreks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertObject.h"

@implementation AlertObject

-(id)initWithTitle:(NSString*)title andMessage:(NSString*)message andViewController:(UIViewController*)viewController andActions:(NSArray*)actions andStyle:(DAAlertControllerStyle)style{
    if(self = [super init]){
        _alertTitle = title;
        _alertMessage = message;
        _alertActions = [[NSArray alloc]initWithArray:actions];
        _alertViewController = viewController;
        _alertStyle = style;
    }
    return self;
}
@end
