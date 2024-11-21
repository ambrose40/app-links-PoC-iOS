//
//  AppDelegate.swift
//  FragmentAppLink
//
//  Created by Boriss Melikjan on 20.11.2024.
//


import UIKit

import GCDWebServer

var webServer: GCDWebServer?

let fileName = "GeneratedPage.html"
let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Check if the URL uses the custom scheme
        if url.scheme == "mypocapp" {
            // Parse the fragment from the URL
            if let fragment = url.fragment {
                print("Fragment: \(fragment)")

                // Store the fragment into a variable
                let authToken = fragment
                print("Auth Token: \(authToken)")
                
                generateAndOpenHTMLServer(withAuthToken:authToken)
            } else {
                print("No fragment found in the URL.")
            }
            return true
        }
        return false
    }
    
    func generateAndOpenHTMLServer(withAuthToken authenticationToken: String) {
        do {
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
                    <input type='hidden' name='authenticationToken' value='\(authenticationToken)'>
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
