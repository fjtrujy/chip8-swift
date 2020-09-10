//
//  CHIP8OPCode.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 31/08/2020.
//

import Foundation

private enum Constants {
    static let nnnMask: UInt16 = 0x0FFF
    static let kkMask: UInt16 = 0xFF
    static let nMask: UInt16 = 0xF
}

enum CHIP8OPCode {
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
