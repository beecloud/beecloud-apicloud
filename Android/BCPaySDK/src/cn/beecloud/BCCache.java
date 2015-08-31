/**
 * BCCache.java
 *
 * Created by xuanzhui on 2015/7/27.
 * Copyright (c) 2015 BeeCloud. All rights reserved.
*/
package cn.beecloud;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 配置缓存类
 * 单例模式
 */
public class BCCache {

    private static BCCache instance;

    /**
     * BeeCloud控制台注册的App Id
     */
    public String appId;

    /**
     * BeeCloud控制台注册的App Secret
     */
    public String appSecret;

    /**
     * 微信App Id
     */
    public String wxAppId;

    /**
     * 网络请求timeout时间
     * 以毫秒为单位
     */
    public Integer networkTimeout;

    /**
     * 线程池
     */
    public static ExecutorService executorService = Executors.newCachedThreadPool();

    private BCCache() {
    }

    /**
     * 唯一获取实例的方法
     * @return  BCCache实例
     */
    public synchronized static BCCache getInstance() {
        if (instance == null) {
            instance = new BCCache();

            instance.appId = null;
            instance.appSecret = null;

            instance.wxAppId = null;

            instance.networkTimeout = 10000;
        }
        return instance;
    }
}
