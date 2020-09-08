//
//  CHIP8.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 30/08/2020.
//

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


import Foundation

private enum Constants {
    static let lastRegPos = 0xF
    static let mostBitReg: UInt8 = 0x80
    static let MAXPCValue: UInt16 = 0xFFF
}

public class CHIP8 {
    public weak var delegate: CHIP8Delegate?
    public var isWaitingKey: Bool { machine.waitKey != .max }
    private var machine: CHIP8Machine
    private var mustQuit: Bool
    
    public init(machine: CHIP8Machine = CHIP8Machine(),
         mustQuit: Bool = false){
        self.machine = machine
        self.mustQuit = mustQuit
    }
    
//    func loadROM(path: String = "\(FileManager.default.currentDirectoryPath)/PONG") {
//        guard let data = FileManager.default.contents(atPath: path) else { return }
//        print(data)
    public func loadROM(data: Data) -> Bool {
        guard data.count < machine.availableMem else { return false }
        let upper: Int = Int(machine.pc) + data.count - 1
        let range = Range(uncheckedBounds: (lower: Int(machine.pc), upper: upper))
        machine.mem.replaceSubrange(range, with: data)
        
        return true
    }
    
    public func screenContent()-> [Bool] { machine.screen }
    
    public func step() {
        let opCode = CHIP8OPCode(opCode: machine.opCode)
//        print(opCode)
        increasePC()
        
        switch opCode {
        case .CLS: clearScreen()
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
    }
    
    public func keyPressed(key: UInt8) {
        machine.waitKey = key
    }
    
    private func increasePC() { machine.pc += 2 & Constants.MAXPCValue }
    private func clearScreen() { (0..<machine.screen.count).forEach { machine.screen[$0] = false } }
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

public protocol CHIP8Delegate: class {
    func chip8(_ chip8: CHIP8, isPressingKey key: UInt8) -> Bool
}
