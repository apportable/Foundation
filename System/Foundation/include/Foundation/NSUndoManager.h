#import <Foundation/NSObject.h>
#import <stdint.h>

@class NSArray, NSString;

enum {
    NSUndoCloseGroupingRunLoopOrdering        = 350000
};

FOUNDATION_EXPORT NSString * const NSUndoManagerGroupIsDiscardableKey;
FOUNDATION_EXPORT NSString * const NSUndoManagerCheckpointNotification;
FOUNDATION_EXPORT NSString * const NSUndoManagerWillUndoChangeNotification;
FOUNDATION_EXPORT NSString * const NSUndoManagerWillRedoChangeNotification;
FOUNDATION_EXPORT NSString * const NSUndoManagerDidUndoChangeNotification;
FOUNDATION_EXPORT NSString * const NSUndoManagerDidRedoChangeNotification;
FOUNDATION_EXPORT NSString * const NSUndoManagerDidOpenUndoGroupNotification;
FOUNDATION_EXPORT NSString * const NSUndoManagerWillCloseUndoGroupNotification;
FOUNDATION_EXPORT NSString * const NSUndoManagerDidCloseUndoGroupNotification;

@interface NSUndoManager : NSObject

- (void)beginUndoGrouping;
- (void)endUndoGrouping;
- (NSInteger)groupingLevel;
- (void)disableUndoRegistration;
- (void)enableUndoRegistration;
- (BOOL)isUndoRegistrationEnabled;
- (BOOL)groupsByEvent;
- (void)setGroupsByEvent:(BOOL)groupsByEvent;
- (void)setLevelsOfUndo:(NSUInteger)levels;
- (NSUInteger)levelsOfUndo;
- (void)setRunLoopModes:(NSArray *)runLoopModes;
- (NSArray *)runLoopModes;
- (void)undo;
- (void)redo;
- (void)undoNestedGroup;
- (BOOL)canUndo;
- (BOOL)canRedo;
- (BOOL)isUndoing;
- (BOOL)isRedoing;
- (void)removeAllActions;
- (void)removeAllActionsWithTarget:(id)target;
- (void)registerUndoWithTarget:(id)target selector:(SEL)selector object:(id)anObject;
- (id)prepareWithInvocationTarget:(id)target;
- (void)setActionIsDiscardable:(BOOL)discardable;
- (BOOL)undoActionIsDiscardable;
- (BOOL)redoActionIsDiscardable;
- (NSString *)undoActionName;
- (NSString *)redoActionName;
- (void)setActionName:(NSString *)actionName;
- (NSString *)undoMenuItemTitle;
- (NSString *)redoMenuItemTitle;
- (NSString *)undoMenuTitleForUndoActionName:(NSString *)actionName;
- (NSString *)redoMenuTitleForUndoActionName:(NSString *)actionName;

@end
