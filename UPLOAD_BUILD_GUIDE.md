# How to Upload Build to App Store Connect

## Step 1: Prepare Your Project
1. Open your Weather project in Xcode
2. Select your project in the navigator
3. Make sure your Bundle Identifier is set to: `com.weiproduct.WeiWeathers`
4. Set your Development Team in Signing & Capabilities

## Step 2: Create Archive
1. In Xcode, select **Product** → **Destination** → **Any iOS Device (arm64)**
2. Go to **Product** → **Archive**
3. Wait for the archive to build (this may take a few minutes)

## Step 3: Upload to App Store Connect
1. When archive is complete, the **Organizer** window will open
2. Select your archive and click **Distribute App**
3. Choose **App Store Connect**
4. Click **Next**
5. Choose **Upload** 
6. Click **Next** through the signing options
7. Click **Upload**

## Step 4: Wait for Processing
- The upload will take 5-15 minutes depending on your internet speed
- Once uploaded, it takes 10-30 minutes for Apple to process the build
- You'll receive an email when processing is complete

## Step 5: Select Build in App Store Connect
1. Go back to App Store Connect
2. Navigate to your app → **1.0 Prepare for Submission**
3. Scroll down to the **Build** section
4. Click **Select a build before you submit your app**
5. Choose your uploaded build from the list
6. Click **Done**

## Common Issues:
- **Build not appearing**: Wait longer, processing can take up to 30 minutes
- **Missing compliance info**: You may need to answer export compliance questions
- **Invalid binary**: Check that your bundle ID matches exactly

## Alternative: Command Line Upload
If you have issues with Xcode, you can also upload using:
```bash
xcrun altool --upload-app -f "YourApp.ipa" -u "your-apple-id" -p "your-app-password"
```

After successful upload and processing, you'll be able to select the build in App Store Connect.