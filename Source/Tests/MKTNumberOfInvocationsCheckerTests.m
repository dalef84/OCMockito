//  OCMockito by Jon Reid, http://qualitycoding.org/about/
//  Copyright 2015 Jonathan M. Reid. See LICENSE.txt

#import "MKTNumberOfInvocationsChecker.h"

#import "MKTInvocation.h"

#import "MockInvocationsFinder.h"
#import "MKTInvocationBuilder.h"
#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>


@interface MKTNumberOfInvocationsCheckerTests : XCTestCase
@end

@implementation MKTNumberOfInvocationsCheckerTests
{
    MockInvocationsFinder *mockInvocationsFinder;
    MKTNumberOfInvocationsChecker *sut;
}

- (void)setUp
{
    [super setUp];
    mockInvocationsFinder = [[MockInvocationsFinder alloc] init];
    sut = [[MKTNumberOfInvocationsChecker alloc] init];
    sut.invocationsFinder = mockInvocationsFinder;
}

- (void)tearDown
{
    sut = nil;
    [super tearDown];
}

- (void)testInvocationsFinder_Default
{
    MKTNumberOfInvocationsChecker *defaultSUT = [[MKTNumberOfInvocationsChecker alloc] init];

    MKTInvocationsFinder *finder = defaultSUT.invocationsFinder;

    assertThat(finder, isA([MKTInvocationsFinder class]));
}

- (void)testCheckInvocations_ShouldAskInvocationsFinderToFindMatchingInvocationsInList
{
    NSArray *invocations = @[ [[MKTInvocationBuilder invocationBuilder] buildMKTInvocation] ];
    MKTInvocationMatcher *wanted = [[MKTInvocationBuilder invocationBuilder] buildInvocationMatcher];

    [sut checkInvocations:invocations wanted:wanted wantedCount:1];

    assertThat(mockInvocationsFinder.capturedInvocations, is(sameInstance(invocations)));
    assertThat(mockInvocationsFinder.capturedWanted, is(sameInstance(wanted)));
}

- (void)testCheckInvocations_WithMatchingCount_ShouldReturnNil
{
    mockInvocationsFinder.stubbedCount = 100;

    NSString *description = [sut checkInvocations:nil wanted:nil wantedCount:100];

    assertThat(description, is(nilValue()));
}

- (void)testCheckInvocations_ShouldReportTooLittleActual
{
    mockInvocationsFinder.stubbedCount = 1;

    NSString *description = [sut checkInvocations:nil wanted:nil wantedCount:100];

    assertThat(description, containsSubstring(@"Wanted 100 times but was called 1 time."));
}

- (void)testCheckInvocations_ShouldReportTooManyActual
{
    mockInvocationsFinder.stubbedCount = 100;

    NSString *description = [sut checkInvocations:nil wanted:nil wantedCount:1];

    assertThat(description, containsSubstring(@"Wanted 1 time but was called 100 times."));
}

- (NSArray *)generateCallStack:(NSArray *)callStack
{
    NSArray *callStackPreamble = @[
            @"  3   ExampleTests                        0x0000000118446bee -[MKTBaseMockObject forwardInvocation:] + 91",
            @"  4   CoreFoundation                      0x000000010e9f9d07 ___forwarding___ + 487",
            @"  5   CoreFoundation                      0x000000010e9f9a98 _CF_forwarding_prep_0 + 120" ];
    return [callStackPreamble arrayByAddingObjectsFromArray:callStack];
}

- (void)testCheckInvocations_WithTooLittleActual_ShouldIncludeFilteredStackTraceOfLastInvocation
{
    mockInvocationsFinder.stubbedCount = 2;
    mockInvocationsFinder.stubbedCallStackOfLastInvocation = [self generateCallStack:@[
            @"  6   ExampleTests                        0x0000000118430edc CALLER",
            @"  7   ExampleTests                        0x0000000118430edc PREVIOUS",
    ]];

    NSString *description = [sut checkInvocations:nil wanted:nil wantedCount:100];

    assertThat(description, containsSubstring(
            @"Last invocation:\n"
                    "ExampleTests CALLER\n"
                    "ExampleTests PREVIOUS"));
}

- (void)testCheckInvocations_WithTooManyActual_ShouldAskInvocationsFinderForCallStackOfFirstUndesiredInvocation
{
    mockInvocationsFinder.stubbedCount = 2;

    [sut checkInvocations:nil wanted:nil wantedCount:1];

    assertThat(@(mockInvocationsFinder.capturedInvocationIndex), is(@1));
}

- (void)testCheckInvocations_WithTooManyActual_ShouldIncludeFilteredStackTraceOfUndesiredInvocation
{
    mockInvocationsFinder.stubbedCount = 2;
    mockInvocationsFinder.stubbedCallStackOfInvocationAtIndex = [self generateCallStack:@[
            @"  6   ExampleTests                        0x0000000118430edc CALLER",
            @"  7   ExampleTests                        0x0000000118430edc PREVIOUS",
    ]];

    NSString *description = [sut checkInvocations:nil wanted:nil wantedCount:1];

    assertThat(description, containsSubstring(
            @"Undesired invocation:\n"
                    "ExampleTests CALLER\n"
                    "ExampleTests PREVIOUS"));
}

- (void)testCheckInvocations_ShouldReportNeverWanted
{
    mockInvocationsFinder.stubbedCount = 100;

    NSString *description = [sut checkInvocations:nil wanted:nil wantedCount:0];

    assertThat(description, containsSubstring(@"Never wanted but was called 100 times."));
}

- (void)testCheckInvocations_WithCallsWhereNoneWereExpected_ShouldAskInvocationsFinderForCallStackOfFirstUndesiredInvocation
{
    mockInvocationsFinder.stubbedCount = 100;

    [sut checkInvocations:nil wanted:nil wantedCount:0];

    assertThat(@(mockInvocationsFinder.capturedInvocationIndex), is(@0));
}

- (void)testCheckInvocations_WithCallsWhereNoneWereExpected_ShouldIncludeFilteredStackTraceOfUndesiredInvocation
{
    mockInvocationsFinder.stubbedCount = 2;
    mockInvocationsFinder.stubbedCallStackOfInvocationAtIndex = [self generateCallStack:@[
            @"  6   ExampleTests                        0x0000000118430edc CALLER",
            @"  7   ExampleTests                        0x0000000118430edc PREVIOUS",
    ]];

    NSString *description = [sut checkInvocations:nil wanted:nil wantedCount:0];

    assertThat(description, containsSubstring(
            @"Undesired invocation:\n"
                    "ExampleTests CALLER\n"
                    "ExampleTests PREVIOUS"));
}

@end