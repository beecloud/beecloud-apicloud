/**
 * BCPay.java
 *
 * Created by xuanzhui on 2015/7/27.
 * Copyright (c) 2015 BeeCloud. All rights reserved.
 */
package cn.beecloud;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import com.alipay.sdk.app.PayTask;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.tencent.mm.sdk.constants.Build;
import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.annotation.UzJavascriptMethod;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

import org.apache.http.HttpResponse;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cn.beecloud.entity.BCPayReqParams;
import cn.beecloud.entity.BCPayResult;

/**
 * 支付类
 * 单例模式
 */
public class BCPay extends UZModule {

	public static final String apiVersion = "1.0.0";
			
    static UZModuleContext moduleContext;
    
    public BCPay(UZWebView webView) {
		super(webView);
		moduleContext=null;
		
		BeeCloud.setAppIdAndSecret(this.getFeatureValue("beecloud", "bcAppID"), 
				this.getFeatureValue("beecloud", "bcAppSecret"));
		
    	initWechatPay(this.getContext(), 
    			this.getFeatureValue("beecloud", "urlScheme"));
	}
    
    public static UZModuleContext getModuleContext(){
    	return moduleContext;
    }

    // IWXAPI 是第三方app和微信通信的openapi接口
    public IWXAPI wxAPI = null;

    /**
     * 初始化微信支付，必须在需要调起微信支付的Activity的onCreate函数中调用
     * 微信支付只有经过初始化才能成功调起，其他支付渠道无此要求
     */
    public String initWechatPay(Context context, String wxAppId) {
    	
        String errMsg = null;
        
        if (context == null) {
            errMsg = "Error: initWechatPay里获取不到context.";
            //Log.e(TAG, errMsg);
        }

        if (wxAppId == null || wxAppId.length() == 0) {
            errMsg = "Error: initWechatPay里，wx_appid必须为合法的微信AppID.";
            //Log.e(TAG, errMsg);
        }

        // 通过WXAPIFactory工厂，获取IWXAPI的实例
        wxAPI = WXAPIFactory.createWXAPI(context, null);

        BCCache.getInstance().wxAppId = wxAppId;

        try {
            if (isWXPaySupported()) {
                // 将该app注册到微信
                wxAPI.registerApp(wxAppId);
            } else {
                errMsg = "Error: 安装的微信版本不支持支付.";
                //Log.d(TAG, errMsg);
            }
        } catch (Exception ignored) {
            errMsg = "Error: 无法注册微信 " + wxAppId + ". Exception: " + ignored.getMessage();
            //Log.e(TAG, errMsg);
        }

        return errMsg;
    }

    /**
     * 判断微信是否支持支付
     * @return true表示支持
     */
    private boolean isWXPaySupported() {
        boolean isPaySupported = false;
        if (wxAPI != null) {
            isPaySupported = wxAPI.getWXAppSupportAPI() >= Build.PAY_SUPPORTED_SDK_INT;
        }
        return isPaySupported;
    }

    /**
     * 校验bill参数
     * 设置公用参数
     *
     * @param billTitle       商品描述, 32个字节内, 汉字以2个字节计
     * @param billTotalFee    支付金额，以分为单位，必须是正整数
     * @param billNum         商户自定义订单号
     * @param parameters      用于存储公用信息
     * @param optional        为扩展参数，可以传入任意数量的key/value对来补充对业务逻辑的需求
     * @return                返回校验失败信息, 为null则表明校验通过
     */
    private String prepareParametersForPay(final String billTitle, final Integer billTotalFee,
                                           final String billNum, final Map<String, String> optional,
                                           BCPayReqParams parameters) {

        if (!BCValidationUtil.isValidBillTitleLength(billTitle)) {
            return "title 必须是长度不大于32个字节,最长16个汉字的字符串的合法字符串";
        }

        if (!BCValidationUtil.isValidBillNum(billNum))
            return "billno 必须是长度8~32位字母和/或数字组合成的字符串";

        if (billTotalFee < 0) {
            return "totalfee 以分为单位，必须是整数";
        }

        parameters.title = billTitle;
        parameters.totalFee = billTotalFee;
        parameters.billNum = billNum;
        parameters.optional = optional;

        return null;
    }
    
    /**
	 * <strong>函数</strong><br><br>
	 * 该函数映射至Javascript中bcPay对象的pay函数<br><br>
	 * <strong>JS Example：</strong><br>
	 * bcPay.getApiVersion(argument);
	 * 
	 * @param moduleContext  (Required)
	 */
    @UzJavascriptMethod
    public void jsmethod_getApiVersion(final UZModuleContext moduleContext) {
    	JSONObject ret = new JSONObject();
    	
    	try {
			ret.put("apiVersion", apiVersion);
		} catch (JSONException e1) {
			e1.printStackTrace();
		}
    	
    	moduleContext.success(ret, true);
    }

    /**
	 * <strong>函数</strong><br><br>
	 * 该函数映射至Javascript中bcPay对象的pay函数<br><br>
	 * <strong>JS Example：</strong><br>
	 * bcPay.pay(argument);
	 * 
	 * @param moduleContext  (Required)
	 */
    @UzJavascriptMethod
    public void jsmethod_pay(final UZModuleContext moduleContext) {
    	BCPay.moduleContext = moduleContext;

        BCCache.executorService.execute(new Runnable() {
            @Override
            public void run() {
            	
            	String channelType = moduleContext.optString("channel");
            	String billTitle = moduleContext.optString("title");
            	Integer billTotalFee = moduleContext.optInt("totalfee");
            	String billNum = moduleContext.optString("billno");
            	
            	Map<String, String> optional = new HashMap<String, String>();
            	
            	JSONObject optionalObject = moduleContext.optJSONObject("optional");
            	if (optionalObject != null) {	
            		Iterator<String> keys = optionalObject.keys();
	            	while (keys.hasNext()){
	            		String key = keys.next();
	            		try {
							optional.put(key, optionalObject.getString(key));
						} catch (JSONException e) {
							e.printStackTrace();
						}
	            	}
            	}
            	
                //校验并准备公用参数
                BCPayReqParams parameters = null;
                try {
                    parameters = new BCPayReqParams(channelType);
                } catch (BCException e) {
                	
                	jsCallback(BCPayResult.BC_ERR_CODE_COMMON, "参数检查出错", e.getMessage());
                	
                    return;
                }

                String paramValidRes = prepareParametersForPay(billTitle, billTotalFee,
                        billNum, optional, parameters);

                if (paramValidRes != null) {
                	jsCallback(BCPayResult.BC_ERR_CODE_COMMON, "参数检查出错", paramValidRes);
                	
                    return;
                }

                String payURL = BCHttpClientUtil.getBillPayURL();

                HttpResponse response = BCHttpClientUtil.httpPost(payURL, parameters.transToBillReqMapParams());
                
                if (null == response) {
                	jsCallback(BCPayResult.BC_ERR_CODE_COMMON, "网络请求失败", "网络请求失败");
                    return;
                }
                if (response.getStatusLine().getStatusCode() == 200) {
                    String serverRet;
                    try {
                    	serverRet = EntityUtils.toString(response.getEntity(), "UTF-8");

                    	Gson res = new Gson();

                        Type type = new TypeToken<Map<String,Object>>() {}.getType();
                        Map<String, Object> responseMap = res.fromJson(serverRet, type);

                        //判断后台返回结果
                        Double resultCode = (Double) responseMap.get("result_code");
                        if (resultCode == 0) {

                            //针对不同的支付渠道调用不同的API
							if (channelType.equals("WX_APP")){
								reqWXPaymentViaAPP(responseMap);
							} else if (channelType.equals("ALI_APP")) {
								reqAliPaymentViaAPP(responseMap);
							} else if (channelType.equals("UN_APP")) {
								reqUnionPaymentViaAPP(responseMap);
							}
							else {
								jsCallback(BCPayResult.BC_ERR_CODE_COMMON, "参数检查出错",
										"channel渠道不支持");
							}
                        } else {
                            //返回后端传回的错误信息
                        	
                        	jsCallback(BCPayResult.BC_ERR_CODE_COMMON, "服务端返回错误信息", 
                        			serverRet);
                        }

                    } catch (IOException e) {                    	
                    	jsCallback(BCPayResult.BC_ERR_CODE_COMMON, "网络请求失败", 
                    			"网络请求失败");
                    }
                } else {
                	jsCallback(BCPayResult.BC_ERR_CODE_COMMON, "网络请求失败", 
                			"网络请求失败");
                }

            }
        });
    }
    
    private void jsCallback(int resultCode, String resultMsg, String errDetail){
    	JSONObject ret = new JSONObject();
    	
    	try {
			ret.put("result_code", resultCode);
			ret.put("result_msg", resultMsg);
			ret.put("err_detail", errDetail);
		} catch (JSONException e1) {
			e1.printStackTrace();
		}
    	
    	moduleContext.success(ret, true);
    }

    /**
     * 与服务器交互后下一步进入微信app支付
     *
     * @param responseMap     服务端返回参数
     */
    private void reqWXPaymentViaAPP(final Map<String, Object> responseMap) {

        //获取到服务器的订单参数后，以下主要代码即可调起微信支付。
        PayReq request = new PayReq();
        request.appId = String.valueOf(responseMap.get("app_id"));
        request.partnerId = String.valueOf(responseMap.get("partner_id"));
        request.prepayId = String.valueOf(responseMap.get("prepay_id"));
        request.packageValue = String.valueOf(responseMap.get("package"));
        request.nonceStr = String.valueOf(responseMap.get("nonce_str"));
        request.timeStamp = String.valueOf(responseMap.get("timestamp"));
        request.sign = String.valueOf(responseMap.get("pay_sign"));

        if (wxAPI != null) {
            wxAPI.sendReq(request);
        } else {
        	jsCallback(BCPayResult.BC_ERR_CODE_COMMON, "参数异常", 
        			"Error: 微信API为空, 需要初始化");
        }
    }

    /**
     * 与服务器交互后下一步进入支付宝app支付
     *
     * @param responseMap     服务端返回参数
     */
    private void reqAliPaymentViaAPP(final Map<String, Object> responseMap) {

        String orderString = (String) responseMap.get("order_string");

        PayTask aliPay = new PayTask((Activity)moduleContext.getContext());
        String aliResult = aliPay.pay(orderString);

        //解析ali返回结果
        Pattern pattern = Pattern.compile("resultStatus=\\{(\\d+?)\\}");
        Matcher matcher = pattern.matcher(aliResult);
        String resCode = "";
        if (matcher.find())
            resCode = matcher.group(1);

        int result;
        String errMsg;
        String errDetail;

        //9000-订单支付成功, 8000-正在处理中, 4000-订单支付失败, 6001-用户中途取消, 6002-网络连接出错
        if (resCode.equals("9000")) {
            result = BCPayResult.BC_SUCC;
            errMsg = BCPayResult.RESULT_SUCCESS;
            errDetail = BCPayResult.RESULT_SUCCESS;
        } else if (resCode.equals("6001")) {
            result = BCPayResult.BC_CANCLE;
            errMsg = BCPayResult.RESULT_CANCEL;
            errDetail = BCPayResult.RESULT_CANCEL;
        } else if (resCode.equals("4000") || resCode.equals("6002")){
        	result = BCPayResult.BC_ERR_FAIL;
            errMsg = "正在处理中";
            errDetail = "正在处理中";
        } else {
            result = BCPayResult.BC_ERR_CODE_COMMON;
            errMsg = BCPayResult.FAIL_ERR_FROM_CHANNEL;
            errDetail = aliResult;
        }
    	
    	jsCallback(result, errMsg, errDetail);
    }

    /**
     * 与服务器交互后下一步进入银联app支付
     *
     * @param responseMap     服务端返回参数
     */
    private void reqUnionPaymentViaAPP(final Map<String, Object> responseMap) {

        String TN = (String) responseMap.get("tn");

        Intent intent = new Intent();
        intent.setClass(moduleContext.getContext(), BCUnionPaymentActivity.class);
        intent.putExtra("tn", TN);
        moduleContext.getContext().startActivity(intent);
    }
}
