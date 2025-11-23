import Foundation

/// Utility for loading and decoding JSON resource files
struct JSONLoader {
    enum LoadError: Error {
        case fileNotFound(String)
        case decodingFailed(String, Error)
    }

    /// Load and decode a JSON file from the main bundle
    static func load<T: Decodable>(_ filename: String, as type: T.Type) -> Result<T, LoadError> {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            return .failure(.fileNotFound("Could not find \(filename).json in bundle"))
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(.decodingFailed("Failed to decode \(filename).json", error))
        }
    }

    /// Load and decode with a default fallback value
    static func loadWithFallback<T: Decodable>(_ filename: String, fallback: T) -> T {
        switch load(filename, as: T.self) {
        case .success(let value):
            return value
        case .failure(let error):
            print("⚠️ JSONLoader error: \(error). Using fallback.")
            return fallback
        }
    }
}

// MARK: - Data Models for JSON Files

/// OnboardingTemplates.json structure
struct OnboardingTemplatesData: Codable {
    let templates: [String: OnboardingTemplate]
}

struct OnboardingTemplate: Codable {
    let goalName: String
    let description: String
    let recommendedCategories: [String]
    let educationalTips: [EducationalTip]
    let initialChallenge: String
}

struct EducationalTip: Codable {
    let category: String
    let tip: String
}

/// Activities.json structure
struct ActivitiesData: Codable {
    let activities: [Activity]
}

struct Activity: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
    let category: String
    let typicalDuration: Int
    let recommendedForGoals: [String]
}

/// Prompts.json structure
struct PromptsData: Codable {
    let prompts: Prompts
}

struct Prompts: Codable {
    let moodDrop: [String]
    let moodImproved: [String]
    let neutral: [String]
    let activitySpecific: [String: [String]]
    let streak: StreakPrompts
    let firstEntry: [String]
}

struct StreakPrompts: Codable {
    let lowMood: [String]
    let highMood: [String]
}
