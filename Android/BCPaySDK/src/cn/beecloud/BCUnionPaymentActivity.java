/**
 * BCUnionPaymentActivity.java
 *
 * Created by xuanzhui on 2015/7/27.
 * Copyright (c) 2015 BeeCloud. All rights reserved.
 */
package cn.beecloud;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import com.unionpay.UPPayAssistEx;

import cn.beecloud.entity.BCPayResult;

/**
 * 用于银联支付
 */
public class BCUnionPaymentActivity extends Activity {

	private static Integer targetVersion = 53;
    private static final String UN_APK_PACKAGE = "com.unionpay.uppay";
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onStart(){
        super.onStart();

        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            String tn= extras.getString("tn");
            int retPay;

            int curVer = getUNAPKVersion();
            if (curVer == -1)
                retPay = -1;
            else if (curVer < targetVersion)
                retPay = 2;
            else
                retPay = UPPayAssistEx.startPay(this, null, null, tn, "00");
            
            //插件问题 -1表示没有安装插件，2表示插件需要升级
            if (retPay==-1 || retPay==2) {
            	
            	AlertDialog.Builder builder = new AlertDialog.Builder(
            			BCUnionPaymentActivity.this);
		        builder.setTitle("提示");
		        builder.setMessage("完成支付需要安装或升级银联支付控件，是否继续？");
		        
		        builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
		            @Override
		            public void onClick(DialogInterface dialog, int which) {
		            	UPPayAssistEx.installUPPayPlugin(BCUnionPaymentActivity.this);
		                dialog.dismiss();
		            }
		        });
		        
		        builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
		            @Override
		            public void onClick(DialogInterface dialog, int which) {
		            	JSONObject ret = new JSONObject();
		                
		            	try {
		        			ret.put("result_code", BCPayResult.BC_ERR_PLUGIN_ISSUE);
		        			ret.put("result_msg", "银联插件问题");
		        			ret.put("err_detail", "银联插件问题, 需重新安装或升级");
		        		} catch (JSONException e) {
		        			e.printStackTrace();
		        		}
		            	
		            	BCPay.moduleContext.success(ret, true);
		            	
		                dialog.dismiss();
		                
		                finish();
		            }
		        });
		        
		        builder.create().show();

                
            }
        }
       
    }

    /**
     * 处理银联手机支付控件返回的支付结果
     */
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (data == null) {
            return;
        }

        int result = -1;
        String errMsg = null;
        /*
         * 支付控件返回字符串:success、fail、cancel 分别代表支付成功，支付失败，支付取消
         */
        String str = data.getExtras().getString("pay_result");
        if (str.equalsIgnoreCase("success")) {
            result = BCPayResult.BC_SUCC;
            errMsg = BCPayResult.RESULT_SUCCESS;
        } else if (str.equalsIgnoreCase("fail")) {
            result = BCPayResult.BC_ERR_CODE_COMMON;
            errMsg = BCPayResult.RESULT_FAIL;
        } else if (str.equalsIgnoreCase("cancel")) {
            result = BCPayResult.BC_CANCEL;
            errMsg = BCPayResult.RESULT_CANCEL;
        }

        JSONObject ret = new JSONObject();
        
    	try {
			ret.put("result_code", result);
			ret.put("result_msg", errMsg);
			ret.put("err_detail", errMsg);
		} catch (JSONException e) {
			e.printStackTrace();
		}
    	
    	BCPay.moduleContext.success(ret, true);

        this.finish();
    }
    
    private int getUNAPKVersion() {
        Integer version = -1;

        PackageManager packageManager=getPackageManager();
        try {
            PackageInfo Info=packageManager.getPackageInfo(UN_APK_PACKAGE, 0);
            version = Info.versionCode;
        } catch (PackageManager.NameNotFoundException e) {
            Log.e("union payment", e.getMessage());
        }

        return version;
    }
}
