//
//  ContentView.swift
//  ShoppingCart
//
//  Created by Chris Eidhof on 22.10.19.
//  Copyright © 2019 Chris Eidhof. All rights reserved.
//

import SwiftUI

let colors = (0..<5).map { ix in
    Color(hue: Double(ix)/5, saturation: 1, brightness: 0.8)
}
let icons = ["airplane", "studentdesk", "hourglass", "headphones", "lightbulb"]

struct ShoppingItem: View {
    let index: Int
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
           .fill(colors[index])
           .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: icons[index])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .padding(10)
            )
    }
}

struct AnchorKey<A>: PreferenceKey {
    typealias Value = Anchor<A>?
    static var defaultValue: Value { nil }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

extension View {
    func overlayWithAnchor<A, V: View>(value: Anchor<A>.Source, transform: @escaping (Anchor<A>) -> V) -> some View {
        self
            .anchorPreference(key: AnchorKey<A>.self, value: value, transform: { $0 })
            .overlayPreferenceValue(AnchorKey<A>.self, { anchor in
                transform(anchor!)
            })
    }
}

fileprivate struct AppearFrom: ViewModifier {
    let anchor: Anchor<CGPoint>
    @State private var didAppear: Bool = false
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .offset(self.didAppear ? .zero : CGSize(width: proxy[self.anchor].x, height: proxy[self.anchor].y))
                .onAppear {
                    self.didAppear = true
                }
        }
    }
}

extension View {
    func appearFrom(anchor: Anchor<CGPoint>) -> some View {
        self.modifier(AppearFrom(anchor: anchor))
    }
}

struct ContentView: View {
    @State var cartItems: [(index: Int, anchor: Anchor<CGPoint>)] = []
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<colors.count) { index in
                    ShoppingItem(index: index)
                        .overlayWithAnchor(value: .topLeading) { anchor in
                            Button(action: {
                                self.cartItems.append((index: index, anchor: anchor))
                            }, label: { Color.clear })
                        }
                }
            }
            Spacer()
            HStack {
                ForEach(Array(self.cartItems.enumerated()), id: \.offset) { (ix, item) in
                    ShoppingItem(index: item.index)
                        .appearFrom(anchor: item.anchor)
                        .animation(.default)
                        .frame(width: 50, height: 50)
                }
            }.frame(height: 50)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
