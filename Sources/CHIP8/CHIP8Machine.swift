import Foundation

private enum Constants {
    static let memSize = 4096
    static let regs = 16
    static let stackSize = 16
    static let pcPos: UInt16 = 0x200
}

struct CHIP8Machine {
    var mem: [UInt8] = [UInt8](repeating: .zero, count: Constants.memSize) // Available Memory
    var pc: UInt16 = Constants.pcPos // Program Counter
    
    var stack: [UInt16] = [UInt16](repeating: .zero, count: Constants.stackSize) // Stack Memory
    var sp: UInt16 = .zero // Stack Pointer
    
    var v: [UInt8] = [UInt8](repeating: .zero, count: Constants.regs) // Available Registers
    var i: UInt16 = .zero // Instruction register
    var dt: UInt8 = .zero // Delay Timer
    var st: UInt8 = .zero // Sound Timer
    
    var opCode: UInt16 {
        let firstCode: UInt16 = UInt16(mem[Int(pc)])
        let secondCode: UInt16 = UInt16(mem[Int(pc+1)])
        return (firstCode << 8) | secondCode
    }
}
