import XCTest
@testable import CHIP8

final class CHIP8Tests: XCTestCase {
    let chip8 = CHIP8()
    
    func testMemSize() {
        XCTAssert(chip8.mem.count == 4096, "The memory size must be 64 and it is \(chip8.mem.count)")
        XCTAssert((chip8.mem as Any) is [UInt8], "The memory array is not UInt8")
    }
    
    func testProgramCounter() {
        XCTAssert((chip8.pc as Any) is UInt16, "The program counter is not UInt16")
    }
    
    func testStackSize() {
        XCTAssert(chip8.stack.count == 16, "The stack size must be 16 and it is \(chip8.stack.count)")
        XCTAssert((chip8.stack as Any) is [UInt16], "The memory array is not UInt16")
    }
    
    func testStackPointer() {
        XCTAssert((chip8.sp as Any) is UInt16, "The program counter is not UInt16")
    }
    
    func testRegisterSize() {
        XCTAssert(chip8.v.count == 16, "The register size must be 64 and it is \(chip8.v.count)")
        XCTAssert((chip8.v as Any) is [UInt8], "The memory array is not UInt8")
    }
    
    func testIntructionRegister() {
        XCTAssert((chip8.i as Any) is UInt16, "The instruction register is not UInt16")
    }
    
    func testDelayTimer() {
        XCTAssert((chip8.dt as Any) is UInt8, "The instruction register is not UInt8")
    }
    
    func testSoundTimer() {
        XCTAssert((chip8.st as Any) is UInt8, "The instruction register is not UInt8")
    }
}
