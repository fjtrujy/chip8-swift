//
//  File.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 30/08/2020.
//

import XCTest
@testable import CHIP8

final class CHIP8Tests: XCTestCase {
    let chip8 = CHIP8()
    
    func testDummy() {
        
        chip8.loadROM()
//        chip8.loop()
        XCTAssert(true)
//        XCTAssert((chip8.mem as Any) is [UInt8], "The memory array is not UInt8")
    }
}

