//
//  ContentView.swift
//  timer3
//
//  Created by Apex_Ventura on 2026/02/22.
//

import SwiftUI
import Combine


enum Mode {
    case focus
    case rest
}

struct ContentView: View {
    @State private var mode: Mode = .focus
    @State private var elapsed: TimeInterval = 0
    @State private var isRunning: Bool = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Button {
                mode = (mode == .focus) ? .rest : .focus
                isRunning = (isRunning == false) ? true : false
            } label: {
                Text(mode == .focus ? "集中" : "休憩")
                Text("\(Int(elapsed))")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onReceive(timer) { _ in
            if isRunning {
                elapsed += 1
            } else {
                
            }
        }
        
    }
}

#Preview {
    ContentView()
}
