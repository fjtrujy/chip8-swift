//
//  File.swift
//  
//
//  Created by Francisco Javier Trujillo Mata on 20/10/23.
//

import Foundation


struct CHIP8Dispatcher {
    let instructions: [UInt16]
    
    init(instructions: [UInt16]) {
        self.instructions = instructions
    }
    
    func executeBackground() async -> [CHIP8OPCode] {
        if #available(macOS 10.15, *) {
            return await Task(priority: .background) {
                print("Is main Thread: \(Thread.isMainThread), id: \(Thread.current) ")
                return instructions.map { CHIP8OPCode(opCode: $0) }
            }.value
        } else {
            print("************Not available!!!!")
            return []
        }
    }
    
    func executeEachInBackground() async throws -> [CHIP8OPCode] {
        if #available(macOS 10.15, *) {
            return try await withThrowingTaskGroup(of: (CHIP8OPCode, Thread).self) { group in
                instructions.forEach { ins in
                    group.addTask { await dummyOpCodeTask(ins) }
                }
                
                var decoded: [CHIP8OPCode] = []
                var threads: Set<Thread> = .init()
                for try await value in group {
                    decoded.append(value.0)
                    threads.insert(value.1)
                }
                
                print("***************** \(threads.count) **************")
                
                return decoded
            }
        } else {
            print("************Not available!!!!")
            return []
        }
    }
    
    func dummyOpCodeTask(_ code: UInt16) async -> (CHIP8OPCode, Thread) {
        guard #available(macOS 10.15, *) else { return (.UKNOWN, Thread.current) }
        return await Task(priority: .background) {
            return (CHIP8OPCode(opCode: code), Thread.current)
        }.value
        
    }
}
