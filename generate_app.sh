#!/bin/bash

# Android Website Wrapper App Generator
# Usage: ./generate_app.sh <app_name> <website_url> <icon_path> [package_name]

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required arguments are provided
if [ $# -lt 3 ]; then
    print_error "Usage: $0 <app_name> <website_url> <icon_path> [package_name]"
    print_error "Example: $0 'MyApp' 'https://example.com' './icon.png' 'com.mycompany.myapp'"
    exit 1
fi

# Parse arguments
APP_NAME="$1"
WEBSITE_URL="$2"
ICON_PATH="$3"
PACKAGE_NAME="${4:-com.generated.$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '')}"

# Validate inputs
if [[ ! "$WEBSITE_URL" =~ ^https?:// ]]; then
    print_error "Website URL must start with http:// or https://"
    exit 1
fi

if [[ ! -f "$ICON_PATH" ]]; then
    print_error "Icon file not found: $ICON_PATH"
    exit 1
fi

# Configuration
TEMPLATE_DIR="."  # Current directory is the template
OUTPUT_DIR="./generated_apps"
NEW_APP_DIR="$OUTPUT_DIR/$(echo "$APP_NAME" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')"

print_status "Starting app generation..."
print_status "App Name: $APP_NAME"
print_status "Website URL: $WEBSITE_URL"
print_status "Package Name: $PACKAGE_NAME"
print_status "Output Directory: $NEW_APP_DIR"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if we're in the right directory (should have app/ folder)
if [[ ! -d "app" ]]; then
    print_error "This script should be run from the root of the Android Website Wrapper project"
    print_error "Make sure you're in the directory that contains the 'app' folder"
    exit 1
fi

# Copy template to new app directory (excluding certain files/folders)
print_status "Copying template files..."
if [[ -d "$NEW_APP_DIR" ]]; then
    print_warning "Directory already exists. Removing: $NEW_APP_DIR"
    rm -rf "$NEW_APP_DIR"
fi

# Create new directory
mkdir -p "$NEW_APP_DIR"

# Copy all files except excluded ones
rsync -av \
    --exclude='.git/' \
    --exclude='generated_apps/' \
    --exclude='*.md' \
    --exclude='generate_app.sh' \
    --exclude='.gradle/' \
    --exclude='app/build/' \
    --exclude='build/' \
    --exclude='.idea/' \
    --exclude='*.iml' \
    --exclude='local.properties' \
    . "$NEW_APP_DIR"/

# Handle .gitignore specially - create a clean version for generated apps
print_status "Creating clean .gitignore for generated app..."
if [[ -f ".gitignore" ]]; then
    # Create new gitignore excluding the lines we don't want in generated apps
    grep -v "^\*.png$" .gitignore | grep -v "^/generated_apps" > "$NEW_APP_DIR/.gitignore.tmp"
    mv "$NEW_APP_DIR/.gitignore.tmp" "$NEW_APP_DIR/.gitignore"
    print_success "Clean .gitignore created (removed *.png and /generated_apps entries)"
fi

print_success "Template copied successfully"

# Navigate to new app directory
cd "$NEW_APP_DIR"

# Update app name in strings.xml
print_status "Updating app name..."
STRINGS_FILE="app/src/main/res/values/strings.xml"
if [[ -f "$STRINGS_FILE" ]]; then
    sed -i.bak "s/<string name=\"app_name\">.*<\/string>/<string name=\"app_name\">$APP_NAME<\/string>/" "$STRINGS_FILE"
    rm "$STRINGS_FILE.bak" 2>/dev/null || true
    print_success "App name updated in strings.xml"
else
    print_warning "strings.xml not found at expected location: $STRINGS_FILE"
fi

# Update package name in build.gradle
print_status "Updating package name..."
BUILD_GRADLE="app/build.gradle"
if [[ -f "$BUILD_GRADLE" ]]; then
    sed -i.bak "s/applicationId \".*\"/applicationId \"$PACKAGE_NAME\"/" "$BUILD_GRADLE"
    rm "$BUILD_GRADLE.bak" 2>/dev/null || true
    print_success "Package name updated in build.gradle"
else
    print_warning "build.gradle not found at expected location: $BUILD_GRADLE"
fi

# Update website URL in MainActivity or WebView configuration
print_status "Updating website URL..."
# Common locations for the URL - updated for new package structure
MAIN_ACTIVITY_JAVA="app/src/main/java/com/example/androidwebsitewrapper/MainActivity.java"
MAIN_ACTIVITY_KOTLIN="app/src/main/java/com/example/androidwebsitewrapper/MainActivity.kt"
WEBVIEW_CLIENT_JAVA="app/src/main/java/com/example/androidwebsitewrapper/WebViewClient.java"
WEBVIEW_CLIENT_KOTLIN="app/src/main/java/com/example/androidwebsitewrapper/WebViewClient.kt"

# Function to update URL in file
update_url_in_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Update common URL patterns
        sed -i.bak "s|loadUrl(\".*\")|loadUrl(\"$WEBSITE_URL\")|g" "$file"
        sed -i.bak "s|\"https\?://[^\"]*\"|\"$WEBSITE_URL\"|g" "$file"
        rm "$file.bak" 2>/dev/null || true
        print_success "URL updated in $(basename "$file")"
        return 0
    fi
    return 1
}

# Try to update URL in common files
updated=false
for file in "$MAIN_ACTIVITY_JAVA" "$MAIN_ACTIVITY_KOTLIN" "$WEBVIEW_CLIENT_JAVA" "$WEBVIEW_CLIENT_KOTLIN"; do
    if update_url_in_file "$file"; then
        updated=true
    fi
done

if [[ "$updated" == false ]]; then
    print_warning "Could not automatically update website URL. Please update it manually in your MainActivity or WebView configuration."
    print_warning "Look for files containing 'loadUrl' or URL references and replace with: $WEBSITE_URL"
fi

# Update package name in Java/Kotlin source files
print_status "Updating package declarations..."
find app/src/main/java -name "*.java" -o -name "*.kt" | while read -r file; do
    if grep -q "package com.example.androidwebsitewrapper" "$file" 2>/dev/null; then
        sed -i.bak "s/package com\.example\.androidwebsitewrapper/package ${PACKAGE_NAME//./\\.}/" "$file"
        rm "$file.bak" 2>/dev/null || true
        print_success "Updated package in $(basename "$file")"
    fi
done

# Move source files to new package structure
print_status "Reorganizing package structure..."
OLD_PACKAGE_PATH="app/src/main/java/com/example/androidwebsitewrapper"
NEW_PACKAGE_PATH="app/src/main/java/$(echo "$PACKAGE_NAME" | tr '.' '/')"

if [[ -d "$OLD_PACKAGE_PATH" ]]; then
    mkdir -p "$(dirname "$NEW_PACKAGE_PATH")"
    mv "$OLD_PACKAGE_PATH" "$NEW_PACKAGE_PATH"
    print_success "Moved source files to new package structure"
    
    # Clean up empty directories
    rmdir app/src/main/java/com/example 2>/dev/null || true
    rmdir app/src/main/java/com 2>/dev/null || true
fi

# Update AndroidManifest.xml
print_status "Updating AndroidManifest.xml..."
MANIFEST_FILE="app/src/main/AndroidManifest.xml"
if [[ -f "$MANIFEST_FILE" ]]; then
    sed -i.bak "s/package=\".*\"/package=\"$PACKAGE_NAME\"/" "$MANIFEST_FILE"
    sed -i.bak "s/android:name=\"\.MainActivity\"/android:name=\"${PACKAGE_NAME}.MainActivity\"/" "$MANIFEST_FILE"
    sed -i.bak "s/android:name=\"com\.example\.androidwebsitewrapper\.MainActivity\"/android:name=\"${PACKAGE_NAME}.MainActivity\"/" "$MANIFEST_FILE"
    rm "$MANIFEST_FILE.bak" 2>/dev/null || true
    print_success "AndroidManifest.xml updated"
else
    print_warning "AndroidManifest.xml not found at expected location: $MANIFEST_FILE"
fi

# Update app icon
print_status "Updating app icon..."

# Get the absolute path of the icon
ICON_ABSOLUTE_PATH="$(cd "$(dirname "$ICON_PATH")" && pwd)/$(basename "$ICON_PATH")"

# Remove existing icons first to avoid conflicts
print_status "Removing existing default icons..."
find app/src/main/res -name "ic_launcher*.png" -delete 2>/dev/null || true
find app/src/main/res -name "ic_launcher*.xml" -delete 2>/dev/null || true

# Define icon directories
ICON_DIRS=("app/src/main/res/mipmap-hdpi" "app/src/main/res/mipmap-mdpi" "app/src/main/res/mipmap-xhdpi" "app/src/main/res/mipmap-xxhdpi" "app/src/main/res/mipmap-xxxhdpi")

# Copy new icon to all density folders
for dir in "${ICON_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        cp "$ICON_ABSOLUTE_PATH" "$dir/ic_launcher.png" 2>/dev/null || print_warning "Could not copy icon to $dir"
        cp "$ICON_ABSOLUTE_PATH" "$dir/ic_launcher_round.png" 2>/dev/null || print_warning "Could not copy icon to $dir"
    fi
done

print_success "App icon updated"

# Update gradle wrapper properties if needed
print_status "Checking Gradle wrapper..."
if [[ -f "gradle/wrapper/gradle-wrapper.properties" ]]; then
    print_success "Gradle wrapper found"
else
    print_warning "Gradle wrapper not found. You may need to run './gradlew wrapper' after generation"
fi

# Generate README for the new app
print_status "Generating README..."
cat > README.md << EOF
# $APP_NAME

This is an automatically generated Android app that displays the website: $WEBSITE_URL

## App Details
- **App Name:** $APP_NAME
- **Package Name:** $PACKAGE_NAME
- **Website URL:** $WEBSITE_URL
- **Generated on:** $(date)

## Building the App

1. Open this project in Android Studio
2. Sync the project with Gradle files
3. Build and run the app

## Customization

To further customize this app, you can:
- Modify the WebView settings in MainActivity
- Update the app theme and colors in res/values/
- Add additional features like splash screen, offline support, etc.
- Update the app icon by replacing files in res/mipmap-* directories

## Generated by
Android Website Wrapper Generator
EOF

print_success "README.md generated"

# Final status
print_success "App generation completed successfully!"
print_status "Generated app location: $NEW_APP_DIR"
print_status ""
print_status "Next steps:"
print_status "1. Open the project in Android Studio: $NEW_APP_DIR"
print_status "2. Sync project with Gradle files"
print_status "3. Build and test the app"
print_status "4. Make any additional customizations needed"
print_status ""
print_warning "Manual verification needed:"
print_warning "- Check that the website URL is correctly updated in MainActivity"
print_warning "- Verify that all package references are updated"
print_warning "- Test the app thoroughly before deployment"

cd - > /dev/null  # Return to original directory