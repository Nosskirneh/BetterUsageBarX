#import <UIKit/UIStatusBar.h>

BOOL shouldProduceReturnEvent = NO;

%hook UIStatusBar

- (UIStatusBar *)initWithFrame:(CGRect)frame {
    UIStatusBar *statusBar = %orig;
    [statusBar _setOverrideHeight:20];
    return statusBar;
}

- (void)_setOverrideHeight:(CGFloat)height {
    %orig(20);
}

- (void)setFrame:(CGRect)frame {
    if (frame.size.height == 40) {
        frame.size.height = 20;
    }
    %orig(frame);
}

// Redirect touches
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger numTaps = [[touches anyObject] tapCount];
    if (numTaps == 0) {
        // Hold
        shouldProduceReturnEvent = YES;
        MSHookIvar<unsigned int>([touches anyObject], "_tapCount")++;
        return %orig(touches, event);
    } else if (numTaps == 1) {
        // Single press
        shouldProduceReturnEvent = NO;
    }
    %orig;
}

- (BOOL)_touchShouldProduceReturnEvent {
    return shouldProduceReturnEvent;
}

%end
