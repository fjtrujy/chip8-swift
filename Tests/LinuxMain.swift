import XCTest

import CHIP8Tests

var tests = [XCTestCaseEntry]()
tests += CHIP8MachineTests.allTests()
XCTMain(tests)
