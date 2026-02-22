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
    @State private var totalFocus: TimeInterval = 0
    @State private var totalRest: TimeInterval = 0
    @State private var isRunning: Bool = false
    @State private var lastTickDate: Date = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private func formatTime(_ t: TimeInterval) -> String {
        let total = Int(t)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            VStack{
                Text("集中: \(formatTime(totalFocus))")
                Text("休憩: \(formatTime(totalRest))")
            }
            .font(.title2)
            .foregroundStyle(.secondary)
            .monospacedDigit()
            .padding()
            
            Button {
                switch mode {
                case .focus: totalFocus += elapsed
                case .rest: totalRest += elapsed
                }
                mode = (mode == .focus) ? .rest : .focus
                elapsed = 0
                isRunning = true
                lastTickDate = Date()
            } label: {
                VStack{
                    Text(mode == .focus ? "集中" : "休憩")
                        .font(.title)
                        .bold()
                    Text(formatTime(elapsed))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.black)
                    .frame(width: 300, height: 300)
                    .padding(.horizontal, 16)
                    .background(mode == .focus ? Color.blue.opacity(0.5) : Color.green.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding()
            
            Button {
                isRunning = false
            } label: {
                Text("停止")
                    .foregroundColor(.red)
            }
            .padding()
            .background(Color.yellow.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onReceive(timer) { now in
            let delta = now.timeIntervalSince(lastTickDate)
            lastTickDate = now
  
            if isRunning {
                elapsed += delta
            }
        }
        
    }
}

#Preview {
    ContentView()
}
