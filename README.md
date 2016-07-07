/*
Title: beecloud
Description: BeeCloud Pay.
*/

* 方法  

[pay](#a1)
[getApiVersion](#a2)
[isSandboxMode](#a3)
[isWXAppInstalled](#a4)
[canMakeApplePayments](#a5)


# **概述**
beecloud 封装了支付宝(ALI\_APP)，微信(WX\_APP)，银联(UN\_APP)，百度钱包(BD\_APP)，Apple Pay(APPLE)四个主流渠道的支付接口。使用此模块可轻松实现各个渠道的支付功能。  
 
使用之前需要先到[BeeCloud](https://beecloud.cn) 注册认证，并[快速开始](https://beecloud.cn/apply)接入BeeCloud Pay.  
更多信息请访问[BeeCloud帮助中心](http://help.beecloud.cn)。

**此模块支持沙箱测试，沙箱测试模式下不产生真实交易。** 

# **配置**
注意: 使用此模块时,请勿同时勾选 aliPay, weChat, unionPay, appleUnionPay模块.

**使用此模块之前需先配置config文件的Feature**

配置示例:

```js
<feature name="beecloud">
	<param name="urlScheme" value="wxf1aa465362b4c8f1" />
	<param name="bcAppID" value="c5d1cba1-5e3f-4ba0-941d-9b0a371fe719" />
	<param name="sandbox" value="true" />
</feature>
```
配置描述:
  
	1.feature-name: beecloud.
	2.param-urlScheme: 此字段为URL Scheme类型,配置为微信开放平台APPID,使得本应用可以启动微信客户端，并与之交换数据.如果不使用微信支付，可自定义配置。
	3.param-bcAppID: BeeCloud平台AppID.
	4.param-sandbox: "true|false"。默认为"false"。  
	  "true"代表切换到沙箱测试模式，沙箱测试模式下不产生真实交易；
	  "false"代表切换到生产模式；
	  
</br>
# **pay**<div id="a1"></div>
支付  
pay(params, callback);

## params
channel：

 * 类型：String  
 * 默认值：无  
 * 描述：支付渠道。微信（WX\_APP），支付宝（ALI\_APP），银联在线（UN\_APP），百度钱包（BD\_APP），Apple Pay（APPLE）
 
title：  

 * 类型：String  
 * 默认值：无  
 * 描述：订单描述。32个字节，最长支持16个汉字。
 
billno：

 * 类型：String  
 * 默认值：无  
 * 描述：订单号。8~32位字母和\或数字组合，必须保证在商户系统中唯一。建议根据当前时间生成订单号，格式为：yyyyMMddHHmmssSSS,"201508191436987"。
 
totalfee：  

 * 类型：Int  
 * 默认值：无  
 * 描述：订单金额。以分为单位，例如：100代表1元。
 
optional：  

 * 类型：Map(String, String) 
 * 默认值：无  
 * 描述：商户业务扩展，用于商户传递处理业务参数，会在**[webhook回调](https://beecloud.cn/doc/?index=8)**中返回。例：{'userID':'张三','mobile':'0512-86861620'}
    
## callback(ret, err)

ret:  

 * 类型：JSON对象  
 
内部字段：

```js
{
	result_code: 0,  //返回码，0代表成功
	result_msg: "支付成功", //返回信息
	err_detail: "" //当result_code不为0时，返回具体fail原因 
}
```
err:

 * 描述：所有信息都通过ret返回，err暂未启用。 

## 示例代码

```js
var payData = {
	channel: "UN_APP",
	title: "apicloud",
	totalfee: 1,
	billno: "201508191436987",
	optional: {'userID':'张三','mobile':'0512-86861620'}    
};

var demo = api.require('beecloud');
demo.pay(payData, payCallBack);

function payCallBack(ret, err) {
	api.toast({msg:ret.result_msg});
}	
```

## 补充说明

回调样例：

```js
//成功
{
	result_code: 0,
	result_msg: "支付成功",
	err_detail: ""
}
//失败
{
	result_code: -1,
	result_msg: "title 必须是长度不大于32个字节,最长16个汉字的字符串的合法字符串",
	err_detail: "title 必须是长度不大于32个字节,最长16个汉字的字符串的合法字符串"
}
```

## 可用性

iOS系统，Android系统  
可提供的1.0.0及更高版本  


# **getApiVersion**<div id="a2"></div>
获取API版本
  
getApiVersion(callback);

## callBack(ret, err)

ret:  

 * 类型：JSON对象  
 
内部字段：

```js
{
	apiVersion: "1.0.0" 
}
```
## 示例代码

```js
var demo = api.require('beecloud');
demo.getApiVersion(callBack);

function callBack(ret, err) {
	api.toast({msg:ret.apiVersion});
}
```

## 补充说明
无

## 可用性

iOS系统，Android系统  
可提供的1.0.0及更高版本 


# **isSandboxMode**<div id="a3"></div>
判断当前是否是沙箱测试环境
  
isSandboxMode(callback);

## callBack(ret, err)

ret:  

 * 类型：JSON对象  
 
内部字段：

```js
{
	flag: true //沙箱测试环境
}
```
## 示例代码

```js
var demo = api.require('beecloud');
demo.isSandboxMode(callBack);

function callBack(ret, err) {
	api.toast({msg:ret.flag});
}
```

## 补充说明
无

## 可用性

iOS系统，Android系统  
可提供的1.4.0及更高版本 


# **isWXAppInstalled**<div id="a3"></div>
判断是否安装微信客户端
  
isWXAppInstalled(callback);

## callBack(ret, err)

ret:  

 * 类型：JSON对象  
 
内部字段：

```js
{
	flag: true //沙箱测试环境
}
```
## 示例代码

```js
var demo = api.require('beecloud');
demo.isWXAppInstalled(callBack);

function callBack(ret, err) {
	api.toast({msg:ret.flag});
}
```

## 补充说明
无

## 可用性

iOS系统，Android系统  
可提供的1.4.0及更高版本


# **canMakeApplePayments**<div id="a3"></div>
判断是否支持Apple Pay
  
canMakeApplePayments(params, callback);

## params

cardType
 
  * 类型：Int
  * 默认值：0
  * 描述：0 代表不区分卡类型；1 代表借记卡；2 代表信用卡。

## callBack(ret, err)

ret:  

 * 类型：JSON对象  
 
内部字段：

```js
{
	status: true //支持
}
```
## 示例代码

```js
var demo = api.require('beecloud');
var params = {
	cardType: 0 
};
demo.canMakeApplePayments(params, callBack);

function callBack(ret, err) {
	api.toast({msg:ret.status});
}
```

## 补充说明
商户 App 在调用 Apple Pay 之前要注意根据此方法函数判断手机是否可用 Apple Pay 做应用内支付,从而判断是否显示 Apple Pay 支付按钮。

## 可用性

iOS系统 
可提供的1.4.0及更高版本



