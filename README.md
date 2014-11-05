ApportableFoundation
====================

ApportableFoundation is an open source implementation of Apple's Foundation Framework that extends Apple's open sourced CoreFoundation [CFLite implementation](http://www.opensource.apple.com/source/CF/). When paired with Apportable's freely available SpriteBuilder Android plugin, this repository provides a buildable and runnable Foundation for the Android platform.

In addition to our appreciation to Apple for open sourcing CFLite, we owe a debt of gratitude to other Foundation open source implementations - notably [GNUstep](http://www.gnu.org/software/gnustep/) and [Cocotron](http://www.cocotron.org/).

More generally, Apportable has been an active [open source user and contributor](http://www.apportable.com/open_source) throughout its history.

Thanks to [everyone](authors.md) who has contributed to ApportableFoundation!


Components
----------

ApportableFoundation consists of three modules - Foundation, CoreFoundation, and CFNetwork. It also includes several private headers required to build these three modules.


Installation
------------

- System Requirements:
	- Xcode 6
	- OSX 10.9+

- git clone git@github.com:apportable/Foundation.git

Building and running ApportableFoundation depend upon lower level include files and libraries that are available in the Xcode Plugin that is packaged in the SpriteBuilder Android Plugin.

- Install the [SpriteBuilder Android plugin](http://www.spritebuilder.com/beta).

- Early versions of the SpriteBuilder Android plugin are [missing Xcode templates](https://github.com/spritebuilder/SpriteBuilder/issues/1002).
	- Check: 
		- *ls -l /Library/SBAndroid/Developer/Xcode/Templates/Project\ Templates/Application/JNI\ Application.xctemplate*
	- If it doesn't exist: 
		- *cp -r XcodeTemplates/JNI\ Application.xctemplate ~/Library/Developer/Xcode/Templates/Project\ Templates/Application*


Back up
-------

Before building this repo, back up the installed version of the module you plan to build. 

For example:

- mkdir backup
- cp -rp /"Library/SBAndroid/Application Support/Developer/Shared/Xcode/Platforms/Android.platform/Developer/SDKs/SBAndroid0.9.sdk/System/Library/Frameworks/Foundation.framework" backup
- cp -rp /"Library/SBAndroid/Application Support/Developer/Shared/Xcode/Platforms/Android.platform/Developer/SDKs/SBAndroid0.9.sdk/System/Library/Frameworks/CoreFoundation.framework" backup
- cp -rp /"Library/SBAndroid/Application Support/Developer/Shared/Xcode/Platforms/Android.platform/Developer/SDKs/SBAndroid0.9.sdk/System/Library/Frameworks/CFNetwork.framework" backup

Xcode Build
----------------

To Build Foundation:

- Open System/Foundation/Foundation.xcodeproj
- Click the Build arrow in Xcode
- sudo rm -rf  "/Library/SBAndroid/Application Support/Developer/Shared/Xcode/Platforms/Android.platform/Developer/SDKs/SBAndroid0.9.sdk/System/Library/Frameworks/Foundation.framework"
- sudo cp -rp ~/Library/Application\ Support/Developer/Shared/Xcode/Platforms/Android.platform/Developer/SDKs/SBAndroid0.9.sdk/System/Library/Frameworks/Foundation.framework "/Library/SBAndroid/Application Support/Developer/Shared/Xcode/Platforms/Android.platform/Developer/SDKs/SBAndroid0.9.sdk/System/Library/Frameworks"/

Similar for CoreFoundation and CFNetwork.

Note that the SpriteBuilder Android plugin must be installed.


Command Line Build
-----------------------

- cd System/Foundation
- xcodebuild -config Debug 
- or xcodebuild -config Release
- sudo rm -rf  "/Library/SBAndroid/Application Support/Developer/Shared/Xcode/Platforms/Android.platform/Developer/SDKs/SBAndroid0.9.sdk/System/Library/Frameworks/Foundation.framework"
- sudo cp -rp ~/Library/Application\ Support/Developer/Shared/Xcode/Platforms/Android.platform/Developer/SDKs/SBAndroid0.9.sdk/System/Library/Frameworks/Foundation.framework "/Library/SBAndroid/Application Support/Developer/Shared/Xcode/Platforms/Android.platform/Developer/SDKs/SBAndroid0.9.sdk/System/Library/Frameworks"/

Similar for CoreFoundation and CFNetwork.

Note that the SpriteBuilder Android plugin must be installed.


Examples/Tutorials
------------------
- [Hello World](docs/hello.md)
- [Foundation Tests](docs/tests.md)
- [SpriteBuilder](docs/sb.md)


Forum
-----

Ask and answer questions on the [Apportable Open Source Forum](http://forum.opensource.apportable.com)

Contributing
------------

Check out the [Contributor's Guide](CONTRIBUTING.md)

Contact
-------
<opensource@apportable.com>

