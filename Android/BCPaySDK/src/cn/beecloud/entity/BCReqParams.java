/**
 * BCReqParams.java
 *
 * Created by xuanzhui on 2015/7/29.
 * Copyright (c) 2015 BeeCloud. All rights reserved.
 */
package cn.beecloud.entity;

import java.util.Date;

import cn.beecloud.BCCache;
import cn.beecloud.BCException;
import cn.beecloud.BCMD5Util;

/**
 * 向服务端请求的基类
 * 包含请求的公用参数
 */
public class BCReqParams {

    //BeeCloud应用APPID
    //BeeCloud的唯一标识
    private String appId;

    //签名生成时间
    //时间戳, 毫秒数
    private Long timestamp;

    //加密签名
    //算法: md5(app_id+timestamp+app_secret), 32位16进制格式, 不区分大小写
    private String appSign;

    /**
     * 渠道类型
     * 根据不同场景选择不同的支付方式
     */
    public String channel;

    /**
     * 请求类型
     */
    public enum ReqType{PAY, QUERY, QRCODE};

    /**
     * 渠道支付类型
     */
    public enum BCChannelTypes {

        /**
         * 微信手机原生APP支付
         */
        WX_APP,

        /**
         * 支付宝手机原生APP支付
         */
        ALI_APP,

        /**
         * 银联手机原生APP支付
         */
        UN_APP;

        /**
         * 判断是否为有效的app端支付渠道类型
         *
         * @param channel 支付渠道类型
         * @return true表示有效
         */
        public static boolean isValidAPPPaymentChannelType(String channel) {
            return channel.equals(WX_APP.name()) ||
                    channel.equals(ALI_APP.name()) ||
                    channel.equals(UN_APP.name());
        }

    }

    /**
     * BeeCloud的唯一标识
     * @return  BeeCloud应用APPID
     */
    public String getAppId() {
        return appId;
    }

    /**
     * 时间戳, 毫秒数
     * @return  签名生成时间
     */
    public Long getTimestamp() {
        return timestamp;
    }

    /**
     * 算法: md5(app_id+timestamp+app_secret), 32位16进制格式, 不区分大小写
     * @return  加密签名
     */
    public String getAppSign() {
        return appSign;
    }

    /**
     * 初始化参数
     * @param channel   渠道类型
     * @param reqType   请求类型
     */
    public BCReqParams(String channel) throws BCException{
        if (channel == null || !BCChannelTypes.isValidAPPPaymentChannelType(channel))
            throw new BCException("channel渠道不支持");

        BCCache mCache = BCCache.getInstance();

        if (mCache.appId == null || mCache.appSecret == null) {
            throw new BCException("parameters: 请通过BeeCloud初始化appId和appSecret");
        } else {
            appId = mCache.appId;
            timestamp = (new Date()).getTime();
            appSign = BCMD5Util.getMessageDigest(appId +
                    timestamp + mCache.appSecret);
            this.channel = channel;
        }
    }
}
