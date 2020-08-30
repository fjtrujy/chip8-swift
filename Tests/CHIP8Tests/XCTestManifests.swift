import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CHIP8MachineTests.allTests),
    ]
}
#endif
