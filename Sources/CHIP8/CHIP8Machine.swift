import Foundation

private enum Constants {
    static let memSize = 4096
    static let regs = 16
    static let stackSize = 16
    static let pcPos: UInt16 = 0x200
    static let screenSize = 64*32
    static let startHexCode = 0x50
    static let hexCodeLenght = 5
    static let hexCodes: [UInt8] = [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80, // F
    ]
}

public struct CHIP8Machine {
    var mem: [UInt8]
    var pc: UInt16 = Constants.pcPos // Program Counter
    
    var stack: [UInt16] = [UInt16](repeating: .zero, count: Constants.stackSize) // Stack Memory
    var sp: UInt16 = .zero // Stack Pointer
    
    var v: [UInt8] = [UInt8](repeating: .zero, count: Constants.regs) // Available Registers
    var i: UInt16 = .zero // Instruction register
    var dt: UInt8 = .zero // Delay Timer
    var st: UInt8 = .zero // Sound Timer
    
    var screen: [Bool] = [Bool](repeating: false, count: Constants.screenSize)
    
    var opCode: UInt16 {
        let firstCode: UInt16 = UInt16(mem[Int(pc)])
        let secondCode: UInt16 = UInt16(mem[Int(pc+1)])
        return (firstCode << 8) | secondCode
    }
    
    public init() {
        var mem: [UInt8] = [UInt8](repeating: .zero, count: Constants.memSize) // Available Memory
        Constants.hexCodes.enumerated().forEach { mem[Constants.startHexCode + $0] = $1 }
        self.mem = mem
    }
    
    func hexCodePos(hexCode: UInt8) -> UInt8 { UInt8(Constants.startHexCode) + (v[Int(hexCode)] * 5) }
}
