[TOC]

Face ID-面部识别插件
## 1.1、说明 
Face ID-面部识别插件,本对象封装了用于调用系统FaceID功能的方法,可以调用系统FaceID验证界面进行面部识别. FaceID功能接口只适用iOS11.0以上系统且支持面部识别的设备.

## 1.2、开源源码
无
## 1.3、平台版本支持

本插件的所有API默认只支持iOS11.0+操作系统,不支持Android. 有特殊版本要求的API会在文档中额外说明.

## 1.4、接口有效性

本插件所有API默认在插件版本**4.0.0+**可用.

# 2、API概览
## 2.1、方法

### 🍭 canAuthenticateForFaceID  校验当前应用是否支持面部识别验证

`uexFaceID.canAuthenticateForFaceID(data)`

**说明:**

校验当前应用是否支持面部验证

**参数:**

| 参数名称    | 参数类型   | 是否必选 | 说明                                       |
| ------- | ------ | ---- | ---------------------------------------- |
| data    | Object       |         是           | 面部识别验证的配置,不需要进行配置时请传null|


**示例:**

```var data = {
mode:
}
```
各字段含义如下：
| 参数名称    | 参数类型   | 是否必选 | 说明                                       |
| ------- | ------ | ---- | ---------------------------------------- |
| mode    | Number       |         否           | 面部验证模式,详见附录-AuthenticateMode,不传时默认为0|

返回值
返回值是一个ErrorCode ,详见附录-ErrorCode,非0时均表示不支持FaceID

**示例:**

```var ret = uexFaceID.canAuthenticateForFaceID(data)({
mode: 0
});
alert(ret);
```

### 🍭 authenticateWithFaceID   开始面部识别验证
`uexFaceID.authenticateWithFaceID(data,cb)`

**说明:**

开始面部识别验证

调用此接口时,最好先调用canAuthenticate接口确认当前设备支持FaceID

**参数:**

| 参数名称    | 参数类型   | 是否必选 | 说明                                       |
| ------- | ------ | ---- | ---------------------------------------- |
| data            | Object       |   是      |  面部识别验证的配置,不需要进行配置时请传null |
| cb               | Function    |   是      |  面部识别验证结果的回调函数|


**示例:**

```var data = {
hint:,
mode:
}
```
各字段含义如下:
| 参数名称    | 参数类型   | 是否必选 | 说明                                       |
| ------- | ------ | ---- | ---------------------------------------- |
| hint            | String         |   否      |  面部识别验证界面的提示语,不传时使用系统默认的提示语 |
| cb              | Function    |   否      |  面部识别验证模式,详见附录-AuthenticateMode,不传时默认为0|

回调参数:
```var cb = function(error){}
```

| 参数名称    | 参数类型   | 是否必选 | 说明                                       |
| ------- | ------ | ---- | ---------------------------------------- |
| error              | Number       |   是      |  ret是一个ErrorCode ,详见附录-ErrorCode,非0时均表示验证失败 |

**示例:**

```var ret = var ret = uexFaceID.canAuthenticateForFaceID();
if (ret != 0){
alert("FaceID Unavailable!errorCode: " + ret);
}else{
uexFaceID.authenticateWithFaceID({
mode:0,
hint:"AppCan需要验证您的脸部"
},
function(ret){
if(ret == 0){
alert("Authentication Succeed!");
}else{
alert("Authentication Failed!errorCode:" + ret);
}
});
}
```


### 🍭 附录
AuthenticateMode 验证模式

说明：
AuthenticateMode 是一个Int类型的枚举值

| mode    | 含义   | 解释 | 备注                                      |
| ------- | ------ | ---- | ---------------------------------------- |
| 0              | DeviceOwnerAuthenticationWithBiometrics       |   默认的面部识别验证模式,仅当面部识别验证通过时返回成功     |  ret是一个ErrorCode ,详见附录-ErrorCode,非0时均表示验证失败 |
| 1             | DeviceOwnerAuthentication       |  允许用户使用设备密码代替面部识别进行验证    需要iOS 11.0+ 系统 |

当设备不支持所选择的验证模式时,插件会默认验证模式为0

ErrorCode 错误码
ErrorCode 是一个Int类型的枚举值,非零值时均表示操作失败

code     |  含义 |   解释  |   备注
| ------- | ------ | ---- | ---------------------------------------- |
0     |  NoError |    没有发生错误,操作成功    
-1    | AuthenticationFailed   |  验证失败    
-2    | UserCancel   |   用户取消,用户点击取消按钮时会导致此结果    
-3    | UserFallback    |  用户回退,在默认验证模式下用户选择"输入密码"会导致此结果    
-4    | SystemCancel    |  系统取消,当另一个应用切换到前台时会导致此结果    
-5    |  PasscodeNotSet    |  用户没有设置设备密码时,会导致此结果    
-6    |  FaceIDNotAvailable    |  FaceID不可用时会导致此结果,可能是设备不支持或者系统版本太低    
-7    |  FaceIDNotEnrolled   |   用户设置了设备密码但没有设置面部识别时,会导致此结果    
-8    |  FaceIDLockout    |   用户验证面部识别错误次数过多会导致此结果    
其他情况 |   UnknownError   | 未知错误


# 3、更新历史

### Ios

API版本: `uexFaceID-4.0.0`

最近更新时间:`2019-3-27`


### Android

uexFaceID暂不支持Android

| 历史发布版本 | 更新内容 |
| ----- | ----- |
