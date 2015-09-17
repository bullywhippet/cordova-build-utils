#!/bin/bash

#Update Application Specific Values HERE
version=0.01.00
archivePath="${HOME}/Deployables/APPNAME"
appName="APPNAME"
packagePrefix="app-name"

#Update with your Profisioning Profile Information Here 
provisioningProfile="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" 
codeSignIdentity="iPhone Distribution: Your Company Name, LLC"

#############################################################################################################
#Start Generic Script
#DO NOT MODIFY BELOW UNLESS ABSOLUTELY NECESSARY
#############################################################################################################
archiveLocation="${archivePath}/${appName}.xcarchive"
appLocation="${archiveLocation}/Products/Applications/${appName}.app"
ipaLocation="${archivePath}/${appName}.ipa"
xcodeProjectLocation="platforms/ios/${appName}.xcodeproj"

xcodebuild \
	-project "${xcodeProjectLocation}" \
	-scheme "${appName}" archive \
	-archivePath "${archiveLocation}" \
	-configuration Release \
	PROVISIONING_PROFILE="${provisioningProfile}" \
	CODE_SIGN_IDENTITY="${codeSignIdentity}"

xcrun \
	-sdk iphoneos PackageApplication \
	-v "${appLocation}" \
	-o "${archivePath}/${packagePrefix}-v${version}.ipa"

#BUILDING ANDROID
echo "------BUILDING ANDROID------"
cordova build android

cp ./platforms/android/build/outputs/apk/android-debug.apk "${archivePath}/${packagePrefix}-v${version}.apk"


echo "------Archives Built-------"
open ${archivePath}
