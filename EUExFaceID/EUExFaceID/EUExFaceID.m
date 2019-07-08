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



@implementation EUExFaceID

//校验当前应用是否支持面部识别 (检验是否系统支持FaceID:canEvaluatePolicy)
- (NSNumber *)canAuthenticateForFaceID:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSNumber *mode = numberArg(info[@"mode"]);
   
    LAContext *ctx = [[LAContext alloc] init];
    NSError *error = nil;
    LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
    
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


//开始面部验证(验证FaceID是否通过evaluatePolicy)
- (void)authenticateWithFaceID:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;

    NSString *hint = stringArg(info[@"hint"]);
    NSNumber *mode = numberArg(info[@"mode"]);


    void (^callback)(NSInteger resultCode) = ^(NSInteger resultCode){
        [cb executeWithArguments:ACArgsPack(@(resultCode))];
    };

  
    LAContext* ctx = [[LAContext alloc] init];
    NSError* error = nil;
    LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
    if (@available(iOS 11.0, *) && mode.integerValue == 1) {
        if (ctx.biometryType == LABiometryTypeFaceID){
             policy = LAPolicyDeviceOwnerAuthentication;
        }
    }
   //注意iOS 11.3之后需要配置Info.plist权限才可以通过Face ID验证哦!不然只能输密码啦...
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
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        //注意iOS 11.3之后需要配置Info.plist权限才可以通过Face ID验证哦!不然只能输密码啦...
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:hint reply:^(BOOL success, NSError *error) {
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
