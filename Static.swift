import Foundation

private enum Constants {
    static let lastRegPos = 0xF
    static let mostBitReg: UInt8 = 0x80
    static let MAXPCValue: UInt16 = 0xFFF

    static let memSize = 4096
    static let regs = 16
    static let stackSize = 16
    static let pcPos: UInt16 = 0x200
    static let screenSize = 64*32
    static let startHexCode = 0x50
    static let hexCodeLenght: UInt8 = 5
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


    static let nnnMask: UInt16 = 0x0FFF
    static let kkMask: UInt16 = 0xFF
    static let nMask: UInt16 = 0xF
}

public class CHIP8 {
    public weak var delegate: CHIP8Delegate?
    public var screenContent: [Bool] { machine.screen }
    public var isWaitingKey: Bool { machine.waitKey != .max }
    
    private var machine: CHIP8Machine
    private var mustQuit: Bool
    
    public init(machine: CHIP8Machine = CHIP8Machine(),
         mustQuit: Bool = false){
        self.machine = machine
        self.mustQuit = mustQuit
    }

    public func loadROM(data: Data) -> Bool {
        guard data.count < machine.availableMem else { return false }
        let upper: Int = Int(machine.pc) + data.count - 1
        let range = Range(uncheckedBounds: (lower: Int(machine.pc), upper: upper))
        machine.mem.replaceSubrange(range, with: data)
        
        return true
    }
    
    public func step() {
        let opCode = CHIP8OPCode(opCode: machine.opCode)
        increasePC()
        
        switch opCode {
        case .CLS: (0..<machine.screen.count).forEach { machine.screen[$0] = false }
        case .RET:
            guard machine.sp > .zero else { return }
            machine.sp -= 1
            machine.pc = machine.stack[Int(machine.sp)]
        case .JP(let nnn): machine.pc = nnn
        case .CALL(let nnn):
            guard machine.sp < machine.stack.count else { return }
            machine.stack[Int(machine.sp)] = machine.pc
            machine.sp += 1
            machine.pc = nnn
        case .SE(let x, let kk): machine.v[Int(x)] == kk ? increasePC() : nil
        case .SNE(let x, let kk): machine.v[Int(x)] != kk ? increasePC() : nil
        case .SE_VxVy(let x, let y): machine.v[Int(x)] == machine.v[Int(y)] ? increasePC() : nil
        case .LD_Vx(let x, let kk): machine.v[Int(x)] = kk
        case .ADD(let x, let kk): machine.v[Int(x)] =  UInt8((Int16(machine.v[Int(x)]) + Int16(kk)) & 0xFF)
        case .LD_VxVy(x: let x, y: let y): machine.v[Int(x)] = machine.v[Int(y)]
        case .OR(let x, let y): machine.v[Int(x)] |= machine.v[Int(y)]
        case .AND(let x, let y): machine.v[Int(x)] &= machine.v[Int(y)]
        case .XOR(let x, let y): machine.v[Int(x)] ^= machine.v[Int(y)]
        case .ADD_VxVy(let x, let y):
            let total = UInt8((UInt16(machine.v[Int(x)]) + UInt16(machine.v[Int(y)])) & 0xFF )
            machine.v[Constants.lastRegPos] = machine.v[Int(x)] > total ? 1 : .zero // CARRY FLAG
            machine.v[Int(x)] = total
        case .SUB(let x, let y):
            let total = UInt8((Int16(machine.v[Int(x)]) - Int16(machine.v[Int(y)])) & 0xFF )
            machine.v[Constants.lastRegPos] = machine.v[Int(x)] > machine.v[Int(y)] ? 1 : .zero // CARRY FLAG
            machine.v[Int(x)] = total
        case .SHR(let x):
            machine.v[Constants.lastRegPos] = machine.v[Int(x)] & 1
            machine.v[Int(x)] >>= 1
        case .SUBN(let x, let y):
            machine.v[Constants.lastRegPos] = machine.v[Int(y)] > machine.v[Int(x)] ? 1 : .zero // CARRY FLAG
            machine.v[Int(x)] = machine.v[Int(y)] - machine.v[Int(x)]
        case .SHL(let x):
            machine.v[Constants.lastRegPos] = (machine.v[Int(x)] & Constants.mostBitReg) != .zero ? 1 : .zero
            machine.v[Int(x)] <<= 1
        case .SNE_VxVy(let x, let y): machine.v[Int(x)] != machine.v[Int(y)] ? increasePC() : nil
        case .LD(let nnn): machine.i = nnn
        case .JP_V0(let nnn): machine.pc = (UInt16(machine.v[.zero]) + nnn) & Constants.MAXPCValue
        case .RND(let x, let kk): machine.v[Int(x)] = UInt8(Int8.random(in: Int8.zero...Int8.max)) & kk
        case .DRW(let x, let y, let n): drw(x: x, y: y, n: n)
        case .SKP(let x): delegate?.chip8(self, isPressingKey: machine.v[Int(x)]) ?? false ? increasePC() : nil
        case .SKNP(let x): delegate?.chip8(self, isPressingKey: machine.v[Int(x)]) ?? true ? nil : increasePC()
        case .LD_FROM_DT(let x): machine.v[Int(x)] = machine.dt
        case .LD_FROM_K(let x): machine.waitKey = x
        case .LD_TO_DT(let x): machine.dt = machine.v[Int(x)]
        case .LD_TO_ST(let x): machine.st = machine.v[Int(x)]
        case .ADD_I(let x): machine.i += UInt16(machine.v[Int(x)])
        case .LD_TO_I(let x): machine.i = UInt16(machine.hexCodePos(hexCode: x))
        case .LD_TO_B(let x): ldToB(x: x)
        case .LD_TO_Vxs(let x): (0...x).forEach { machine.mem[Int(machine.i + UInt16($0))] = machine.v[Int($0)] }
        case .LD_FROM_Vxs(let x): (0...x).forEach { machine.v[Int($0)] = machine.mem[Int(machine.i + UInt16($0))] }
        case .UKNOWN: print("Trying to execute a uknown instructions")
        }
    }
    
    public func decreaseTimers() {
        (machine.dt > .zero) ? machine.dt -= 1 : nil
        (machine.st > .zero) ? machine.st -= 1 : nil
        
        delegate?.chip8(self, pauseAudio: machine.st == .zero)
    }
    
    public func keyPressed(key: UInt8) { machine.waitKey = key }
    
    // MARK: - Private Functions
    private func increasePC() { machine.pc += 2 & Constants.MAXPCValue }
    private func drw(x: UInt8, y: UInt8, n: UInt8) {
        machine.v[Constants.lastRegPos] = .zero
        (0..<n).forEach { pass in
            let sprite = machine.mem[Int(machine.i + UInt16(pass))]
            (0..<8).forEach {
                let px = (Int(machine.v[Int(x)]) + $0) & 63
                let py = (Int(machine.v[Int(y)]) + Int(pass)) & 31
                let pos = 64 * py + px
                let pixelOn = ((sprite & (1 << (7 - $0))) != .zero)
                machine.v[Constants.lastRegPos] |= (machine.screen[pos] && pixelOn) ? 1 : .zero
                machine.screen[pos] = machine.screen[pos] != pixelOn
            }
        }
    }
    private func ldToB(x: UInt8) {
        machine.mem[Int(machine.i) + 2] = machine.v[Int(x)] % 10
        machine.mem[Int(machine.i) + 1] = (machine.v[Int(x)] / 10) % 10
        machine.mem[Int(machine.i)] = machine.v[Int(x)] / 100
    }
}

// MARK: - CHIP8Delegate
public protocol CHIP8Delegate: AnyObject {
    func chip8(_ chip8: CHIP8, isPressingKey key: UInt8) -> Bool
    func chip8(_ chip8: CHIP8, pauseAudio pause: Bool)
}

//Memory Map:
//+---------------+= 0xFFF (4095) End of Chip-8 RAM
//|               |
//|               |
//|               |
//|               |
//|               |
//| 0x200 to 0xFFF|
//|     Chip-8    |
//| Program / Data|
//|     Space     |
//|               |
//|               |
//|               |
//+- - - - - - - -+= 0x600 (1536) Start of ETI 660 Chip-8 programs
//|               |
//|               |
//|               |
//+---------------+= 0x200 (512) Start of most Chip-8 programs
//| 0x000 to 0x1FF|
//| Reserved for  |
//|  interpreter  |
//+---------------+= 0x000 (0) Start of Chip-8 RAM

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
    
    var waitKey: UInt8 = .max
    
    let availableMem: UInt16 = UInt16(Constants.memSize) - Constants.pcPos
    
    public init() {
        var mem: [UInt8] = [UInt8](repeating: .zero, count: Constants.memSize) // Available Memory
        Constants.hexCodes.enumerated().forEach { mem[Constants.startHexCode + $0] = $1 } // Save HexCode in Memory
        self.mem = mem
    }
    
    func hexCodePos(hexCode: UInt8) -> UInt8 {
        UInt8(Constants.startHexCode) + (v[Int(hexCode)] * Constants.hexCodeLenght)
    }
}

public enum CHIP8OPCode {
    case CLS
    case RET
    case JP(nnn: UInt16)
    case CALL(nnn: UInt16)
    case SE(x: UInt8, kk: UInt8)
    case SNE(x: UInt8, kk: UInt8)
    case SE_VxVy(x: UInt8, y: UInt8)
    case LD_Vx(x: UInt8, kk: UInt8)
    case ADD(x: UInt8, kk: UInt8)
    case LD_VxVy(x: UInt8, y: UInt8)
    case OR(x: UInt8, y: UInt8)
    case AND(x: UInt8, y: UInt8)
    case XOR(x: UInt8, y: UInt8)
    case ADD_VxVy(x: UInt8, y: UInt8)
    case SUB(x: UInt8, y: UInt8)
    case SHR(x: UInt8)
    case SUBN(x: UInt8, y: UInt8)
    case SHL(x: UInt8)
    case SNE_VxVy(x: UInt8, y: UInt8)
    case LD(nnn: UInt16)
    case JP_V0(nnn: UInt16)
    case RND(x: UInt8, kk: UInt8)
    case DRW(x: UInt8, y: UInt8, n: UInt8)
    case SKP(x: UInt8)
    case SKNP(x: UInt8)
    case LD_FROM_DT(x: UInt8)
    case LD_FROM_K(x: UInt8)
    case LD_TO_DT(x: UInt8)
    case LD_TO_ST(x: UInt8)
    case ADD_I(x: UInt8)
    case LD_TO_I(x: UInt8)
    case LD_TO_B(x: UInt8)
    case LD_TO_Vxs(x: UInt8)
    case LD_FROM_Vxs(x: UInt8)
    case UKNOWN
    
    public init(opCode: UInt16) {
        let nnn = opCode & Constants.nnnMask
        let kk = UInt8(opCode & Constants.kkMask)
        let n = UInt8(opCode & Constants.nMask)
        let x = UInt8((opCode >> 8) & Constants.nMask)
        let y = UInt8((opCode >> 4) & Constants.nMask)
        let p = UInt8(opCode >> 12)

        switch (p, x, y, n) {
        case (0x0, 0x0, 0xE, 0x0): self = .CLS
        case (0x0, 0x0, 0xE, 0xE): self = .RET
        case (0x1, _, _, _): self = .JP(nnn: nnn)
        case (0x2, _, _, _): self = .CALL(nnn: nnn)
        case (0x3, _, _, _): self = .SE(x: x, kk: kk)
        case (0x4, _, _, _): self = .SNE(x: x, kk: kk)
        case (0x5, _, _, 0x0): self = .SE_VxVy(x: x, y: y)
        case (0x6, _, _, _): self = .LD_Vx(x: x, kk: kk)
        case (0x7, _, _, _): self = .ADD(x: x, kk: kk)
        case (0x8, _, _, 0x0): self = .LD_VxVy(x: x, y: y)
        case (0x8, _, _, 0x1): self = .OR(x: x, y: y)
        case (0x8, _, _, 0x2): self = .AND(x: x, y: y)
        case (0x8, _, _, 0x3): self = .XOR(x: x, y: y)
        case (0x8, _, _, 0x4): self = .ADD_VxVy(x: x, y: y)
        case (0x8, _, _, 0x5): self = .SUB(x: x, y: y)
        case (0x8, _, _, 0x6): self = .SHR(x: x)
        case (0x8, _, _, 0x7): self = .SUBN(x: x, y: y)
        case (0x8, _, _, 0xE): self = .SHL(x: x)
        case (0x9, _, _, 0x0): self = .SNE_VxVy(x: x, y: y)
        case (0xA, _, _, _): self = .LD(nnn: nnn)
        case (0xB, _, _, _): self = .JP_V0(nnn: nnn)
        case (0xC, _, _, _): self = .RND(x: x, kk: kk)
        case (0xD, _, _, _): self = .DRW(x: x, y: y, n: n)
        case (0xE, _, 0x9, 0xE): self = .SKP(x: x)
        case (0xE, _, 0xA, 0x1): self = .SKNP(x: x)
        case (0xF, _, 0x0, 0x7): self = .LD_FROM_DT(x: x)
        case (0xF, _, 0x0, 0xA): self = .LD_FROM_K(x: x)
        case (0xF, _, 0x1, 0x5): self = .LD_TO_DT(x: x)
        case (0xF, _, 0x1, 0x8): self = .LD_TO_ST(x: x)
        case (0xF, _, 0x1, 0xE): self = .ADD_I(x: x)
        case (0xF, _, 0x2, 0x9): self = .LD_TO_I(x: x)
        case (0xF, _, 0x3, 0x3): self = .LD_TO_B(x: x)
        case (0xF, _, 0x5, 0x5): self = .LD_TO_Vxs(x: x)
        case (0xF, _, 0x6, 0x5): self = .LD_FROM_Vxs(x: x)
        default: self = .UKNOWN
        }
    }
}


let rndOpcodes: [UInt16] = (1...1000000).map( {_ in UInt16(Int16.random(in: Int16.zero...Int16.max))} )
rndOpcodes.forEach { print(CHIP8OPCode(opCode: $0)) }