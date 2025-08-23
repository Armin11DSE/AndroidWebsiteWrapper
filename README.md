# Android Website Wrapper Generator

🚀 **Transform any website into an Android app in seconds!**

This project provides a simple, automated way to create Android apps that wrap websites in a WebView. Perfect for converting web applications, blogs, e-commerce sites, or any web content into native Android apps.

## ✨ Features

- **One-command generation** - Create apps instantly with a single script
- **Fully automated** - Updates app name, package, icon, and URL automatically  
- **Optimized & lightweight** - Minimal dependencies, fast performance
- **Android 5.0+ support** - Compatible with API level 21 and above
- **WebView optimized** - JavaScript, DOM storage, and zoom support enabled
- **Professional quality** - Clean code, proper back button handling

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/android-website-wrapper.git
cd android-website-wrapper
```

### 2. Make the Script Executable

```bash
chmod +x generate_app.sh
```

### 3. Generate Your App

```bash
./generate_app.sh "My App Name" "https://example.com" "./path/to/icon.png"
```

That's it! Your new app will be created in the `generated_apps/` directory.

## 📋 Usage

### Basic Syntax

```bash
./generate_app.sh <app_name> <website_url> <icon_path> [package_name]
```

### Parameters

- **`app_name`** - Display name for your app (shown in launcher)
- **`website_url`** - URL of the website to wrap (must include http:// or https://)
- **`icon_path`** - Path to your app icon (PNG recommended, any size)
- **`package_name`** *(optional)* - Custom Android package name

### Examples

**Create a news app:**

```bash
./generate_app.sh "Daily News" "https://news.example.com" "./icons/news.png"
```

**Create an e-commerce app:**

```bash
./generate_app.sh "My Store" "https://shop.example.com" "./icons/store.png" "com.mycompany.store"
```

**Create a blog app:**

```bash
./generate_app.sh "Tech Blog" "https://blog.example.com" "./icons/blog.png"
```

## 📁 Project Structure

```tree
android-website-wrapper/
├── README.md                    # This file
├── generate_app.sh              # Main generation script
├── app/                         # Template Android project
│   ├── src/main/
│   │   ├── java/               # Kotlin source files
│   │   ├── res/                # Android resources
│   │   └── AndroidManifest.xml
│   └── build.gradle            # App-level build config
├── gradle/                     # Gradle wrapper
├── build.gradle               # Project-level build config
├── libs.versions.toml         # Dependency versions
└── generated_apps/            # Output directory
    ├── my_app_1/
    ├── my_app_2/
    └── ...
```

## 🔧 What Gets Automated

The script automatically handles:

- ✅ **App Name** - Updates in `strings.xml`
- ✅ **Package Name** - Updates throughout the project
- ✅ **Website URL** - Replaces in `MainActivity.kt`
- ✅ **App Icon** - Copies to all resolution folders
- ✅ **Source Structure** - Reorganizes package directories
- ✅ **Build Configuration** - Updates `build.gradle` and `AndroidManifest.xml`
- ✅ **Clean Build** - Generates ready-to-build project

## 📱 Building Your Generated App

1. **Open in Android Studio**

   ```bash
   # Navigate to your generated app
   cd generated_apps/my_app_name
   ```

2. **Open the project in Android Studio**
   - File → Open → Select the generated app folder

3. **Sync and Build**
   - Android Studio will automatically sync Gradle
   - Build → Make Project
   - Run the app on device/emulator

## ⚙️ Customization Options

### WebView Settings

The generated apps include optimized WebView settings:

- JavaScript enabled
- DOM storage support
- Zoom controls (pinch-to-zoom)
- Wide viewport support
- Responsive layout handling

### Adding Features

You can extend generated apps with:

- **Push notifications**
- **Offline support**
- **File upload handling**
- **Custom splash screen**
- **Deep linking**
- **App-specific UI elements**

### Theme Customization

Modify these files in your generated app:

- `res/values/colors.xml` - App colors
- `res/values/strings.xml` - App strings
- `res/values/themes.xml` - Material themes

## 🎨 Icon Guidelines

For best results, provide app icons that are:

- **Format**: PNG with transparent background
- **Size**: 512x512px or larger (will be automatically resized)
- **Style**: Simple, recognizable design
- **Content**: Avoid text (may become unreadable when small)

## 🔍 Troubleshooting

### Common Issues

**"Permission denied" error:**

```bash
chmod +x generate_app.sh
```

**"Template not found" error:**
Make sure you're running the script from the project root directory.

**Website doesn't load properly:**

- Check if the URL is accessible
- Some sites block WebView loading (anti-iframe protection)
- Try adding `https://` prefix if missing

**Build errors in Android Studio:**

- Clean and rebuild: Build → Clean Project
- Invalidate caches: File → Invalidate Caches and Restart

### Generated App Issues

**App shows blank white screen:**

- Check internet connection
- Verify the website URL is correct
- Some websites require specific user agents

**Back button doesn't work:**
The template includes proper back button handling that navigates web history.

**Website features don't work:**
Some advanced web features may need additional WebView permissions or settings.

## 📊 Technical Details

- **Minimum Android Version**: Android 5.0 (API level 21)
- **Target Android Version**: Android 14 (API level 35)
- **Build Tools**: Android Gradle Plugin 8.10.1
- **Language**: Kotlin
- **Architecture**: Single Activity with WebView
- **Permissions**: Internet access only

## 🤝 Contributing

We welcome contributions! Here are ways to help:

1. **Report bugs** - Open issues for any problems
2. **Request features** - Suggest improvements
3. **Submit PRs** - Fix bugs or add features
4. **Improve documentation** - Help others understand the project

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with multiple website types
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Credits

Created with ❤️ for developers who want to quickly convert websites into Android apps.

Special thanks to all contributors and the Android development community.

---

## 🚀 Ready to get started?

```bash
git clone https://github.com/yourusername/android-website-wrapper.git
cd android-website-wrapper
chmod +x generate_app.sh
./generate_app.sh "My First App" "https://github.com" "./icon.png"
```

**Happy app building!** 📱✨
