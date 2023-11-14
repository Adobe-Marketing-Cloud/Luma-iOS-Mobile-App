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
                    MobileSDK.shared.sendTrackScreenEvent(stateName: "luma: content: ios: us: en: terms of service")
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
            AEPEdgeIdentity.Identity.getUrlVariables {(urlVariables, error) in
                if let error = error {
                    Logger.aepMobileSDK.error("TermsOfServiceSheet - loadUrl: Error with Webview: \(error.localizedDescription)…")
                    return;
                }
                
                if let urlVariables: String = urlVariables {
                    urlString.append("?" + urlVariables)
                    guard let url = URL(string: urlString) else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.webView.load(URLRequest(url: url))
                    }
                }
                Logger.aepMobileSDK.info("TermsOfServiceSheet - loadUrl: Successfully retrieved urlVariables for WebView, final URL: \(urlString)")
            }
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
