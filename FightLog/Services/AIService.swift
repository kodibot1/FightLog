import Foundation

struct AIDrill: Codable {
    let name: String
    let description: String
    let combos: [String]?
}

struct AISessionAnalysis: Codable {
    let sessionType: String?
    let duration: Int?
    let intensity: String?
    let techniques: [String]
    let combos: [String]
    let drills: [AIDrill]?
    let wentWell: String?
    let toImprove: String?
    let followUpQuestions: [String]
}

struct QuickContext {
    let sessionType: SessionType
    let duration: Int
    let intensity: Intensity?
    let didSpar: Bool
}

struct AINextQuestion: Codable {
    let question: String
    let isComplete: Bool
}

struct ConversationTurn {
    let question: String
    let answer: String // empty if skipped
}

@MainActor
class AIService {
    static let shared = AIService()

    private let apiKeyKey = "claude_api_key"

    var apiKey: String? {
        get { UserDefaults.standard.string(forKey: apiKeyKey) }
        set { UserDefaults.standard.set(newValue, forKey: apiKeyKey) }
    }

    var hasAPIKey: Bool {
        guard let key = apiKey else { return false }
        return !key.isEmpty
    }

    func analyzeTrainingDescription(
        _ text: String,
        techniqueNames: [String],
        comboNames: [String],
        userContext: String?
    ) async throws -> AISessionAnalysis {
        guard let apiKey, !apiKey.isEmpty else {
            throw AIServiceError.noAPIKey
        }

        let systemPrompt = buildSystemPrompt(
            techniqueNames: techniqueNames,
            comboNames: comboNames,
            userContext: userContext
        )

        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-5-20250929",
            "max_tokens": 1536,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": text]
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = jsonData
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIServiceError.apiError(statusCode: httpResponse.statusCode, message: body)
        }

        return try parseResponse(data)
    }

    // MARK: - Guided Recall

    func generateNextQuestion(
        quickContext: QuickContext,
        conversationSoFar: [ConversationTurn],
        techniqueNames: [String],
        comboNames: [String],
        userContext: String?
    ) async throws -> AINextQuestion {
        guard let apiKey, !apiKey.isEmpty else {
            throw AIServiceError.noAPIKey
        }

        let systemPrompt = buildQuestionPrompt(
            quickContext: quickContext,
            techniqueNames: techniqueNames,
            comboNames: comboNames,
            userContext: userContext
        )

        // Build conversation history for context
        var conversationText = "Session context: \(quickContext.sessionType.rawValue), \(quickContext.duration) min, \(quickContext.intensity?.rawValue ?? "unspecified") intensity"
        conversationText += quickContext.didSpar ? ". They DID spar." : ". They did NOT spar - do NOT ask about sparring."
        conversationText += "\n\nConversation so far:"
        for turn in conversationSoFar {
            conversationText += "\nQ: \(turn.question)"
            if turn.answer.isEmpty {
                conversationText += "\nA: [skipped]"
            } else {
                conversationText += "\nA: \(turn.answer)"
            }
        }

        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-5-20250929",
            "max_tokens": 256,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": conversationText]
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = jsonData
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            if let httpResponse = response as? HTTPURLResponse {
                throw AIServiceError.apiError(statusCode: httpResponse.statusCode, message: body)
            }
            throw AIServiceError.invalidResponse
        }

        return try parseQuestionResponse(data)
    }

    func assembleSessionFromConversation(
        quickContext: QuickContext,
        conversation: [ConversationTurn],
        techniqueNames: [String],
        comboNames: [String],
        userContext: String?
    ) async throws -> AISessionAnalysis {
        guard let apiKey, !apiKey.isEmpty else {
            throw AIServiceError.noAPIKey
        }

        let systemPrompt = buildSystemPrompt(
            techniqueNames: techniqueNames,
            comboNames: comboNames,
            userContext: userContext
        )

        // Build full transcript from quick context + conversation
        var transcript = "Session basics: \(quickContext.sessionType.rawValue) session, \(quickContext.duration) minutes, \(quickContext.intensity?.rawValue ?? "unspecified") intensity."
        if quickContext.didSpar {
            transcript += " Included sparring."
        }
        transcript += "\n\nDetailed recall interview:"
        for turn in conversation {
            transcript += "\nQ: \(turn.question)"
            if !turn.answer.isEmpty {
                transcript += "\nA: \(turn.answer)"
            }
        }

        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-5-20250929",
            "max_tokens": 1536,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": transcript]
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = jsonData
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            if let httpResponse = response as? HTTPURLResponse {
                throw AIServiceError.apiError(statusCode: httpResponse.statusCode, message: body)
            }
            throw AIServiceError.invalidResponse
        }

        return try parseResponse(data)
    }

    // MARK: - Prompts

    private func buildQuestionPrompt(
        quickContext: QuickContext,
        techniqueNames: [String],
        comboNames: [String],
        userContext: String?
    ) -> String {
        var prompt = """
        You help a boxer recall what they did in their training session so they can log it. Ask ONE short question at a time about what actually happened - you are just helping them remember, NOT coaching or giving tips.

        IMPORTANT: Respond with ONLY a JSON object, no other text:
        {
          "question": "Your follow-up question here",
          "isComplete": false
        }

        Example questions (pick based on what's not been covered yet):
        - "What did you do for warmup?"
        - "Did you do any pad work or bag work?"
        - "What drills did coach have you do?"
        - "Did you work with a partner on anything?"
        - "Any combos you remember drilling?"
        - "How did sparring go? Any specific rounds stand out?"
        - "Anything else happen in the session?"

        Rules:
        - ONLY ask about what they DID in the session - don't give advice or tips
        - Keep questions casual and short, like a friend asking about their day
        - Focus on helping them walk through the session chronologically (warmup → drills → main work → cooldown)
        - The session context tells you if they sparred or not - NEVER ask about sparring if they said they didn't
        - After 3-5 questions or when they've covered the main parts of the session, set isComplete to true
        - Don't repeat topics already covered
        - Don't ask about things already answered in the session context (type, duration, intensity, sparring)
        """

        if let userContext {
            prompt += "\n\n\(userContext)"
        }

        return prompt
    }

    private func parseQuestionResponse(_ data: Data) throws -> AINextQuestion {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw AIServiceError.invalidResponse
        }

        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleaned.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        return try JSONDecoder().decode(AINextQuestion.self, from: jsonData)
    }

    private func buildSystemPrompt(
        techniqueNames: [String],
        comboNames: [String],
        userContext: String?
    ) -> String {
        var prompt = """
        You are a combat sports training assistant. Given the user's description of their training session, extract structured data.

        IMPORTANT: Respond with ONLY a JSON object, no other text. The JSON must have this exact structure:
        {
          "sessionType": "Class" | "Sparring" | "Drilling" | "Bag Work" | "Pad Work" | "Shadow Boxing" | null,
          "duration": <minutes as integer or null>,
          "intensity": "Light" | "Moderate" | "Hard" | null,
          "techniques": ["technique1", "technique2"],
          "combos": ["1-2-3", "1-2"],
          "drills": [
            {"name": "Warmup", "description": "Jump rope 3 rds, shadow boxing", "combos": []},
            {"name": "Pad Work", "description": "1-2 × 2 reps, 1-2-3 hip rotation × 2 reps. 3 rds", "combos": ["1-2", "1-2-3"]},
            {"name": "Bag Work", "description": "1-2-7 on heavy bag. 3 rds", "combos": ["1-2-7"]},
            {"name": "Conditioning", "description": "Burpees, push-ups, abs", "combos": []}
          ],
          "wentWell": "brief summary of what went well" or null,
          "toImprove": "brief summary of what to improve" or null,
          "followUpQuestions": ["question1"]
        }

        Match techniques against the user's known techniques (fuzzy match OK):
        \(techniqueNames.joined(separator: ", "))

        Match combos against the user's known combos (fuzzy match OK):
        \(comboNames.joined(separator: ", "))

        Rules:
        - Only include techniques/combos that the user actually mentioned or clearly implied
        - Use exact names from the known lists when there's a match
        - For combos, use the number format (e.g., "1-2-3" not "jab cross hook")
        - If the user doesn't mention something, use null or empty array
        - Keep followUpQuestions to 1-2 max, only for clearly missing important info
        - Be concise in wentWell and toImprove

        DRILL RULES:
        - Break the session into chronological drills/phases (warmup, pad work, bag work, sparring, conditioning, cooldown, etc.)
        - Only include phases the user actually mentioned - do NOT fabricate warmup/cooldown if not discussed
        - Each drill needs a descriptive name, what was done, and which combos were used in that drill
        - Use combo number format in the combos array (e.g. "1-2-3")
        - CLEAN UP the description - don't copy user's messy text. Rewrite as short combo-focused notes
        - Use terse format: "1 × 2 reps, 1-2 slip × 2 reps, 1-2-7-3-2. 5 min each, swap."
        - Reference combos by number, add reps/rounds/time. No prose or full sentences. Keep it scannable.
        - Pull ALL combos into the combos array using number format - the description is the quick reference, the array is the definitive list
        """

        if let userContext {
            prompt += "\n\n\(userContext)"
        }

        return prompt
    }

    private func parseResponse(_ data: Data) throws -> AISessionAnalysis {
        // Parse the Claude API response to get the text content
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw AIServiceError.invalidResponse
        }

        // Clean the text - remove markdown code fences if present
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleaned.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(AISessionAnalysis.self, from: jsonData)
    }
}

enum AIServiceError: LocalizedError {
    case noAPIKey
    case invalidResponse
    case apiError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key configured. Add your Claude API key in settings."
        case .invalidResponse:
            return "Couldn't understand the AI response. Try again."
        case .apiError(let code, let message):
            if code == 401 {
                return "Invalid API key. Check your key in settings."
            }
            return "API error (\(code)): \(message)"
        }
    }
}
