/**
 * BCValidationUtil.java
 *
 * Created by xuanzhui on 2015/7/27.
 * Copyright (c) 2015 BeeCloud. All rights reserved.
 */
package cn.beecloud;

import java.io.UnsupportedEncodingException;

/**
 * 校验类
 */
class BCValidationUtil {

    /**
     * 判断string是否为空
     */
    public static boolean isValidString(String str) {
        return str != null && str.length() != 0;
    }
    
    /**
     * 判断string是否为空
     */
    public static boolean isValidBillNum(String str) {
        return str != null && str.length() >= 8 && str.length() <= 32;
    }

    /**
     * 判断字符串是否为有效的正整数
     * @param str
     */
    public static boolean isStringValidPositiveInt(String str) {
        boolean res = false;

        if (isValidString(str)){

            int length = str.length();
            int i = 0;

            for (; i < length; i++) {
                char c = str.charAt(i);
                if (c <= '/' || c >= ':') {
                    break;
                }
            }

            if (i == length)
                res = true;
        }

        return res;
    }

    /**
     * 判断订单长度是否在有效长度以内, 汉字以2个字节计, 总长度最大为32
     * @param str   订单标题
     * @return      true代表长度有效
     */
    public static boolean isValidBillTitleLength(String str) {
        if (!isValidString(str))
            return false;

        boolean res = false;

        try {
            byte[] bytes = str.getBytes("GBK");

            if (bytes.length <= 32)
                res = true;
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        return res;
    }
}
