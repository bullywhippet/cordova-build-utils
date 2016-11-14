#!/bin/bash

if [ -z $ENV ]
then
   lowerEnv="dev"
else
   lowerEnv=`echo $ENV | tr '[A-Z]' '[a-z]'`
fi
upperEnv=`echo $lowerEnv | tr '[a-z]' '[A-Z]'`

now=`date +%Y-%m-%d-%H%M`
 
#Update Application Specific Values HERE
version=0.00.00
archivePath="${HOME}/Deployables/APPNAME"
packagePrefix="app-name-${lowerEnv}"
indexWaitTime=20
appNamePrefix="APPNAME"
if [ $upperEnv = "PROD" ]
then
	appName="${appNamePrefix}"
else
	appName="${appNamePrefix} ${upperEnv}"
fi
##Uncomment the line below to override the default android build tools
## version used by cordova.
#androidBuildToolVersion=22.0.1

#Update with your Signing values here 
provisioningProfile="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" 
developmentTeamId="XXXXXXXXX"
codeSignIdentity="iPhone Developer"

#############################################################################################################
#Start Generic Script
#DO NOT MODIFY BELOW UNLESS ABSOLUTELY NECESSARY
#############################################################################################################

echo "------CONFIG------"
echo "version: ${version}"
echo "archivePath: ${archivePath}"
echo "appName: ${appName}"
echo "packagePrefix: ${packagePrefix}"
echo "indexWaitTime: ${indexWaitTime}"
echo "androidBuildToolVersion: ${androidBuildToolVersion}"

archiveLocation="${archivePath}/${now}_${appName}.xcarchive"
appLocation="${archiveLocation}/Products/Applications/${appName}.app"
ipaLocation="${archivePath}/${appName}.ipa"
xcodeProjectLocation="platforms/ios/${appName}.xcodeproj"

echo "------RE-ADD iOS PLATFORM------"
cordova platform remove ios
cordova platform add ios

echo "------PRE-BUILDING iOS------"
cordova build ios

open "${xcodeProjectLocation}" 
echo "---------Waiting ${indexWaitTime} seconds to let project index---------"
sleep $indexWaitTime
echo "Closing Xcode"
osascript -e 'quit app "Xcode"'

echo "---------Beginning xcodebuild---------"
xcodebuild \
	-project "${xcodeProjectLocation}" \
	-scheme "${appName}" archive \
	-archivePath "${archiveLocation}" \
	-configuration Release \
	DEVELOPMENT_TEAM="${developmentTeamId}" \
	CODE_SIGN_IDENTITY="${codeSignIdentity}"
	#PROVISIONING_PROFILE="${provisioningProfile}" \

xcrun \
	-sdk iphoneos PackageApplication \
	-v "${appLocation}" \
	-o "${archivePath}/${packagePrefix}-v${version}.ipa"

#BUILDING ANDROID
echo "------BUILDING ANDROID------"
if [ -z "$androidBuildToolVersion" ]
then
        echo "---------No Android Build Tool Version set. Default to Cordova's Default"
        cordova build android
else
        echo "---------Android Build Tool Version set. Using ${androidBuildToolVersion}"
        cordova build android -- --gradleArg=-PcdvBuildToolsVersion=${androidBuildToolVersion}
fi

cp ./platforms/android/build/outputs/apk/android-debug.apk "${archivePath}/${packagePrefix}-v${version}.apk"


echo "------Archives Built-------"
open ${archivePath}
