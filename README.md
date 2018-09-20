# FlowarePopover

FlowarePopover as named, is the custom popover based on NSPopover and other libraries to display an NSViewController or NSView on a NSWindow or NSView popup.

## Requirements

- Objective-C
- macOS 10.11+
- XCode 8.3+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods
```

To integrate Alamofire into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :osx, '10.11'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/lam1607/FlowarePopover-Specs'

target '<Your Target Name>' do
  pod 'FlowarePopover'
end
```

Then, run the following command in `<Your Project Directory>`:

```bash
$ pod install
```

## Popover APIs

The popover has some main apis listed as follow:

### Types

Popover have two main types:

- FLOViewPopover
- FLOWindowPopover

### Initialize

- `NSView`
  - `Default`
  ```
  - (id)initWithContentView:(NSView *)contentView;
  ```
  
  - `Detail`
  ```
  - (id)initWithContentView:(NSView *)contentView popoverType:(FLOPopoverType)popoverType;
  ```

- `NSViewController`
  - `Default`
  ```
  - (id)initWithContentViewController:(NSViewController *)contentViewController;
  ```
  
  - `Detail`
  ```
  - (id)initWithContentViewController:(NSViewController *)contentViewController popoverType:(FLOPopoverType)popoverType;
  ```

The default initialization of FLOPopover type is `FLOViewPopover`

`Examples`:
  ```
  popover = [[FLOPopover alloc] initWithContentViewController:self.dataViewController popoverType:FLOWindowPopover];
  ```


### Properties

- **contentView** : `The initialized content view in the init.`
- **contentViewController** : `The initialized content view controller in the init.`
- **popupType** : `Type of popover.`

- **shown (getter = isShown)** : `Check whether the popover is shown or not.`
- **alwaysOnTop** : `Make the popover always on top. If there is more than one popover is set as top, only the last one is top most`
- **shouldShowArrow** : `Show arrow at popover`
- **animated** : `Show popover with animation`
- **closesWhenPopoverResignsKey** : `Close the popover automatically when resigned`
- **closesWhenApplicationBecomesInactive** : `Close the popover automatically when the application becomes inactive`
- **popoverMovable** : `Make the popover draggable`
- **popoverShouldDetach** : `Make the popover draggable and detachable (only works with` **`FLOWindowPopover`** `type`

### Display

**`Showing`**

  The popover is displayed with two methods:

  - `Display the popover at selected view `**`(positioningView)`**` with frame as selected view bounds` **`rect`**`. It means that the popover will stick to selected view.`
    ```
    - (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType;
    ```

  - `Display the popover at given frame `**`rect`**` relatively to the selected view` **`(positioningView)`**
    ```
    - (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect;
    ```

`Examples`:
  - `Stick`
    ```
    [popover showRelativeToRect:[sender bounds] ofView:sender edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
    ```
  - `Given frame`
    ```
    NSRect positioningRect = NSMakeRect(100.0f, 200.0f, 0.0f, 0.0f);
    
    [popover showRelativeToView:sender withRect:positioningRect];
    ```

**`Closing`**
  ```
  - (IBAction)closePopover:(FLOPopover *)sender;
  ```

`Examples`:
  ```
  if ([popover isShown]) {
      [popover closePopover:popover];
  }
  ```

### Popover edge type

When showing the sticking popover, you must provide the edge type. Edge type of popover is defined as **`NS_ENUM`**  **`FLOPopoverEdgeType`** with values:

- **FLOPopoverEdgeTypeAboveLeftEdge** : `Popover will be displayed ABOVE of the selected view, with the LEFT EDGE of popover stays at the LEFT EDGE of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeAboveRightEdge** : `Popover will be displayed ABOVE of the selected view, with the RIGHT EDGE of popover stays at the RIGHT EDGE of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeBelowLeftEdge** : `Popover will be displayed BELOW of the selected view, with the LEFT EDGE of popover stays at the LEFT EDGE of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeBelowRightEdge** : `Popover will be displayed BELOW of the selected view, with the RIGHT EDGE of popover stays at the RIGHT EDGE of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeBackwardBottomEdge** : `Popover will be displayed at BACKWARD f the selected view, with the BOTTOM EDGE of popover stays at the BOTTOM EDGE of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeBackwardTopEdge** : `Popover will be displayed at BACKWARD of the selected view, with the TOP EDGE of popover stays at the TOP EDGE of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeForwardBottomEdge** : `Popover will be displayed at FORWARD of the selected view, with the BOTTOM EDGE of popover stays at the BOTTOM EDGE of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeForwardTopEdge** : `Popover will be displayed at FORWARD of the selected view, with the TOP EDGE of popover stays at the TOP EDGE of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeAboveCenter** : `Popover will be displayed ABOVE of the selected view, with the CENTER HORIZONTAL POINT of popover stays at the CENTER HORIZONTAL POINT of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeBelowCenter** : `Popover will be displayed BELOW of the selected view, with the CENTER HORIZONTAL POINT of popover stays at the CENTER HORIZONTAL POINT of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeBackwardCenter** : `Popover will be displayed BACKWARD of the selected view, with the CENTER VERTICAL POINT of popover stays at the CENTER VERTICAL POINT of positioning rect (rect of selected view)`

- **FLOPopoverEdgeTypeForwardCenter** : `Popover will be displayed FORWARD of the selected view, with the CENTER VERTICAL POINT of popover stays at the CENTER VERTICAL POINT of positioning rect (rect of selected view)`


### Animation

After setting the property **`animated`** is **`YES`**, we must use this method to apply the animation when displaying.

```
- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationTransition)animationType;
```

- **`FLOPopoverAnimationBehaviour`**
  - **`FLOPopoverAnimationBehaviorNone`**
  - **`FLOPopoverAnimationBehaviorTransform`**
  - **`FLOPopoverAnimationBehaviorTransition`**

- **`FLOPopoverAnimationTransition`**
  - **`FLOPopoverAnimationLeftToRight`**
  - **`FLOPopoverAnimationRightToLeft`**
  - **`FLOPopoverAnimationTopToBottom`**
  - **`FLOPopoverAnimationBottomToTop`**
  - **`FLOPopoverAnimationFromMiddle`**

Currently only the **`FLOPopoverAnimationBehaviorTransition`** type is supported.

`Examples`:
  ```
  [popover setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft];
  ```


### Delegation

The popover have two delegations with protocol `FLOPopoverDelegate`:

```
- (void)popoverDidShow:(NSResponder *)popover;
- (void)popoverDidClose:(NSResponder *)popover;
```


## How to use

Select the target screen in your project, then add the following line:

```
#import <FlowarePopover/FLOPopover.h>
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Floware macOS team**

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/lam1607/FlowarePopover/blob/master/LICENSE) file for details
