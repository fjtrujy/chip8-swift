//
//  CHIP8Tests.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 30/08/2020.
//

import XCTest
@testable import CHIP8

final class CHIP8Tests: XCTestCase {
    let chip8 = CHIP8()
    
    override func setUp() {
        chip8.loadROM()
    }
    
    func testLoadRom() {
        
//        chip8.loadROM()
        XCTAssert(true)
    }
    
    func testMemoryDecoding() {
        chip8.loop()
        XCTAssert(true)
    }
}

