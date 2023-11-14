//
//  TermsOfUseSheet.swift
//  Luma
//
//  Created by Rob In der Maur on 14/07/2023.
//

import SwiftUI
import WebKit
import AEPEdge
import AEPCore
import AEPEdgeIdentity
import os.log

struct TermsOfUseSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var model = SwiftUIWebViewModel()
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                }
                Spacer()
            }
            SwiftUIWebView(webView: model.webView)
                .onAppear() {
                    model.loadUrl()
                    
                }
        }
        .padding()
    }
}

final class SwiftUIWebViewModel: ObservableObject {
    
    // @Published var urlString = ""
    
    let webView: WKWebView
    
    init() {
        webView = WKWebView(frame: .zero)
    }
    
    func loadUrl() {
        let url = Bundle.main.url(forResource: "tou", withExtension: "html")
        if var urlString = url?.absoluteString {
            //  Handle web view
            
        }
    }
}

struct SwiftUIWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}
