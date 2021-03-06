#!/usr/bin/env bash
TESTFAIRY_API_KEY=2ac2709f30963b30320dbb3c375416b5956f5e6d

patch_android_modules() {
	sh ./gradlew tasks --all  | grep 'androidDependencies' | sed s/\:.*$// | \
		while read MODULE ; do
		if [ -f ${MODULE}/build.gradle ] ; then \
		    patch_gradle_build_file ${MODULE}/build.gradle ${TESTFAIRY_API_KEY}
		else
		    echo File not found: ${MODULE}/build.gradle
		fi
		done
}

patch_gradle_build_file() {
	FILE_TO_PATCH=$1
	echo -n  "Patching gradle build file" ${FILE_TO_PATCH} '..'
	API_KEY=$2

	grep 'TestFairy start - autogenerated by TestFairy' ${FILE_TO_PATCH} > /dev/null && echo "Already patched" && return


	echo "" >> ${FILE_TO_PATCH}
	echo "//TestFairy start - autogenerated by TestFairy" >> ${FILE_TO_PATCH}
	echo "//manual changes might get overwritten" >> ${FILE_TO_PATCH}
	echo "buildscript {" >> ${FILE_TO_PATCH}
	echo "   repositories {" >> ${FILE_TO_PATCH}
	echo "       mavenCentral()" >> ${FILE_TO_PATCH}
	echo "       maven { url 'https://www.testfairy.com/maven' }" >> ${FILE_TO_PATCH}
	echo "   }" >> ${FILE_TO_PATCH}
	echo "   dependencies {" >> ${FILE_TO_PATCH}
	echo "       classpath 'com.testfairy.plugins.gradle:testfairy:1.+'" >> ${FILE_TO_PATCH}
	echo "   }" >> ${FILE_TO_PATCH}
	echo "}" >> ${FILE_TO_PATCH}
	echo "apply plugin: 'testfairy'" >> ${FILE_TO_PATCH}
	echo "android {" >> ${FILE_TO_PATCH}
	echo "   testfairyConfig {" >> ${FILE_TO_PATCH}
	echo "       apiKey '"${API_KEY}"'" >> ${FILE_TO_PATCH}
	echo "   }" >> ${FILE_TO_PATCH}
	echo "}" >> ${FILE_TO_PATCH}
	echo "//TestFairy end" >> ${FILE_TO_PATCH}
	echo "" >> ${FILE_TO_PATCH}

	echo " done"
}

if [ -z ${TESTFAIRY_API_KEY} ]; then
	echo Environment variable TESTFAIRY_API_KEY is required.
	exit 1
fi

patch_android_modules