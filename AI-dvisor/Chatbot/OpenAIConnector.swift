//
//  OpenAIConnector.swift
//  AI-dvisor
//
//  Created by Leyendecker, Lauren S on 3/27/25.
//

import OpenAI
import Foundation

class OpenAIConnector {
    static let shared = OpenAIConnector()
    private let apiKey = "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"
    
    let openAI: OpenAI
    
    init() {
        openAI = OpenAI(apiToken: apiKey)
    }
    
    func getResponse(input: String, completion: @escaping (String) -> Void) {
        let query = ChatQuery(messages: [.init(role: .user, content: input)!], model: .gpt3_5Turbo)
        
        openAI.chats(query: query) { result in
            switch result {
            case .success(let success):
                let response = success.choices.first?.message.content ?? "No response"
                completion(response)
                
            case .failure(let failure):
                print("Error: \(failure)")
                completion("Sorry, an error occurred. Please try again.")
            }
        }
    }
}
