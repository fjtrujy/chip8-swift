//
//  CHIP8OPCodeTests.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 31/08/2020.
//

import XCTest
@testable import CHIP8

final class CHIP8OPCodeTests: XCTestCase {
    let rndOpcodes: [UInt16] = (1...1000000).map( {_ in UInt16(Int16.random(in: Int16.zero...Int16.max))} )
    
    func testDecodingSpeed() {
          rndOpcodes.forEach { _ = CHIP8OPCode(opCode: $0) }
    }
}
