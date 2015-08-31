/**
 * BCPayResult.java
 *
 * Created by xuanzhui on 2015/7/27.
 * Copyright (c) 2015 BeeCloud. All rights reserved.
*/
package cn.beecloud.entity;

import cn.beecloud.async.BCResult;

/**
 * 支付结果返回类
 *
 * @see cn.beecloud.async.BCResult
 */
public class BCPayResult implements BCResult {
    //result包含支付成功、取消支付、支付失败
    private String result;
    //针对支付失败的情况，提供失败原因
    private String errMsg;
    //提供详细的支付信息，比如原生的支付宝返回信息
    private String detailInfo;
    
    //result code
    public static int BC_SUCC = 0;
    public static int BC_ERR_CODE_COMMON = -1;
    public static int BC_CANCLE = -2;
    public static int BC_ERR_FAIL = -3;
    public static int BC_ERR_UNSUPPORT = -4;
    public static int BC_ERR_PLUGIN_ISSUE = -5;

    /**
     * 表示支付成功
     */
    public static final String RESULT_SUCCESS = "支付成功";

    /**
     * 表示用户取消支付
     */
    public static final String RESULT_CANCEL = "支付取消";

    /**
     * 表示支付失败
     */
    public static final String RESULT_FAIL = "支付失败";

    /**
     * 针对银联，存在插件不存在需要安装的问题
     */
    public static final String FAIL_PLUGIN_NOT_INSTALLED = "FAIL_PLUGIN_NOT_INSTALLED";

    /**
     * 针对银联，存在插件需要升级的问题
     */
    public static final String FAIL_PLUGIN_NEED_UPGRADE = "FAIL_PLUGIN_NEED_UPGRADE";

    /**
     * 网络问题造成的支付失败
     */
    public static final String FAIL_NETWORK_ISSUE = "FAIL_NETWORK_ISSUE";

    /**
     * 参数不合法造成的支付失败
     */
    public static final String FAIL_INVALID_PARAMS = "参数检查出错";

    /**
     * 从beecloud服务端返回的错误
     */
    public static final String FAIL_ERR_FROM_SERVER = "FAIL_ERR_FROM_SERVER";

    /**
     * 从第三方app支付渠道返回的错误信息
     */
    public static final String FAIL_ERR_FROM_CHANNEL = "FAIL_ERR_FROM_CHANNEL";

    /**
     * 支付过程中的Exception
     */
    public static final String FAIL_EXCEPTION = "FAIL_EXCEPTION";

    /**
     * 构造函数
     * @param result        包含支付成功, 用户取消支付, 支付失败
     * @param errMsg        支付失败的分类错误信息
     * @param detailInfo    详细的支付结果信息, 对于错误显示详细的错误信息
     */
    public BCPayResult(String result, String errMsg, String detailInfo) {
        this.result = result;
        this.errMsg = errMsg;
        this.detailInfo = detailInfo;
    }

    /**
     * @return  支付结果
     */
    public String getResult() {
        return result;
    }

    /**
     * @return  支付失败的分类错误信息
     */
    public String getErrMsg() {
        return errMsg;
    }

    /**
     * @return  详细的支付结果信息, 对于错误显示详细的错误信息
     */
    public String getDetailInfo() {
        return detailInfo;
    }
}
