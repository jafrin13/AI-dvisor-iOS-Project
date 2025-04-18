//
//  OpenAIConnector.swift
//  AI-dvisor
//
//  Created by Leyendecker, Lauren S on 3/27/25.
//

import Foundation

class OpenAIConnector {
    static let shared = OpenAIConnector()
    
    private let apiKey = ""
            
    init() {}
    
    // code adapted from https://mrprogrammer.medium.com/integrating-openai-api-into-ios-application-using-swift-42b96614458b
    func getResponse(prompt: String, completion: @escaping (String) -> Void) {
        // URL object with endpoint of OpenAI API for text generation
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        // create URL request with URL object and set HTTP method to POST
        var request = URLRequest(url: url) // configures request we want to send
        request.httpMethod = "POST" // make POST since we want to send data to the server
        
        //
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") // sending a Bearer Token to authenticate ourselves with the API
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // tells server body of our request is JSON-formatted

        // create message to send to OpenAI
        let message: [String: Any] = [
            "role": "user", // specifies that the user is sending the message
            "content": prompt // user input we want response to
        ]
        
        // specify parameters for text generation
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo", // model we want to use
            "messages": [message], // message we want to send/get response for
            "temperature": 0.5, // randomness of the text generation
            "max_tokens": 250 // max number of tokens to generate
        ]

        // create a JSON object with the specified parameters
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        // create data task using URLSession to send HTTP request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // check if an error occurred
            guard error == nil else {
                completion("Sorry, an error occurred. Please try again.")
                return
            }
            
            // check that data was received in the response (response is not empty)
            guard let data = data else {
                completion("Please send a message.")
                return
            }
            
            // check HTTP response is valid (status code 200 means everything is good)
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                // parse JSON data into a dictionary
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]], // get list of all responses returned from the model
                   let message = choices.first?["message"] as? [String: Any], // arbitrarily choose the first response
                   let content = message["content"] as? String { // get the content/text of the response
                    DispatchQueue.main.async {
                        completion(content) // send response in completion handler to display in chatbot screen
                    }
                }
            }
        }
        task.resume() // start the network request
    }
}
