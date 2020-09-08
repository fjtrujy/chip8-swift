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

public enum Rom {
    public static let pong: [UInt8] = [0x6a, 0x02, 0x6b, 0x0c, 0x6c, 0x3f, 0x6d, 0x0c, 0xa2, 0xea, 0xda, 0xb6, 0xdc, 0xd6, 0x6e, 0x00, 0x22, 0xd4, 0x66, 0x03, 0x68, 0x02, 0x60, 0x60, 0xf0, 0x15, 0xf0, 0x07, 0x30, 0x00, 0x12, 0x1a, 0xc7, 0x17, 0x77, 0x08, 0x69, 0xff, 0xa2, 0xf0, 0xd6, 0x71, 0xa2, 0xea, 0xda, 0xb6, 0xdc, 0xd6, 0x60, 0x01, 0xe0, 0xa1, 0x7b, 0xfe, 0x60, 0x04, 0xe0, 0xa1, 0x7b, 0x02, 0x60, 0x1f, 0x8b, 0x02, 0xda, 0xb6, 0x60, 0x0c, 0xe0, 0xa1, 0x7d, 0xfe, 0x60, 0x0d, 0xe0, 0xa1, 0x7d, 0x02, 0x60, 0x1f, 0x8d, 0x02, 0xdc, 0xd6, 0xa2, 0xf0, 0xd6, 0x71, 0x86, 0x84, 0x87, 0x94, 0x60, 0x3f, 0x86, 0x02, 0x61, 0x1f, 0x87, 0x12, 0x46, 0x02, 0x12, 0x78, 0x46, 0x3f, 0x12, 0x82, 0x47, 0x1f, 0x69, 0xff, 0x47, 0x00, 0x69, 0x01, 0xd6, 0x71, 0x12, 0x2a, 0x68, 0x02, 0x63, 0x01, 0x80, 0x70, 0x80, 0xb5, 0x12, 0x8a, 0x68, 0xfe, 0x63, 0x0a, 0x80, 0x70, 0x80, 0xd5, 0x3f, 0x01, 0x12, 0xa2, 0x61, 0x02, 0x80, 0x15, 0x3f, 0x01, 0x12, 0xba, 0x80, 0x15, 0x3f, 0x01, 0x12, 0xc8, 0x80, 0x15, 0x3f, 0x01, 0x12, 0xc2, 0x60, 0x20, 0xf0, 0x18, 0x22, 0xd4, 0x8e, 0x34, 0x22, 0xd4, 0x66, 0x3e, 0x33, 0x01, 0x66, 0x03, 0x68, 0xfe, 0x33, 0x01, 0x68, 0x02, 0x12, 0x16, 0x79, 0xff, 0x49, 0xfe, 0x69, 0xff, 0x12, 0xc8, 0x79, 0x01, 0x49, 0x02, 0x69, 0x01, 0x60, 0x04, 0xf0, 0x18, 0x76, 0x01, 0x46, 0x40, 0x76, 0xfe, 0x12, 0x6c, 0xa2, 0xf2, 0xfe, 0x33, 0xf2, 0x65, 0xf1, 0x29, 0x64, 0x14, 0x65, 0x00, 0xd4, 0x55, 0x74, 0x15, 0xf2, 0x29, 0xd4, 0x55, 0x00, 0xee, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00
]
    
    public static let pongData = Data(Rom.pong)
}

private enum Constants {
    static let lastRegPos = 0xF
    static let mostBitReg: UInt8 = 0x80
    static let MAXPCValue: UInt16 = 0xFFF
}

public class CHIP8 {
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
    public func loadROM(data: Data = Rom.pongData) {
        let upper: Int = Int(machine.pc) + data.count - 1
        let range = Range(uncheckedBounds: (lower: Int(machine.pc), upper: upper))
        machine.mem.replaceSubrange(range, with: data)
        print(machine.mem)
    }
    
    public func screenContent()-> [Bool] { machine.screen }
    
    public func step() {
        let opCode = CHIP8OPCode(opCode: machine.opCode)
        increasePC()
        
        switch opCode {
        case .CLS: clearScreen()
        case .RET:
            guard machine.sp > .zero else { return }
            machine.sp -= 1
            machine.pc = machine.stack[Int(machine.sp)]
        case .SYS(let nnnn): break
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
        case .ADD(let x, let kk): machine.v[Int(x)] += kk
        case .LD_VxVy(x: let x, y: let y): machine.v[Int(x)] = machine.v[Int(y)]
        case .OR(let x, let y): machine.v[Int(x)] |= machine.v[Int(y)]
        case .AND(let x, let y): machine.v[Int(x)] &= machine.v[Int(y)]
        case .XOR(let x, let y): machine.v[Int(x)] ^= machine.v[Int(y)]
        case .ADD_VxVy(let x, let y):
            machine.v[0xF] = machine.v[Int(x)] > machine.v[Int(x)] + machine.v[Int(y)] ? 1 : .zero // CARRY FLAG
            machine.v[Int(x)] += machine.v[Int(y)]
        case .SUB(let x, let y):
            machine.v[Constants.lastRegPos] = machine.v[Int(x)] > machine.v[Int(y)] ? 1 : .zero // CARRY FLAG
            machine.v[Int(x)] -= machine.v[Int(y)]
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
        case .SKP(let x): break
        case .SKNP(let x): break
        case .LD_FROM_DT(let x): machine.v[Int(x)] = machine.dt
        case .LD_FROM_K(let x): break
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
