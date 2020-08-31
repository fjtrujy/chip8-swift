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

private enum Rom {
    static let pong: [UInt8] = [0x6a, 0x02, 0x6b, 0x0c, 0x6c, 0x3f, 0x6d, 0x0c, 0xa2, 0xea, 0xda, 0xb6, 0xdc, 0xd6, 0x6e, 0x00, 0x22, 0xd4, 0x66, 0x03, 0x68, 0x02, 0x60, 0x60, 0xf0, 0x15, 0xf0, 0x07, 0x30, 0x00, 0x12, 0x1a, 0xc7, 0x17, 0x77, 0x08, 0x69, 0xff, 0xa2, 0xf0, 0xd6, 0x71, 0xa2, 0xea, 0xda, 0xb6, 0xdc, 0xd6, 0x60, 0x01, 0xe0, 0xa1, 0x7b, 0xfe, 0x60, 0x04, 0xe0, 0xa1, 0x7b, 0x02, 0x60, 0x1f, 0x8b, 0x02, 0xda, 0xb6, 0x60, 0x0c, 0xe0, 0xa1, 0x7d, 0xfe, 0x60, 0x0d, 0xe0, 0xa1, 0x7d, 0x02, 0x60, 0x1f, 0x8d, 0x02, 0xdc, 0xd6, 0xa2, 0xf0, 0xd6, 0x71, 0x86, 0x84, 0x87, 0x94, 0x60, 0x3f, 0x86, 0x02, 0x61, 0x1f, 0x87, 0x12, 0x46, 0x02, 0x12, 0x78, 0x46, 0x3f, 0x12, 0x82, 0x47, 0x1f, 0x69, 0xff, 0x47, 0x00, 0x69, 0x01, 0xd6, 0x71, 0x12, 0x2a, 0x68, 0x02, 0x63, 0x01, 0x80, 0x70, 0x80, 0xb5, 0x12, 0x8a, 0x68, 0xfe, 0x63, 0x0a, 0x80, 0x70, 0x80, 0xd5, 0x3f, 0x01, 0x12, 0xa2, 0x61, 0x02, 0x80, 0x15, 0x3f, 0x01, 0x12, 0xba, 0x80, 0x15, 0x3f, 0x01, 0x12, 0xc8, 0x80, 0x15, 0x3f, 0x01, 0x12, 0xc2, 0x60, 0x20, 0xf0, 0x18, 0x22, 0xd4, 0x8e, 0x34, 0x22, 0xd4, 0x66, 0x3e, 0x33, 0x01, 0x66, 0x03, 0x68, 0xfe, 0x33, 0x01, 0x68, 0x02, 0x12, 0x16, 0x79, 0xff, 0x49, 0xfe, 0x69, 0xff, 0x12, 0xc8, 0x79, 0x01, 0x49, 0x02, 0x69, 0x01, 0x60, 0x04, 0xf0, 0x18, 0x76, 0x01, 0x46, 0x40, 0x76, 0xfe, 0x12, 0x6c, 0xa2, 0xf2, 0xfe, 0x33, 0xf2, 0x65, 0xf1, 0x29, 0x64, 0x14, 0x65, 0x00, 0xd4, 0x55, 0x74, 0x15, 0xf2, 0x29, 0xd4, 0x55, 0x00, 0xee, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00
]
    
    static let pongData = Data(Rom.pong)
}

private enum Constants {
    static let lastRegPos = 0xF
    static let mostBitReg: UInt8 = 0x80
}

class CHIP8 {
    private var machine: CHIP8Machine
    private var mustQuit: Bool
    
    init(machine: CHIP8Machine = CHIP8Machine(),
         mustQuit: Bool = false){
        self.machine = machine
        self.mustQuit = mustQuit
    }
    
//    func loadROM(path: String = "\(FileManager.default.currentDirectoryPath)/PONG") {
//        guard let data = FileManager.default.contents(atPath: path) else { return }
//        print(data)
    func loadROM(data: Data = Rom.pongData) {
        let upper: Int = Int(machine.pc) + data.count - 1
        let range = Range(uncheckedBounds: (lower: Int(machine.pc), upper: upper))
        machine.mem.replaceSubrange(range, with: data)
        print(machine.mem)
    }
    
    func loop() {
        while !mustQuit {
            let opCode = CHIP8OPCode(opCode: machine.opCode)
            increasePC()
            print(opCode)
            
            
            switch opCode {
            case .CLS: break
            case .RET: break
            case .SYS(let nnnn): break
            case .JP(let nnn): machine.pc = nnn
            case .CALL(let nnn): break
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
            case .JP_V0(let nnn): machine.pc = UInt16(machine.v[.zero]) + nnn
            case .RND(let x, let kk): break
            case .DRW(let x, let y, let nibble): break
            case .SKP(let x): break
            case .SKNP(let x): break
            case .LD_FROM_DT(let x): machine.v[Int(x)] = machine.dt
            case .LD_FROM_K(let x): break
            case .LD_TO_DT(let x): machine.dt = machine.v[Int(x)]
            case .LD_TO_ST(let x): machine.st = machine.v[Int(x)]
            case .ADD_I(let x): machine.i += UInt16(machine.v[Int(x)])
            case .LD_TO_I(let x): break
            case .LD_TO_B(let x): break
            case .LD_TO_Vxs(let x): break
            case .LD_FROM_Vxs(let x): break
            case .UKNOWN: print("Trying to execute a uknown instructions")
            }
        }
    }
    
    private func increasePC() { machine.pc = machine.pc + 2 >= machine.mem.count - 1 ? .zero : machine.pc + 2 }
}
