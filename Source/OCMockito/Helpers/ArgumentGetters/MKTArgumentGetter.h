//  OCMockito by Jon Reid, https://qualitycoding.org/
//  Copyright 2017 Jonathan M. Reid. See LICENSE.txt

@import Foundation;


NS_ASSUME_NONNULL_BEGIN

/*!
 * @abstract Chain-of-responsibility for converting NSInvocation argument to object.
 */
@interface MKTArgumentGetter : NSObject

/*!
 * @abstract Initializes a newly allocated argument getter.
 * @param handlerType Argument type managed by this getter. Assign with \@encode compiler directive.
 * @param successor Successor in chain to handle argument type.
 */
- (instancetype)initWithType:(char const *)handlerType successor:(nullable MKTArgumentGetter *)successor NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/*!
 * @abstract Retrieve designated argument of specified type from NSInvocation, or pass to successor.
 */
- (id)retrieveArgumentAtIndex:(NSInteger)idx ofType:(char const *)type onInvocation:(NSInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
