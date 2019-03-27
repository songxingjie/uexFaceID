//
//  LAContextManager.h
//  EUExFaceID
//
//  Created by 郭杰 on 2019/3/26.
//  Copyright © 2019 songxingjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LAContextErrorType) {
    LAContextErrorAuthorFailure   = 0,  // 指纹识别或FaceID识别错误
    LAContextErrorAuthorNotAccess = 1,  // 指纹识别或FaceID不支持等其他原因
};

typedef void(^LAContext_Success)(void);
typedef void(^LAContext_Failure)(NSError *tyError, LAContextErrorType feedType);

@interface LAContextManager : NSObject

+ (void)callLAContextManagerWithController:(UIViewController *)currentVC
                                   success:(LAContext_Success)success
                                   failure:(LAContext_Failure)failure;





@end


