//
//  WebView.swift
//  HTMLPostAutoSubmitPOC
//
//  Created by Boriss Melikjan on 19.11.2024.
//


import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let htmlURL: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        print("htmlURL updated to: \(htmlURL)")
        uiView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
    }
}
