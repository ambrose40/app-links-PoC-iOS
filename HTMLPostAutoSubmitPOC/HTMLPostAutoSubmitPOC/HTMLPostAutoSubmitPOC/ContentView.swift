//
//  ContentView.swift
//  HTMLPostAutoSubmitPOC
//
//  Created by Boriss Melikjan on 19.11.2024.
//

import SwiftUI
import GCDWebServer

var webServer: GCDWebServer?

// HTML content
let htmlContent = """
<!DOCTYPE html>
<html>
<head>
    <title>Sample HTML Page</title>
</head>
<body onload='document.forms[0].submit()'>
    <h1>test</h1>
    <p>Updated at \(Date())</p>
    <form action='https://test-echo.free.beeceptor.com' method='post'>
        <input type='hidden' name='param1' value='value1'>
        <input type='hidden' name='param2' value='value2'>
    </form>
    <!-- Fallback if JavaScript is disabled -->
    <noscript>
        <p>Please click submit to continue:</p>
        <input type='submit' value='Submit'>
    </noscript>
</body>
</html>
"""

let fileName = "GeneratedPage.html"
let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

struct ContentView: View {
    
    @State private var showWebView = false
    @State private var htmlURL: URL?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button(action: generateAndOpenHTMLServer) {
                Text("HTML with local server and open in Safari")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: generateAndOpenHTMLWebView) {
                Text("HTML with WebView and open in Safari")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $showWebView) {
            WebView(htmlURL: fileURL)
        }
    }
    
    func generateAndOpenHTMLWebView() {
        do {
            try htmlContent.write(to: fileURL, atomically: true, encoding: .utf8)
            DispatchQueue.main.async {
                self.htmlURL = fileURL
                self.showWebView = true
            }
        } catch {
            print("Error writing HTML to file: \(error.localizedDescription)")
        }
        
        print("showWebView updated to: \(self.showWebView)")
    }
    
    func generateAndOpenHTMLServer() {
        do {
            // Write HTML content to file
            try htmlContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            stopWebServer() // Ensure previous server is stopped
            
            if let serverURL = startWebServer(withFileAt: fileURL.path) {
                UIApplication.shared.open(serverURL) { success in
                    if success {
                        print("File successfully opened in Safari.")
                    } else {
                        print("Failed to open file in Safari.")
                    }
                }
            } else {
                print("Failed to start web server.")
            }
        } catch {
            print("Error writing HTML to file: \(error.localizedDescription)")
        }
        //        // Stop the server after attempting to open the file
        //        stopWebServer()
    }
    
    func startWebServer(withFileAt filePath: String) -> URL? {
        webServer = GCDWebServer() // Reinitialize the web server
        guard let server = webServer else { return nil }
        
        server.addGETHandler(forPath: "/", filePath: filePath, isAttachment: false, cacheAge: UInt(UInt8.max), allowRangeRequests:true)
        
        
        try? server.start(options: [
            GCDWebServerOption_AutomaticallySuspendInBackground: false,
            GCDWebServerOption_Port: 8080
        ])
        
        if let serverURL = server.serverURL {
            return serverURL.appendingPathComponent("/")
        }
        
        return nil
    }
    
    func stopWebServer() {
        if let server = webServer, server.isRunning {
            server.stop()
            print("Web server stopped.")
        }
        webServer = nil
    }
}

#Preview {
    ContentView()
}
