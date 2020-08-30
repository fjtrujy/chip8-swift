
private enum Constants {
    static let memSize = 4096
    static let regs = 16
    static let stackSize = 16
}

struct CHIP8 {
    var mem: [UInt8] = [UInt8](repeating: .zero, count: Constants.memSize) // Available Memory
    var pc: UInt16 = .zero // Program Counter
    
    var stack: [UInt16] = [UInt16](repeating: .zero, count: Constants.stackSize) // Stack Memory
    var sp: UInt16 = .zero // Stack Pointer
    
    var v: [UInt8] = [UInt8](repeating: .zero, count: Constants.regs) // Available Registers
    var i: UInt16 = .zero // Instruction register
    var dt: UInt8 = .zero // Delay Timer
    var st: UInt8 = .zero // Sound Timer
}
