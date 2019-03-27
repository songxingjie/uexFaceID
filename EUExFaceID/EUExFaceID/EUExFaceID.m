//
//  EUExFaceID.m
//  EUExFaceID
//
//  Created by 郭杰 on 2019/3/26.
//  Copyright © 2019 songxingjie. All rights reserved.
//

#import "EUExFaceID.h"
#import <LocalAuthentication/LocalAuthentication.h>


static const NSInteger kUexFaceIDNoError = 0;
static const NSInteger kUexFaceIDNotAvailable = -6; // -6 = LAErrorTouchIDNotAvailable

@implementation EUExFaceID

//校验当前应用是否支持面部识别
- (NSNumber *)canAuthenticateForFaceID:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSNumber *mode = numberArg(info[@"mode"]);
    if (!NSClassFromString(@"LAContext")) {
        //8.0以下的系统
        return @(kUexFaceIDNotAvailable);
    }
    
    LAContext *ctx = [[LAContext alloc] init];
    NSError *error = nil;
    LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    
    if (@available(iOS 11.0, *) && mode.integerValue == 1) {
        if (ctx.biometryType == LABiometryTypeFaceID){
           policy = LAPolicyDeviceOwnerAuthentication;
        }
    }
    
    if(![ctx canEvaluatePolicy:policy error:&error]){
        ACLogDebug(@"FaceID is unavailable: %@",error.localizedDescription);
        return @(error.code);
    }

    return @(kUexFaceIDNoError);
}

//开始面部验证
- (void)authenticateWithFaceID:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;
    
    NSString *hint = stringArg(info[@"hint"]);
    NSNumber *mode = numberArg(info[@"mode"]);
    
    
    void (^callback)(NSInteger resultCode) = ^(NSInteger resultCode){
        [cb executeWithArguments:ACArgsPack(@(resultCode))];
    };
    
    if (!NSClassFromString(@"LAContext")){
        callback(kUexFaceIDNotAvailable);
        return;
    }
    
    LAContext* ctx = [[LAContext alloc] init];
    NSError* error = nil;
    LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    if (@available(iOS 11.0, *) && mode.integerValue == 1) {
        if (ctx.biometryType == LABiometryTypeFaceID){
             policy = LAPolicyDeviceOwnerAuthentication;
        }
    }
    if (![ctx canEvaluatePolicy:policy error:&error]) {
        //不支持面部识别
        callback(error.code);
        return;
    }
    [ctx evaluatePolicy:policy localizedReason:hint reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //验证成功
            callback(kUexFaceIDNoError);
        }else{
            //验证失败，或取消验证
            callback(error.code);
        }
    }];
}

-(void)verifyWithFaceID:(NSMutableArray*)inArguments{
    ACArgsUnpack(NSString *hint) = inArguments;
    LAContext* context = [[LAContext alloc] init];
    void (^callback)(BOOL result,NSString *reason) = ^(BOOL result,NSString *reason){
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexFaceID.cbVerifyWithFaceID" arguments:ACArgsPack(@(result),reason)];
    };
    
    NSError* error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:hint reply:^(BOOL success, NSError *error) {
            if (success) {
                //验证成功
                callback(YES,nil);
            }else{
                //验证失败，或取消验证
                callback(NO,error.localizedDescription);
            }
        }];
    }else{
        //不支持FaceID
        callback(NO,error.localizedDescription);
    }
}



@end
