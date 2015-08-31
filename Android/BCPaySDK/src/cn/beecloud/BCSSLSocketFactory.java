/**
 * BCSSLSocketFactory.java
 *
 * Created by xuanzhui on 2015/7/27.
 * Copyright (c) 2015 BeeCloud. All rights reserved.
 */
package cn.beecloud;

import org.apache.http.conn.ssl.SSLSocketFactory;

import java.io.IOException;
import java.net.Socket;
import java.security.KeyManagementException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

/**
 * 用于BCHttpClientUtil wrapClient
 * @see BCHttpClientUtil
 */
class BCSSLSocketFactory extends SSLSocketFactory {

    final SSLContext sslContext = SSLContext.getInstance("TLS");

    BCSSLSocketFactory(KeyStore trustStore)
            throws NoSuchAlgorithmException, KeyManagementException,
            KeyStoreException, UnrecoverableKeyException {
        super(trustStore);

        TrustManager tm = new X509TrustManager() {
            public void checkClientTrusted(X509Certificate[] chain,
                                           String authType) throws CertificateException {
            }

            public void checkServerTrusted(X509Certificate[] chain,
                                           String authType) throws CertificateException {
            }

            public X509Certificate[] getAcceptedIssuers() {
                return null;
            }
        };

        sslContext.init(null, new TrustManager[]{tm}, null);
    }

    @Override
    public Socket createSocket(Socket socket, String host, int port,
                               boolean autoClose) throws IOException {
        return sslContext.getSocketFactory().createSocket(socket, host, port,
                autoClose);
    }

    @Override
    public Socket createSocket() throws IOException {
        return sslContext.getSocketFactory().createSocket();
    }
}
