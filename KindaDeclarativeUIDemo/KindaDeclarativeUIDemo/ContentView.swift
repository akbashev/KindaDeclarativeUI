//
//  ContentView.swift
//  KindaDeclarativeUIDemo
//
//  Created by Jaleel Akbashev on 14.03.21.
//

import SwiftUI
import KindaDeclarativeUI

struct ContentView: View {
    
    @State var buttonClicked: Bool = false
    
    var strings = Array(0...2000).map { "Row \($0) "}
    
    var body: some View {
        VStack {
            StackList(axis: .vertical) {
                StackEach(strings, id: \.self) { string in
                    HorizontalStack {
                        VerticalStack(alignment: .leading) {
                            GenerateView {
                                let label = UILabel()
                                label.text = string
                                return label
                            }
                            GenerateView {
                                let label = UILabel()
                                label.text = "Description"
                                return label
                            }
                        }
                        GenerateView {
                            let label = UILabel()
                            label.text = "next >"
                            return label
                        }
                    }
                }
            }.swiftUIView
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
