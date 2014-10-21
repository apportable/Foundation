Hello World Tutorial
====================

Hello World shows how to build a minimal JNI hello world program that uses Foundation and builds and runs on an Android device.


Steps
-----

* Start Xcode (Android plug-in must have been installed) 
* Select New->Project
* Choose JNI Application

![My text](images/hello/new-jni-project.png)

* Name project
* Choose "com.apportable" for Organization Identifier
	* Optionally choose another identifier
	* If you do, after project creation, edit HelloAndroidActivity.m to match

![My text](images/hello/name-project.png)

* Continue to create project

![My text](images/hello/create-project.png)

* Connect Android device via USB to Mac
* Make sure the device is in developer mode. 

* If your Mac recognizes the device, the Xcode scheme will transition from a generic Android target

![My text](images/hello/pre-connect.png)

* To showing the specific device

![My text](images/hello/post-connect.png)

* Open HelloAndroid.m

* Double click line 16 to set a breakpoint

![My text](images/hello/breakpoint.png)

* Click the Build and Run button in the upper left corner

* Note "hello from printf" in the Output log

![My text](images/hello/printf.png)

* Click the Step Over icon

* Note "hello from NSLog" in the Output log

![My text](images/hello/nslog.png)
