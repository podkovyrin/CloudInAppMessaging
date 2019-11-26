
# CloudInAppMessaging

[![CI Status](https://img.shields.io/travis/podkovyrin/CloudInAppMessaging.svg?style=flat)](https://travis-ci.org/podkovyrin/CloudInAppMessaging)
[![Version](https://img.shields.io/cocoapods/v/CloudInAppMessaging.svg?style=flat)](https://cocoapods.org/pods/CloudInAppMessaging)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Accio supported](https://img.shields.io/badge/Accio-supported-0A7CF5.svg?style=flat)](https://github.com/JamitLabs/Accio)
[![License](https://img.shields.io/cocoapods/l/CloudInAppMessaging.svg?style=flat)](https://cocoapods.org/pods/CloudInAppMessaging)
[![Platform](https://img.shields.io/cocoapods/p/CloudInAppMessaging.svg?style=flat)](https://cocoapods.org/pods/CloudInAppMessaging)

CloudInAppMessaging is CloudKit-powered SDK which allows you to engage active app users with contextual messages.

It was created as an open-source alternative to the [Firebase In-App Messaging](https://firebase.google.com/docs/in-app-messaging).

<p align="center">
<img src="https://github.com/podkovyrin/CloudInAppMessaging/raw/master/assets/alert.png?raw=true" alt="CloudInAppMessaging Alert" width="270">
</p>

## Details

### Features

- Create, configure and preview Alert Campaigns via separate Admin App.
- Open any URL (such as HTTP or a deeplink) by button action.
- Localization support.
- Targeting (by Countries, Languages, Min/Max App and OS versions).
- Scheduling with Start and/or End dates.
- Trigger displaying of Alert Campaign on any custom desired event or on system event such as "On Foreground" or "On App Launch".
- Customize the presentation of Alert Campaigns with your own UI.
- Your users don't need to have an iCloud account.
- Built with privacy in mind.
- Fork and hack it as you want!

### Implementation details

CloudInAppMessaging uses a public CloudKit database so it can be accessed by any user of your app even without an iCloud account. This comes with an important limitation of not having push notifications feature. Because currently, CloudKit supports push notifications for shared and private databases only they can't be used for purposes of sending In-App Messaging.

## Setup

### Add the CloudInAppMessaging SDK to your project

1. To add CloudInAppMessaging refer [Installation](#installation) section.
2. Add iCloud capability in Xcode App target's settings in the Signing & Capabilities tab.
3. Enable CloudKit service under iCloud section and add a new CloudKit container.
Input unique identifier (usually just Bundle Identifier) without "iCloud" prefix, for example `com.example.myapp`. 
Also, this can be done via [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list/cloudContainer).
4. Let Xcode fix the signing issues.
5. Configure CLMCloudInAppMessaging shared instance, typically in your app's `application:didFinishLaunchingWithOptions:` method:

Swift
```swift
CLMCloudInAppMessaging.setup(with: "iCloud.com.example.myapp")
```

Objective-C
```obj-c
[CLMCloudInAppMessaging setupWithCloudKitContainerIdentifier:@"iCloud.com.example.myapp"];
```

### Setup CloudInAppMessaging Admin App

In order to create and modify Alert Campaigns, you need to use either CloudKit Dashboard or the so-called Admin App. The latter allows to do it more convenient instead of dealing with database data.

1. To run Admin App, clone the repo, and run `pod install` from the Example directory first.
2. Setup target's App Bundle Identifier in `CloudMessagingAdminConfiguration.swift`
3. Similar to SDK setup, set the same CloudKit Container Identifier ("iCloud.com.example.myapp") for Admin App.
4. Setup CloudKit Container Identifier in `CloudMessagingAdminConfiguration.swift`
5. Run Admin App on your device or Simulator (notice that you can write to the database only from device which is signed into iCloud account).
6. Since CloudKit schema is usually defined by creating new records, run the Admin App and create a test Alert Campaign from the Debug menu.
7. After successful creation the app will try to fetch current Alert Campaigns and end up with an error: "Field 'recordName' is not marked querable". Unfortunately, it's not allowed to create indexes programmatically and it needs to be done via [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/):
- Select your CloudKit Container and navigate to the "Schema" settings.
- From the drop-down "Records Type" menu select "Indexes".
- For the AlertCampaign record add a new index with "QUERYABLE" type for the "recordName" field and press "Save Changes".
8. After creating the index pull to refresh the list to see newly created Alert Campaign.
9. Don't forget to deploy your development schema to production in CloudKit Dashboard before releasing your app.

## Installation

### CocoaPods

CloudInAppMessaging is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'CloudInAppMessaging'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application. To integrate CloudInAppMessaging into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "podkovyrin/CloudInAppMessaging"
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding CloudInAppMessaging as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/podkovyrin/CloudInAppMessaging.git", from: "0.1.0")
]
```

### Accio

1. Add the following to your `Package.swift`:

```swift
.package(url: "https://github.com/podkovyrin/CloudInAppMessaging.git", .upToNextMajor(from: "0.1.0")),
```

2. Next, add `CloudInAppMessaging` to your App targets dependencies like so:

```swift
.target(name: "App", dependencies: ["CloudInAppMessaging"]),
```

3. Then run `accio update`.

## Requirements

CloudInAppMessaging requires iOS 10 or later.

CloudInAppMessaging Admin App requires iOS 11 or later.

## FAQ

### Why not to use Firebase In-App Messaging?

- It is really heavy. Firebase In-App Messaging SDK comes with 14(!) dependencies and some of them are proprietary (closed-source).
```
$ pod install
Installing Firebase (6.11.0)
Installing FirebaseAnalytics (6.1.3) # 📦 closed-source
Installing FirebaseAnalyticsInterop (1.4.0) # 📦 closed-source
Installing FirebaseCore (6.3.2)
Installing FirebaseCoreDiagnostics (1.1.1)
Installing FirebaseCoreDiagnosticsInterop (1.0.0)
Installing FirebaseInAppMessaging (0.15.5)
Installing FirebaseInAppMessagingDisplay (0.15.5)
Installing FirebaseInstanceID (4.2.6)
Installing GoogleAppMeasurement (6.1.3) # 📦 closed-source
Installing GoogleDataTransport (3.0.1)
Installing GoogleDataTransportCCTSupport (1.2.1)
Installing GoogleUtilities (6.3.1)
Installing nanopb (0.3.9011)
```
- Firebase In-App Messaging uses its own UI for alerts which is a bit "androidy", though it can be overridden to use UIAlertController or any of you custom controllers.
- One more third party service you have to trust your data and your user's data.

As for the rest, they have deep integration with Firebase Analytics which is great if you already using it.

## Author

Andrew Podkovyrin, podkovyrin@gmail.com

## License

CloudInAppMessaging is available under the MIT license. See the LICENSE file for more info.
