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
    @State private var current: Subject? = .math          // nil = 休憩
    @State private var lastSubject: Subject? = .math      // 休憩から戻る先
    @State private var totals: [Subject: TimeInterval] = [:]
    @State private var elapsed: TimeInterval = 0          // 今の区間（表示用）
    @State private var isRunning: Bool = false
    @State private var lastTickDate: Date = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private func formatTime(_ t: TimeInterval) -> String {
        let total = Int(t)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func select(_ s: Subject) {
        current = s
        lastSubject = s
        isRunning = true
        lastTickDate = Date()
        elapsed = 0
    }
    
    private func toggleRest() {
        // 中央ボタン：科目 <-> 休憩
        isRunning = true
        lastTickDate = Date()
        elapsed = 0
        
        if let cur = current {
            lastSubject = cur
            current = nil // 休憩へ
        } else {
            // 休憩 -> 前回科目へ
            current = lastSubject
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 科目ごとの合計表示
            VStack {
                ForEach(Subject.allCases, id: \.self) { s in
                    Text("\(s.rawValue): \(formatTime(totals[s, default: 0]))")
                }
            }
            .font(.title2)
            .foregroundStyle(.secondary)
            .monospacedDigit()
            .padding()
            
            // 中央の大ボタン（球形）
            ZStack{
                // 外周ラベル
                let all = Subject.allCases
                ForEach(all.indices, id: \.self) { i in
                    SubjectLabel(
                        subject: all[i],
                        index: i,
                        count: all.count,
                        radius: 150,
                        isSelected: current == all[i]
                    ) {
                        select(all[i])
                    }
                }
                .padding()
                Button {
                    toggleRest()
                } label: {
                        // 中央表示
                        VStack(spacing: 6) {
                            Text(current?.rawValue ?? "休憩")
                                .font(.title)
                                .bold()
                            
                            Text(formatTime(elapsed))
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .monospacedDigit()
                        }
                        
                    .frame(width: 250, height: 250)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .background(current == nil ? Color.gray : Color.blue.opacity(0.5))
                    .clipShape(Circle())
                }
                .padding()
            }
            .padding(30)
            
            // デバッグ用停止ボタン（そのままでOK）
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
            guard delta > 0, delta < 2 else { return } // 復帰ドカン保険
            
            if let s = current {
                totals[s, default: 0] += delta
                elapsed += delta
            }
        }
    }
}

struct SubjectLabel: View {
    let subject: Subject
    let index: Int
    let count: Int
    let radius: CGFloat
    let isSelected: Bool
    let action: () -> Void
    
    private func offset() -> CGSize {
        let angle = (Double(index) / Double(count)) * (2 * Double.pi) - Double.pi / 2
        return CGSize(
            width: cos(angle) * Double(radius),
            height: sin(angle) * Double(radius)
        )
    }
    
    var body: some View {
        Text(subject.rawValue)
            .font(.caption)
            .padding(6)
            .background(.thinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? Color.primary : Color.clear, lineWidth: 2)
            )
            .offset(offset())
            .onTapGesture { action() }
    }
}

#Preview {
    ContentView()
}
