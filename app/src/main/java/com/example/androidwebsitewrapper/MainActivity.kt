package com.example.androidwebsitewrapper

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.util.Log

class MainActivity : Activity() {

    private lateinit var webView: WebView

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webview)

        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            setSupportZoom(true)
            builtInZoomControls = true
            displayZoomControls = false
            loadWithOverviewMode = true
            useWideViewPort = true
            cacheMode = WebSettings.LOAD_DEFAULT
            allowFileAccess = true
            allowContentAccess = true
            setSupportMultipleWindows(false)
        }

        webView.webViewClient = object : WebViewClient() {
            // For API 23+ (but with fallback for older versions)
            override fun onReceivedError(
                view: WebView?,
                request: WebResourceRequest?,
                error: WebResourceError?
            ) {
                super.onReceivedError(view, request, error)
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                    Log.e("WebView", "Error loading page: ${error?.description}")
                    
                    if (error?.errorCode == ERROR_CONNECT || 
                        error?.errorCode == ERROR_TIMEOUT ||
                        error?.errorCode == ERROR_HOST_LOOKUP) {
                        // Retry with different cache mode
                        view?.settings?.cacheMode = WebSettings.LOAD_NO_CACHE
                        view?.reload()
                    }
                }
            }

            // Deprecated but needed for API < 23
            @Suppress("OVERRIDE_DEPRECATION", "DEPRECATION")
            override fun onReceivedError(
                view: WebView?,
                errorCode: Int,
                description: String?,
                failingUrl: String?
            ) {
                super.onReceivedError(view, errorCode, description, failingUrl)
                Log.e("WebView", "Error loading page: $description")
                
                if (errorCode == ERROR_CONNECT || 
                    errorCode == ERROR_TIMEOUT ||
                    errorCode == ERROR_HOST_LOOKUP) {
                    // Retry with different cache mode
                    view?.settings?.cacheMode = WebSettings.LOAD_NO_CACHE
                    view?.reload()
                }
            }

            @Deprecated("Use shouldOverrideUrlLoading(WebView, WebResourceRequest) instead")
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                url?.let { view?.loadUrl(it) }
                return true
            }
        }

        // Load the URL
        val url = "https://www.example.com"
        Log.d("WebView", "Loading URL: $url")
        webView.loadUrl(url)
    }

    @Suppress("OVERRIDE_DEPRECATION", "DEPRECATION")
    override fun onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack()
        } else {
            super.onBackPressed()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        webView.destroy()
    }
}
