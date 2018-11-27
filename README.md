# FlowarePopover

FlowarePopover as named, is the custom popover based on RBLPopover, NSPopover and other libraries to display an NSViewController or NSView on an NSWindow or NSView popup.

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

To integrate FlowarePopover into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :osx, '10.11'

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

- **`FLOViewPopover`**
- **`FLOWindowPopover`**

### Initialize

- **NSView**
  - **Default**
  ```
    - (id)initWithContentView:(NSView *)contentView;
  ```

  - **Detail**
  ```
    - (id)initWithContentView:(NSView *)contentView type:(FLOPopoverType)type;
  ```

- **NSViewController**
  - **Default**
  ```
    - (id)initWithContentViewController:(NSViewController *)contentViewController;
  ```

  - **Detail**
  ```
    - (id)initWithContentViewController:(NSViewController *)contentViewController type:(FLOPopoverType)type;
  ```

The default initialization of FLOPopover type is **`FLOViewPopover`**

`Examples`:
```
  popover = [[FLOPopover alloc] initWithContentViewController:self.dataViewController type:FLOWindowPopover];
```


### Properties

- **contentView** : The initialized content view in the init.
- **contentViewController** : The initialized content view controller in the init.
- **type** : Type of popover.

- **shown (getter = isShown)** : Check whether the popover is shown or not.
- **alwaysOnTop** : Make the popover always on top. If there is more than one popover is set as top, only the last one is top most
- **shouldShowArrow** : Show arrow at popover
- **animated** : Show popover with animation
- **animatedForwarding** : Animation with forwarding direction
- **shouldChangeSizeWhenApplicationResizes** : Change the popover size relatively the size of application window
- **closesWhenPopoverResignsKey** : Close the popover automatically when resigned
- **closesWhenApplicationBecomesInactive** : Close the popover automatically when the application becomes inactive
- **closesWhenApplicationResizes** : Close the popover automatically when the application resizes
- **closesAfterTimeInterval** : Close the popover automatically after some time intervals
- **isMovable** : Make the popover draggable
- **isDetachable** : Make the popover draggable and detachable

### Display

**`Showing`**

The popover is displayed with follwing methods:

- Display the popover at selected view **`positioningView`** with frame as selected view bounds **`rect`**. It means that the popover will stick to selected view.
  ```
    - (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType;
  ```

- Display the popover at given frame **`rect`** relatively to the selected view **`positioningView`** with anchorType **`FLOPopoverAnchorTopPositiveLeadingPositive`** by default
  ```
    - (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect;
  ```

- Display the popover at given frame **`rect`** relatively to the selected view **`positioningView`** with specific anchor type of the anchor view with the **`positioningView`** as ((top, leading) | (top, trailing), (bottom, leading), (bottom, trailing))
  ```
    - (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect anchorType:(FLOPopoverAnchorType)anchorType;
  ```

`Examples`:
- Stick
  ```
    [popover showRelativeToRect:[sender bounds] ofView:sender edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
  ```
- Given frame
  ```
    NSRect positioningRect = NSMakeRect(100.0f, 200.0f, 0.0f, 0.0f);

    [popover showRelativeToView:sender withRect:positioningRect];
  ```
- Given frame with anchor type
  ```
    NSRect positioningRect = NSMakeRect(100.0f, 200.0f, 0.0f, 0.0f);

    [popover showRelativeToView:sender withRect:positioningRect anchorType:FLOPopoverAnchorTopPositiveLeadingPositive];
  ```

The anchor type **`FLOPopoverAnchorType`** has the following types (anchor view that is the view the popover should display at):
- **FLOPopoverAnchorTopPositiveLeadingPositive** : The anchor view has positive top and positive leading contraints to the **positioningView**
- **FLOPopoverAnchorTopPositiveLeadingNegative** : The anchor view has positive top and negative leading contraints to the **positioningView**
- **FLOPopoverAnchorTopNegativeLeadingPositive** : The anchor view has negative top and positive leading contraints to the **positioningView**
- **FLOPopoverAnchorTopNegativeLeadingNegative** : The anchor view has negative top and negative leading contraints to the **positioningView**

- **FLOPopoverAnchorTopPositiveTrailingPositive** : The anchor view has positive top and positive trailing contraints to the **positioningView**
- **FLOPopoverAnchorTopPositiveTrailingNegative** : The anchor view has positive top and negative trailing contraints to the **positioningView**
- **FLOPopoverAnchorTopNegativeTrailingPositive** : The anchor view has negative top and positive trailing contraints to the **positioningView**
- **FLOPopoverAnchorTopNegativeTrailingNegative** : The anchor view has negative top and negative trailing contraints to the **positioningView**

- **FLOPopoverAnchorBottomPositiveLeadingPositive** : The anchor view has positive bottom and positive leading contraints to the **positioningView**
- **FLOPopoverAnchorBottomPositiveLeadingNegative** : The anchor view has positive bottom and negative leading contraints to the **positioningView**
- **FLOPopoverAnchorBottomNegativeLeadingPositive** : The anchor view has negative bottom and positive leading contraints to the **positioningView**
- **FLOPopoverAnchorBottomNegativeLeadingNegative** : The anchor view has negative bottom and negative leading contraints to the **positioningView**

- **FLOPopoverAnchorBottomPositiveTrailingPositive** : The anchor view has positive bottom and positive trailing contraints to the **positioningView**
- **FLOPopoverAnchorBottomPositiveTrailingNegative** : The anchor view has positive bottom and negative trailing contraints to the **positioningView**
- **FLOPopoverAnchorBottomNegativeTrailingPositive** : The anchor view has negative bottom and positive trailing contraints to the **positioningView**
- **FLOPopoverAnchorBottomNegativeTrailingNegative** : The anchor view has negative bottom and negative trailing contraints to the **positioningView**

For more detail about **`[showRelativeToView:withRect:]`**, and **`[showRelativeToView:withRect:anchorType:]`** methods, please take a look at sample in github repository.

**`Closing`**
```
  - (void)close;
```

`Example`:
```
    if ([popover isShown]) {
        [popover close];
    }
```

### Popover edge type

When showing the sticking popover, you must provide the edge type. Edge type of popover is defined as **`NS_ENUM`** **`FLOPopoverEdgeType`** with values:

- **FLOPopoverEdgeTypeAboveLeftEdge**: Popover will be displayed ABOVE of the selected view, with the LEFT EDGE of popover stays at the LEFT EDGE of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeAboveRightEdge**: Popover will be displayed ABOVE of the selected view, with the RIGHT EDGE of popover stays at the RIGHT EDGE of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeBelowLeftEdge**: Popover will be displayed BELOW of the selected view, with the LEFT EDGE of popover stays at the LEFT EDGE of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeBelowRightEdge**: Popover will be displayed BELOW of the selected view, with the RIGHT EDGE of popover stays at the RIGHT EDGE of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeBackwardBottomEdge**: Popover will be displayed at BACKWARD f the selected view, with the BOTTOM EDGE of popover stays at the BOTTOM EDGE of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeBackwardTopEdge**: Popover will be displayed at BACKWARD of the selected view, with the TOP EDGE of popover stays at the TOP EDGE of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeForwardBottomEdge**: Popover will be displayed at FORWARD of the selected view, with the BOTTOM EDGE of popover stays at the BOTTOM EDGE of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeForwardTopEdge**: Popover will be displayed at FORWARD of the selected view, with the TOP EDGE of popover stays at the TOP EDGE of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeAboveCenter**: Popover will be displayed ABOVE of the selected view, with the CENTER HORIZONTAL POINT of popover stays at the CENTER HORIZONTAL POINT of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeBelowCenter**: Popover will be displayed BELOW of the selected view, with the CENTER HORIZONTAL POINT of popover stays at the CENTER HORIZONTAL POINT of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeBackwardCenter**: Popover will be displayed BACKWARD of the selected view, with the CENTER VERTICAL POINT of popover stays at the CENTER VERTICAL POINT of positioning rect (rect of selected view)

- **FLOPopoverEdgeTypeForwardCenter**: Popover will be displayed FORWARD of the selected view, with the CENTER VERTICAL POINT of popover stays at the CENTER VERTICAL POINT of positioning rect (rect of selected view)


### Animation

After setting the property **`animated`** is **`YES`**, we should use this method to apply the animation when displaying.

```
  - (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType;
```

The **`FLOPopoverAnimationBehaviour`** that is animation behaviour has following types:
- **`FLOPopoverAnimationBehaviorDefault`** (popover will display with slightly default fade in/out animation)
- **`FLOPopoverAnimationBehaviorTransform`**
- **`FLOPopoverAnimationBehaviorTransition`**

And animation type **`FLOPopoverAnimationType`** of **`FLOPopoverAnimationBehaviour`** has types as follow:
- `Default:`
  - **`FLOPopoverAnimationDefault`**

- `Transform:`
  - **`FLOPopoverAnimationScale`**
  - **`FLOPopoverAnimationRotate`**
  - **`FLOPopoverAnimationFlip`**

- `Transition:`
  - **`FLOPopoverAnimationLeftToRight`**
  - **`FLOPopoverAnimationRightToLeft`**
  - **`FLOPopoverAnimationTopToBottom`**
  - **`FLOPopoverAnimationBottomToTop`**
  - **`FLOPopoverAnimationFromMiddle`**

`Example`:
```
  [popover setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft];
```

If we don't call the method **`[setAnimationBehaviour:type:]`**, default animation behaviour and type will be performed by default.


### Delegation

The popover have following delegations with protocol `FLOPopoverDelegate`:

```
  - (void)floPopoverWillShow:(FLOPopover *)popover;
  - (void)floPopoverDidShow:(FLOPopover *)popover;
  - (void)floPopoverWillClose:(FLOPopover *)popover;
  - (void)floPopoverDidClose:(FLOPopover *)popover;
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
