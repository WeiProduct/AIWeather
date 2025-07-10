#!/bin/bash

# Setup script for WeiWeathers Privacy Policy GitHub Repository
# Run this script to upload your privacy policy to GitHub

echo "Setting up WeiWeathers Privacy Policy Repository..."

# Create a temporary directory
mkdir -p ~/Desktop/weiweathers-privacy-temp
cd ~/Desktop/weiweathers-privacy-temp

# Copy the privacy policy files
cp ~/Desktop/Weather/index.html .
cp ~/Desktop/Weather/privacy-policy.md .
cp ~/Desktop/Weather/README_PRIVACY.md ./README.md

# Initialize git repository
git init

# Add files
git add .

# Commit files
git commit -m "Add privacy policy for WeiWeathers app"

# Add remote repository
git remote add origin https://github.com/WeiProduct/weiweathers-privacy.git

# Push to GitHub
git push -u origin main

echo "Privacy policy uploaded successfully!"
echo "Now go to GitHub repository settings to enable GitHub Pages"
echo "Your privacy policy will be available at: https://weiproduct.github.io/weiweathers-privacy/"