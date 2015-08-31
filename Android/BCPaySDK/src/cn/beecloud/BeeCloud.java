/**
 * BeeCloud.java
 *
 * Created by xuanzhui on 2015/7/27.
 * Copyright (c) 2015 BeeCloud. All rights reserved.
 */
package cn.beecloud;

/**
 * 全局参数配置类
 * 建议在主activity中初始化
 */
public class BeeCloud {
    /**
     * BeeCloud Android SDK 版本
     */
    public static final String BEECLOUD_ANDROID_SDK_VERSION = "1.3";

    /**
     * 设置AppId和AppSecret(从BeeCloud网站的控制台获得), 并进行一系列异步的初始化
     * 本函数必须在所有其他BeeCloud函数调用前被调用, 推荐在主Activity的onCreate函数中调用
     *
     * @param appId     App ID obtained from BeeCloud website.
     * @param appSecret App Secret obtained from BeeCloud website.
     */
    public static void setAppIdAndSecret(String appId, String appSecret) {
        BCCache instance = BCCache.getInstance();
        instance.appId = appId;
        instance.appSecret = appSecret;
    }

    /**
     * 修改所有网络请求的超时时间，单位是毫秒，默认为10秒.
     *
     * @param networkTimeout 超时时间，单位为毫秒，例如5000表示5秒.
     */
    public static void setNetworkTimeout(Integer networkTimeout) {
        BCCache.getInstance().networkTimeout = networkTimeout;
    }
}
