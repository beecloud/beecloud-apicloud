/**
 * BCWechatPaymentActivity.java
 *
 * Created by xuanzhui on 2015/7/27.
 * Copyright (c) 2015 BeeCloud. All rights reserved.
 */
package cn.beecloud;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import cn.beecloud.entity.BCPayResult;

/**
 * 微信支付结果接收类
 */
public class BCWechatPaymentActivity extends Activity implements IWXAPIEventHandler {
    private static final String TAG = "WechatPaymentActivity";

    private IWXAPI wxAPI;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.i(TAG, "into weixin return activity");

        try {
            String wxAppId = BCCache.getInstance().wxAppId;
            if (wxAppId != null && wxAppId.length() > 0) {
                wxAPI = WXAPIFactory.createWXAPI(this, wxAppId);
                wxAPI.handleIntent(getIntent(), this);
            } else {
                Log.e(TAG, "Error: wxAppId 不合法 WechatPaymentActivity: " + wxAppId);
            }
        } catch (Exception ex) {
            Log.e(TAG, ex.getMessage());
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        try {
            setIntent(intent);
            if (wxAPI != null) {
                wxAPI.handleIntent(intent, this);
            }
        } catch (Exception ex) {
            Log.e(TAG, ex.getMessage());
        }
    }

    /**
     * 微信发送请求到第三方应用时，会回调到该方法
     */
    @Override
    public void onReq(BaseReq baseReq) {

    }

    /**
     * 第三方应用发送到微信的请求处理后的响应结果，会回调到该方法
     */
    @Override
    public void onResp(BaseResp baseResp) {

        //Log.i(TAG, "onPayFinish, result code = " + baseResp.errCode);

        int resultCode = BCPayResult.BC_ERR_CODE_COMMON;
        String errMsg = BCPayResult.RESULT_FAIL;
        String errDetail = null;
        switch (baseResp.errCode) {
            case BaseResp.ErrCode.ERR_OK:
            	resultCode = BCPayResult.BC_SUCC;
            	errMsg = BCPayResult.RESULT_SUCCESS;
            	errDetail = errMsg;
                break;
            case BaseResp.ErrCode.ERR_USER_CANCEL:
            	resultCode = BCPayResult.BC_CANCEL;
            	errMsg = BCPayResult.RESULT_CANCEL;
            	errDetail = errMsg;
                break;
            case BaseResp.ErrCode.ERR_AUTH_DENIED:
            	errDetail = "发送被拒绝";
                break;
            case BaseResp.ErrCode.ERR_COMM:
            	errDetail = "一般错误";
                break;
            case BaseResp.ErrCode.ERR_UNSUPPORT:
            	errDetail = "不支持错误";
                break;
            case BaseResp.ErrCode.ERR_SENT_FAILED:
            	errDetail = "发送失败";
                break;
            default:
            	errDetail = "支付失败";
                break;
        }

        JSONObject ret = new JSONObject();

    	try {		
			ret.put("result_code", resultCode);
			ret.put("result_msg", errMsg);
			ret.put("err_detail", errDetail);
		} catch (JSONException e) {
			e.printStackTrace();
		}
    	
    	BCPay.getModuleContext().success(ret, true);
        
        this.finish();
    }
}
