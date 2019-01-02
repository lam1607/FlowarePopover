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

The default initialization of FLOPopover type is **`FLOWindowPopover`**

`Example`:
```
  popover = [[FLOPopover alloc] initWithContentViewController:self.dataViewController];
```


### Properties

- **contentView (readonly)** : The initialized content view in the init.
- **contentViewController (readonly)** : The initialized content view controller in the init.
- **type (readonly)** : Type of popover.
- **frame (readonly)** : Frame of popover.
- **shown (getter = isShown) (readonly)** : Check whether the popover is shown or not.
- **alwaysOnTop** : Make the popover always on top. If there is more than one popover is set as top, only the last one is top most
- **shouldShowArrow** : Show arrow at popover (**only available when displaying popover at sender view**)
- **animated** : Show popover with animation
- **animatedForwarding** : Animation with forwarding direction
- **shouldChangeSizeWhenApplicationResizes** : Change the popover size relatively the size of application window
- **closesWhenPopoverResignsKey** : Close the popover automatically when resigned
- **closesWhenApplicationBecomesInactive** : Close the popover automatically when the application becomes inactive
- **closesWhenApplicationResizes** : Close the popover automatically when the application resizes
- **closesAfterTimeInterval** : Close the popover automatically after some time intervals
- **isMovable** : Make the popover draggable
- **isDetachable** : Make the popover draggable and detachable
- **canBecomeKey** : Make the popover as key window (only available for **`FLOWindowPopover`**)
- **tag** : Set the tag for popover if needed

### Display

**`Showing`**

The popover is displayed with follwing methods:

- Display the popover at selected view **`positioningView`** with frame as selected view bounds **`rect`**. It means that the popover will stick to selected view.
  ```
    - (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType;
  ```

- Display the popover relatively to the selected view **`positioningView`** by given frame **`rect`**.
  ```
    - (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect;
  ```

- Display the popover relatively to the selected view **`positioningView`** by given frame **`rect`** at specific relative position **`relativePositionType`** to **`positioningView`**.
  ```
    - (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect relativePositionType:(FLOPopoverRelativePositionType)relativePositionType;
  ```

- Display the popover relatively to the selected view **`positioningView`** by given frame **`rect`**. **`sender`** is the view that fires an event to display the popover. It means that when we click on **`sender`** but we want to display the popover relatively to **`positioningView`**.
  ```
    - (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect sender:(NSView *)sender;
  ```

- Display the popover relatively to the selected view **`positioningView`** by given frame **`rect`** at specific relative position **`relativePositionType`** to **`positioningView`**. **`sender`** is the view that fires an event to display the popover. It means that when we click on **`sender`** but we want to display the popover relatively to **`positioningView`**.
  ```
    - (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect sender:(NSView *)sender relativePositionType:(FLOPopoverRelativePositionType)relativePositionType;
  ```

`Note`: **`rect`** MUST be a value on screen rect (MUST convert to screen rect by **`[convertRectToScreen:]`** method). Therefore, you must convert the given frame to screen frame before displaying.

All **`[showRelativeToView:withRect:]`**, **`[showRelativeToView:withRect:relativePositionType:]`**, **`[showRelativeToView:withRect:sender:]`** methods perform the **`[showRelativeToView:withRect:sender:relativePositionType:]`** method.

The **`sender`** is required. If you use both **`[showRelativeToView:withRect:]`**, **`[showRelativeToView:withRect:relativePositionType:]`** methods, it means that **`sender`** and **`positioningView`** are the same.

Popover needs to know about the **`sender`** sent the displaying event for preventing display issue from **`closesWhenPopoverResignsKey`**. When you set **`closesWhenPopoverResignsKey`** to **`YES`** and click to the **`sender`** again.

The relative position **`FLOPopoverRelativePositionType`** has the following types (the way that popover should display relatively to **`positioningView`**):
- **FLOPopoverRelativePositionAutomatic** : It means that relative position (anchor view constraints) will be calculated automatically based on the given frame
- **FLOPopoverRelativePositionTopLeading**
- **FLOPopoverRelativePositionTopTrailing**
- **FLOPopoverRelativePositionBottomLeading**
- **FLOPopoverRelativePositionBottomTrailing**

For more detail about **`[showRelativeToView:withRect:]`**, **`[showRelativeToView:withRect:relativePositionType:]`**, **`[showRelativeToView:withRect:sender:]`**, and **`[showRelativeToView:withRect:sender:relativePositionType:]`** methods and **`FLOPopoverRelativePositionType`**, please take a look at and try sample in github repository.

`Examples`:
- Sticking rect: Display the popover relative to the rect of positioning view
  ```
    [popover showRelativeToRect:[sender bounds] ofView:sender edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
  ```
- Given rect: Dipslay the popover at the given rect with selected view.
  ```
    NSRect positioningRect = [sender.window convertRectToScreen:NSMakeRect(100.0, 200.0, 0.0, 0.0)];

    [popover showRelativeToView:sender withRect:positioningRect];
  ```
- Given rect: Dipslay the popover at the given rect with selected view at specific relative position.
  ```
    // frame here is screen rect
    NSRect frame = [self calculateMessageBoxFrame];

    [popover showRelativeToView:self.view.window.contentView withRect:frame relativePositionType:FLOPopoverRelativePositionBottomTrailing];
  ```
- Given rect: Dipslay the popover relatively to positioningView at the given rect with sender.
  ```
    NSRect viewRect = [self.view.window convertRectToScreen:[self.view convertRect:self.view.bounds toView:self.view.window.contentView]];
    NSRect popoverRect = sortSelectionController.view.frame;
    popoverRect.origin.x = viewRect.origin.x + viewRect.size.width + 2;
    popoverRect.origin.y = viewRect.origin.y + 1;

    [popover showRelativeToView:self.view withRect:popoverRect sender:selectedCell];
  ```

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

After setting the property **`animated`** is **`YES`**, we should use the following methods to apply the animation when displaying.

```
  - (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType;
```
or

```
  - (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType animatedInApplicationRect:(BOOL)animatedInApplicationRect;
```

**`animatedInApplicationRect`** means that the animation is only performed inside the application frame. Value of **`animatedInApplicationRect`** is set as **`NO`** by default.

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

`Example`:
```
  [popover setAnimationBehaviour:FLOPopoverAnimationBehaviorTransition type:FLOPopoverAnimationRightToLeft];
```

If we don't call the method **`[setAnimationBehaviour:type:]`**, default animation behaviour and type will be performed by default.

### Other utilities

When you display popover, if you want you change size, position of the view or view controller that displayed on the popover. You can use the following methods.

- Update content size for view or view controller in popover.
  ```
    - (void)setPopoverContentViewSize:(NSSize)newSize;
  ```

- Update position of popover.
  ```
    - (void)setPopoverPositioningRect:(NSRect)rect;
  ```

- Update content size for view or view controller in popover and position of popover.
  ```
    - (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect;
  ```

When you want to change the view or view controller that displayed on popover, you can use below methods.

  - **NSView**
  ```
    - (void)setPopoverContentView:(NSView *)contentView;
  ```

  - **NSViewController**
  ```
    - (void)setPopoverContentViewController:(NSViewController *)contentViewController;
  ```

When you display the popover with **`FLOWindowPopover`** type and want to change the level for window popover, you can use this methods.

```
  - (void)setPopoverLevel:(NSWindowLevel)level;
```

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

For more detail about usages, please take a deep look at sample in github repository.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Floware macOS team**

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/lam1607/FlowarePopover/blob/master/LICENSE) file for details
