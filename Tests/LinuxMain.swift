import XCTest

import CHIP8Tests

var tests = [XCTestCaseEntry]()
tests += CHIP8Tests.__allTests()

XCTMain(tests)
