# Adobe Experience Platform - Assurance extension for iOS

## About this project

Assurance/Project Griffon is a new, innovative beta product from [Adobe Experience Cloud](https://business.adobe.com/) to help you inspect, proof, simulate, and validate how you collect data or serve experiences in your mobile app. For more information on what Project Griffon can do for you, see [here](https://aep-sdks.gitbook.io/docs/beta/project-griffon#what-can-project-griffon-do-for-you).

## Requirements
- Xcode 12 or newer
- Swift 5.1 or newer

## Installation

### Binaries

To generate an `AEPAssurance.xcframework`, run the following command:

```ruby
$ make archive
```

This generates the xcframework under the `build` folder. Drag and drop all the `.xcframeworks` to your app target in Xcode.

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'AEPAssurance', '~> 3.0.0'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```ruby
$ pod install
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add the AEPAssurance Package to your application, from the Xcode menu select:

`File > Swift Packages > Add Package Dependency...`

Enter the URL for the AEPAssurance package repository: `https://github.com/adobe/aepsdk-assurance-ios.git`.

When prompted, make sure you change the branch to `main`. (Once the repo is public, we will reference specific tags/versions instead of a branch)

Alternatively, if your project has a `Package.swift` file, you can add AEPAssurance directly to your dependencies:

```
dependencies: [
    .package(url: "https://github.com/adobe/aepsdk-assurance-ios.git", .upToNextMajor(from: "3.0.0"))
],
targets: [
    .target(name: "YourTarget",
            dependencies: ["AEPAssurance"],
            path: "your/path")
]
```

## TestApps
Two sample apps are provided (one each for Swift and Objective-c) which demonstrate setting up and getting started with Assurance extension. Their targets are in `AEPAssurance.xcodeproj`, runnable in `AEPAssurance.xcworkspace`. Sample app source code can be found in the `TestApp` and `TestAppObjC` directories.

## Development

The first time you clone or download the project, you should run the following from the root directory to setup the environment:

~~~
make pod-install
~~~

Subsequently, you can make sure your environment is updated by running the following:

~~~
make pod-update
~~~

#### Open the Xcode workspace
Open the workspace in Xcode by running the following command from the root directory of the repository:

~~~
make open
~~~

#### Command line integration

You can run all the test suites from command line:

~~~
make test
~~~

## Related Projects
| Project                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [AEPCore Extensions](https://github.com/adobe/aepsdk-core-ios) | The AEPCore and AEPServices represent the foundation of the Adobe Experience Platform SDK. |
| [AEP SDK Sample App for iOS](https://github.com/adobe/aepsdk-sample-app-ios) | Contains iOS sample apps for the AEP SDK. Apps are provided for both Objective-C and Swift implementations. |


## Documentation
Additional documentation for configuration and SDK usage can be found under the [Documentation](Documentation/README.md) directory.

## Contributing
Contributions are welcomed! Read the [Contributing Guide](./.github/CONTRIBUTING.md) for more information.
We look forward to working with you!

## Licensing
This project is licensed under the Apache V2 License. See [LICENSE](LICENSE) for more information.
