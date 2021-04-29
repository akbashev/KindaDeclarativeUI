//
//  ContentView.swift
//  KindaDeclarativeUIDemo
//
//  Created by Jaleel Akbashev on 14.03.21.
//

import SwiftUI
import KindaDeclarativeUI

struct KDUIView: View {
    
    @State var buttonClicked: Bool = false
    
    var strings = Array(0...1).map { "Row \($0) "}
    
    var body: some View {
        VStack {
            HStack {
                StackList(axis: .vertical) {
                    StackEach(strings, id: \.self) { string in
                        VerticalStack {
                            HorizontalStack {
                                VerticalStack(alignment: .center) {
                                    UILabel().map {
                                        $0.text = string
                                    }.aspectRatio(1, contentMode: .fit)
                                    UILabel().map {
                                        $0.numberOfLines = 0
                                        $0.text = "Description is quite long"
                                    }.padding(8)
                                }
                                FlatStack(alignment: .trailingBottom) {
                                    UILabel().map {
                                        $0.text = "Top thing here"
                                    }.padding()
                                    UILabel().map {
                                        $0.text = "Bottom"
                                    }
                                }
                                UILabel().map {
                                    $0.text = "next >"
                                    $0.textColor = .white
                                }.background(UIColor.red).shadow(radius: 12).padding(4)
                            }.debug()
                            UIView().map {
                                $0.backgroundColor = .gray
                            }.frame(width: .infinity, height: 1)
                        }
                    }
                }.swiftUIView
            }
        }
    }
}

struct SwiftUIView: View {
    
    @State var buttonClicked: Bool = false
    
    var strings = Array(0...1).map { "Row \($0) "}
    
    var body: some View {
        VStack {
            List {
                ForEach(strings, id: \.self) { string in
                    VStack {
                        HStack {
                            VStack(alignment: .center) {
                                Text(string)
                                    .aspectRatio(7, contentMode: .fit).debugBorder()
                                Text("Description is quite long")
                                    .lineLimit(nil)
                                    .padding(8).debugBorder()
                                }.debugBorder()
                            ZStack(alignment: .bottomTrailing) {
                                Text("Top thing here").padding().debugBorder()
                                Text("Bottom").debugBorder()
                            }
                            Text("next >").background(Color.red).shadow(radius: 12).padding(4).debugBorder()
                        }.debugBorder()
                    }.debugBorder()
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            KDUIView()
                .previewLayout(PreviewLayout.device)

            SwiftUIView()
                .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}


extension View {
    func debugModifier<T: View>(_ modifier: (Self) -> T) -> some View {
        #if DEBUG
        return modifier(self)
        #else
        return self
        #endif
    }
}

extension View {
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        debugModifier {
            $0.border(color, width: width)
        }
    }

    func debugBackground(_ color: Color = .red) -> some View {
        debugModifier {
            $0.background(color)
        }
    }
}
