import XCTest

import CHIP8Tests

var tests = [XCTestCaseEntry]()
tests += CHIP8Tests.allTests()
XCTMain(tests)
