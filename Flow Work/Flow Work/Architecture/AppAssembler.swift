//
//  AppAssembler.swift
//  Flow Work
//
//  Created by Allen Lin on 10/12/23.
//

import Swinject

final class AppAssembler {
    private let assembler: Assembler
    
    var resolver: Resolver {
        self.assembler.resolver
    }
    
    init() {
        self.assembler = Assembler([
            CoordinatorAssembly(),
            ViewModelAssembly(),
            ServiceAssembly()])
    }
}
