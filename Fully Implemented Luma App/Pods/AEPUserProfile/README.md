# AEPUserProfile

[![Cocoapods](https://img.shields.io/cocoapods/v/AEPUserProfile.svg?color=orange&label=AEPUserProfile&logo=apple&logoColor=white)](https://cocoapods.org/pods/AEPUserProfile)

[![SPM](https://img.shields.io/badge/SPM-Supported-orange.svg?logo=apple&logoColor=white)](https://swift.org/package-manager/)
[![Actions Status](https://github.com/adobe/aepsdk-userprofile-ios/workflows/Build/badge.svg)](https://github.com/adobe/aepsdk-userprofile-ios/actions)
[![Code Coverage](https://img.shields.io/codecov/c/github/adobe/aepsdk-userprofile-ios/dev.svg?logo=codecov)](https://codecov.io/gh/adobe/aepsdk-userprofile-ios/branch/dev)

## About this project

The Adobe Experience Platform UserProfile Mobile Extension is an extension for the [Adobe Experience Platform SDK](https://github.com/Adobe-Marketing-Cloud/acp-sdks).

To learn more about this extension, read [Adobe Experience Platform Profile Mobile Extension](https://aep-sdks.gitbook.io/docs/v/AEP-Edge-Docs/).

## Requirements
- Xcode 11.0 (or newer)
- Swift 5.1 (or newer)

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile

use_frameworks!

# for app development, include all the following pods
target 'YOUR_TARGET_NAME' do
    pod 'AEPCore'
end

# for extension development, include AEPCore and its dependencies
target 'YOUR_TARGET_NAME' do
    pod 'AEPCore'
end
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add the AEPUserProfile Package to your application, from the Xcode menu select:

`File > Swift Packages > Add Package Dependency...`

Enter the URL for the AEPUserProfile package repository: `https://github.com/adobe/aepsdk-userprofile-ios.git`.

When prompted, make sure you change the branch to `main`. 

Alternatively, if your project has a `Package.swift` file, you can add AEPUserProfile directly to your dependencies:

```
dependencies: [
    .package(url: "https://github.com/adobe/aepsdk-userprofile-ios.git", .branch("main")),
],
targets: [
    .target(name: "YourTarget",
            dependencies: ["AEPUserProfile"],
	    path: "your/path")
]
```

### Binaries

To generate an `AEPUserProfile.xcframework`, run the following command:

```
make archive
```

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

## Contributing

Contributions are welcomed! Read the [Contributing Guide](./.github/CONTRIBUTING.md) for more information.

## Licensing

This project is licensed under the Apache V2 License. See [LICENSE](LICENSE) for more information.
