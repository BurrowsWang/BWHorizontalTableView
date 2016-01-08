BWHorizontalTableView
=========
![Platform](https://img.shields.io/badge/platform-iOS-brightgreen.svg)
![Pod Version](https://img.shields.io/badge/pod-v1.0.1-brightgreen.svg)
![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

BWHorizontalTableView is an efficient horizontal table view based on Objective-c with same usage and interface as [UITableView](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/index.html).

How To Use
----------
API documentation is available at [CocoaDocs - BWHorizontalTableView](http://cocoadocs.org/docsets/BWHorizontalTableView/).

[Sample project](https://github.com/BurrowsWang/BWHorizontalTableView/archive/master.zip) can be found [here](https://github.com/BurrowsWang/BWHorizontalTableView/tree/master/Examples). If you know how to use `UITableView` in your iOS project, you already know how to use `BWHorizontalTableView`.

First of all, you should provide `dataSource` and `delegate` of the horizontal table view.

```objective-c
BWHorizontalTableView *tableView = [[BWHorizontalTableView alloc] init];
tableView.frame = rect;
tableView.dataSource = your-data-source;
tableView.delegate = your-delegate;
```

Your data source should conforms to `BWHorizontalTableViewDataSource` and implement the following methods:

```objective-c
- (NSInteger)numberOfSectionsInHorizontalTableView:(BWHorizontalTableView *)tableView;

- (NSInteger)horizontalTableView:(BWHorizontalTableView *)tableView
        numberOfColumnsInSection:(NSInteger)section;
        
- (BWHorizontalTableViewCell *)horizontalTableView:(BWHorizontalTableView *)tableView
                          cellForColumnAtIndexPath:(NSIndexPath *)indexPath;
```

Your delegate object should conforms to `BWHorizontalTableViewDelegate` and implement the methods defined in [protocol BWHorizontalTableViewDelegate](https://github.com/BurrowsWang/BWHorizontalTableView/blob/master/BWHorizontalTableView/BWHorizontalTableViewDelegate.h#L31) according to your needs.

```objective-c
- (CGFloat)horizontalTableView:(BWHorizontalTableView *)tableView
     widthForColumnAtIndexPath:(NSIndexPath *)indexPath;
     
- (void)horizontalTableView:(BWHorizontalTableView *)tableView
 didSelectColumnAtIndexPath:(NSIndexPath *)indexPath;
```

Installation
------------
#### Installation with CocoaPods (Recommend)

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the [Get Started](https://cocoapods.org/#get_started) section for more details.

```ruby
platform :ios, '7.0'

pod 'BWHorizontalTableView', '~>1.0.1'
```

### Installation with Carthage (iOS 8+)

[Carthage](https://github.com/Carthage/Carthage) is a lightweight dependency manager for Swift and Objective-C. It leverages CocoaTouch modules and is less invasive than CocoaPods.

To install with carthage, follow the instruction on [Carthage](https://github.com/Carthage/Carthage)

```ruby
github "BurrowsWang/BWHorizontalTableView"
```

#### Other Ways
- Copying all the files into your project
- Importing the project as a dynamic framework, PS: ADD FRAMEWORK TO `Embedded Binaries`
- Importing the project as a static library, PS: ADD `-ObjC` TO BUILD SETTING `Other Linker Flags`

License
-------------------
All source code is licensed under the [MIT License](https://github.com/BurrowsWang/BWHorizontalTableView/blob/master/LICENSE).
