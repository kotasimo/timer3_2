//
//  ContentView.swift
//  timer3
//
//  Created by Apex_Ventura on 2026/02/22.
//

import SwiftUI
import Combine


enum Subject: String, CaseIterable {
    case math = "数学"
    case physics = "物理"
    case chemistry = "化学"
    case english = "英語"
    case reading = "読書"
    case training = "筋トレ"
}

struct ContentView: View {
    @State private var current: Subject? = .math
    @State private var totals: [Subject: TimeInterval] = [:]
    @State private var elapsed: TimeInterval = 0
    @State private var isRunning: Bool = false
    @State private var lastTickDate: Date = Date()
    @State private var lastSubject: Subject? = .math
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private func formatTime(_ t: TimeInterval) -> String {
        let total = Int(t)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func subjectPosition(index: Int, count: Int, radius: CGFloat) -> CGPoint {
        let angle = (Double(index) / Double(count)) * (2 * Double.pi) - Double.pi / 2
        let x = cos(angle) * Double(radius)
        let y = sin(angle) * Double(radius)
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            VStack{
                ForEach(Subject.allCases, id: \.self) { s in
                    Text("\(s.rawValue): \(formatTime(totals[s, default: 0]))")
                }
            }
            .font(.title2)
            .foregroundStyle(.secondary)
            .monospacedDigit()
            .padding()
            
            Button {
                elapsed = 0
                isRunning = true
                lastTickDate = Date()
                
                if current != nil {
                    lastSubject = current
                    current = nil
                } else {
                    current = lastSubject
                }
                
            } label: {
                ZStack{
                    VStack{
                        Text(current? .rawValue ?? "休憩" )
                            .font(.title)
                            .bold()
                        Text(formatTime(elapsed))
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }
                    let all: [Subject] = Array(Subject.allCases)
                    ForEach(all.indices, id: \.self) { i in
                        let s = all[i]
                        let p = subjectPosition(index: i, count: all.count, radius: 170)
                        Text(s.rawValue)
                            .font(.caption)
                            .padding(6)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(current == s ? .primary : .clear, lineWidth: 2)
                            )
                            .offset(x: p.x, y: p.y)
                            .onTapGesture {
                                current = s
                                lastSubject = s
                                isRunning = true
                                lastTickDate = Date()
                                elapsed = 0
                            }
                        
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.black)
                .frame(width: 300, height: 300)
                .padding(.horizontal, 16)
                .background(current == nil ? Color.gray : Color.blue.opacity(0.5))
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
            
            guard isRunning else { return }
            guard delta > 0, delta < 2 else { return }
            
            if let s = current {
                totals[s, default: 0] += delta
                elapsed += delta
            }
        }
        
    }
}

#Preview {
    ContentView()
}
