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
import android.view.View
import android.view.WindowInsetsController
import android.view.WindowManager
import android.os.Build
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

class MainActivity : Activity() {

    private lateinit var webView: WebView

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webview)

        // Configure window for proper display
        configureWindow()

        // Configure WebView insets to avoid overlay buttons
        configureWebViewInsets()

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
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
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
    private fun configureWindow() {
        // Make status bar and navigation bar transparent/translucent
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+ approach
            window.setDecorFitsSystemWindows(false)
            val controller = window.insetsController
            controller?.apply {
                // Keep status bar visible but make it translucent
                systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            // Legacy approach for older Android versions
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    )

            // Make status bar translucent
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.statusBarColor = 0x66000000 // Semi-transparent black
        }
    }

    private fun configureWebViewInsets() {
        ViewCompat.setOnApplyWindowInsetsListener(webView) { view, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            val navigationBars = insets.getInsets(WindowInsetsCompat.Type.navigationBars())

            // Apply padding to avoid overlay buttons
            view.setPadding(
                systemBars.left,
                systemBars.top,
                systemBars.right,
                maxOf(systemBars.bottom, navigationBars.bottom)
            )

            // Return consumed insets
            WindowInsetsCompat.CONSUMED
        }
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