//
//  OpenAIConnector.swift
//  AI-dvisor
//
//  Created by Leyendecker, Lauren S on 3/27/25.
//

import OpenAI
import Foundation

class OpenAIConnector {
    let apiKey: String
    let openAI: OpenAI
    
    init() {
        apiKey = "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"
        
        openAI = OpenAI(apiToken: apiKey)
    }
    
    func receiveMessage(message: String) {
        
    }
    
    func generateResponse(message: String) {
        
    }
    
    func sendResponse(response: String) {
        
    }
}
