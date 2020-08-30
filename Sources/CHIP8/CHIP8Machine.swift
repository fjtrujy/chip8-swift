import Foundation

private enum Constants {
    static let memSize = 4096
    static let regs = 16
    static let stackSize = 16
    static let pcPos: UInt16 = 0x200
    
    static let nnnMask: UInt16 = 0x0FFF
    static let kkMask: UInt16 = 0xFF
    static let nMask: UInt16 = 0xF
}

struct CHIP8Machine {
    enum OPCODE {
        case CLS
        case RET
        case SYS(nnn: UInt16)
        case JP(nnn: UInt16)
        case CALL(nnn: UInt16)
        case SE(Vx: UInt8, kk: UInt8)
        case SNE(Vx: UInt8, kk: UInt8)
        case SE(Vx: UInt8, Vy: UInt8)
        case LD(Vx: UInt8, kk: UInt8)
        case ADD(Vx: UInt8, kk: UInt8)
        case LD(Vx: UInt8, Vy: UInt8)
        case OR(Vx: UInt8, Vy: UInt8)
        case AND(Vx: UInt8, Vy: UInt8)
        case XOR(Vx: UInt8, Vy: UInt8)
        case ADD(Vx: UInt8, Vy: UInt8)
        case SUB(Vx: UInt8, Vy: UInt8)
        case SHR(Vx: UInt8, Vy: UInt8)
        case SUBN(Vx: UInt8, Vy: UInt8)
        case SHL(Vx: UInt8, Vy: UInt8)
        case SNE(Vx: UInt8, Vy: UInt8)
        case LD(nnn: UInt16)
        case JP_V0(nnn: UInt16)
        case RND(Vx: UInt8, kk: UInt8)
        case DRW(Vx: UInt8, Vy: UInt8, nibble: UInt8)
        case SKP(Vx: UInt8)
        case SKNP(Vx: UInt8)
        case LD_FROM_DT(Vx: UInt8)
        case LD_FROM_K(Vx: UInt8)
        case LD_TO_DT(Vx: UInt8)
        case LD_TO_ST(Vx: UInt8)
        case ADD_I(Vx: UInt8)
        case LD_TO_I(Vx: UInt8)
        case LD_TO_B(Vx: UInt8)
        case LD_TO_Vxs(Vx: UInt8)
        case LD_FROM_Vxs(Vx: UInt8)
        case UKNOWN
        
        init(opCode: UInt16) {
            let nnn = opCode & Constants.nnnMask
            let kk = UInt8(opCode & Constants.kkMask)
            let n = UInt8(opCode & Constants.nMask)
            let x = UInt8((opCode >> 8) & Constants.nMask)
            let y = UInt8((opCode >> 4) & Constants.nMask)
            let p = UInt8(opCode >> 12)
            
            switch (p, x, y, n) {
            case (0x0, 0x0, 0xE, 0x0): self = .CLS
            case (0x0, 0x0, 0xE, 0xE): self = .RET
            case (0x0, _, _, _): self = .SYS(nnn: nnn)
            case (0x1, _, _, _): self = .JP(nnn: nnn)
            case (0x2, _, _, _): self = .CALL(nnn: nnn)
            case (0x3, _, _, _): self = .SE(Vx: x, kk: kk)
            case (0x4, _, _, _): self = .SNE(Vx: x, kk: kk)
            case (0x5, _, _, 0x0): self = .SE(Vx: x, Vy: y)
            case (0x6, _, _, _): self = .LD(Vx: x, kk: kk)
            case (0x7, _, _, _): self = .ADD(Vx: x, kk: kk)
            case (0x8, _, _, 0x0): self = .LD(Vx: x, Vy: y)
            case (0x8, _, _, 0x1): self = .OR(Vx: x, Vy: y)
            case (0x8, _, _, 0x2): self = .AND(Vx: x, Vy: y)
            case (0x8, _, _, 0x3): self = .XOR(Vx: x, Vy: y)
            case (0x8, _, _, 0x4): self = .ADD(Vx: x, Vy: y)
            case (0x8, _, _, 0x5): self = .SUB(Vx: x, Vy: y)
            case (0x8, _, _, 0x6): self = .SHR(Vx: x, Vy: y)
            case (0x8, _, _, 0x7): self = .SUBN(Vx: x, Vy: y)
            case (0x8, _, _, 0xE): self = .SHL(Vx: x, Vy: y)
            case (0x9, _, _, 0x0): self = .SNE(Vx: x, Vy: y)
            case (0xA, _, _, _): self = .LD(nnn: nnn)
            case (0xB, _, _, _): self = .JP_V0(nnn: nnn)
            case (0xC, _, _, _): self = .RND(Vx: x, kk: kk)
            case (0xD, _, _, _): self = .DRW(Vx: x, Vy: y, nibble: n)
            case (0xE, _, 0x9, 0xE): self = .SKP(Vx: x)
            case (0xE, _, 0xA, 0x1): self = .SKNP(Vx: x)
            case (0xF, _, 0x0, 0x7): self = .LD_FROM_DT(Vx: x)
            case (0xF, _, 0x0, 0xA): self = .LD_FROM_K(Vx: x)
            case (0xF, _, 0x1, 0x5): self = .LD_TO_DT(Vx: x)
            case (0xF, _, 0x1, 0x8): self = .LD_TO_ST(Vx: x)
            case (0xF, _, 0x1, 0xE): self = .ADD_I(Vx: x)
            case (0xF, _, 0x2, 0x9): self = .LD_TO_I(Vx: x)
            case (0xF, _, 0x3, 0x3): self = .LD_TO_B(Vx: x)
            case (0xF, _, 0x5, 0x5): self = .LD_TO_Vxs(Vx: x)
            case (0xF, _, 0x6, 0x5): self = .LD_FROM_Vxs(Vx: x)
            default: self = .UKNOWN
            }
        }
        
    }
    
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
