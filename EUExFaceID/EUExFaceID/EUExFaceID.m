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

//校验当前应用是否支持面部识别 (检验是否系统支持FaceID:canEvaluatePolicy)
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
        NSLog(@"canAuthenticateForFaceID canEvaluatePolicy =========== error.code = %ld",error.code);
        return @(error.code);
    }

    return @(kUexFaceIDNoError);
}

/*
 error.code  :
      1.LAErrorAuthenticationFailed   身份验证失败
 
      2.LAErrorUserCancel   用户在认证时点击取消
 
      3.LAErrorUserFallback 用户点击输入密码取消指纹验证
 
      4.LAErrorSystemCancel 身份认证被系统取消(按下Home键或电源键)
 
      5.LAErrorTouchIDNotEnrolled  用户未录入指纹
 
      6.LAErrorPasscodeNotSet 设备未设置密码
 
      7.LAErrorTouchIDNotAvailable  该设备为设置FaceID
 
      8.LAErrorTouchIDLockout   连续五次密码错误,FaceID被锁定.
 
      9.LAErrorAppCancel 用户不能控制情况下App被挂起
 
 */

//开始面部验证(验证FaceID是否通过evaluatePolicy)
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
         NSLog(@"authenticateWithFaceID canEvaluatePolicy =========== error.code = %ld",error.code);
        return;
    }
    [ctx evaluatePolicy:policy localizedReason:hint reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //验证成功
            callback(kUexFaceIDNoError);
        }else{
            //验证失败，或取消验证
            callback(error.code);
            NSLog(@"authenticateWithFaceID evaluatePolicy =========== error.code = %ld",error.code);
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
