//
//  NetworkManager.swift
//  DHUNIYA
//
//  Created by Lifeboat on 28/11/25.
//
import UIKit
import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case noaccess
    case unauthorized
    case decodingError(String)
    case serverError(String)
}

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let errorCode: Int
    let total: Int?
    let description: String
    let info: T?

    enum CodingKeys: String, CodingKey {
        case success, errorCode, description, total, info
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try container.decode(Int.self, forKey: .errorCode)
        description = try container.decode(String.self, forKey: .description)
        total = try? container.decode(Int.self, forKey: .total)
        info = try? container.decodeIfPresent(T.self, forKey: .info)
    }
}

// Error response from API
struct APIErrorResponse: Decodable {
    let detail: String?
    let code: String?
}

class NetworkManager {

    static let shared = NetworkManager()
    private init() {}

    // Generic request function
    func request<T: Decodable>(
        urlString: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        requiresAuth: Bool = true,  // NEW: Control auth requirement
        completion: @escaping (Result<APIResponse<T>, NetworkError>) -> Void
    ) {
        guard var urlComponents = URLComponents(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        if method == .GET, let parameters = parameters {
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }

        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        // Body for POST / PUT
        if let parameters = parameters, method == .POST || method == .PUT {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
                return
            }
        }

        // ✅ FIX: Only add Authorization header if token exists and is not empty
        if requiresAuth {
            let token = Session.shared.accesstoken
            if !token.isEmpty {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            // If token is empty and auth is required, you might want to skip the request
            // or handle it differently based on your app's needs
        }

        print("🌐 API Request: \(method.rawValue) \(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            // Debug print
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Response: \(responseString)")
            }
            
            // Check for HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Status Code: \(httpResponse.statusCode)")
                
                // Handle 401 Unauthorized
                if httpResponse.statusCode == 401 {
                    // Try to decode error response
                    if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                        print("🔒 Auth Error: \(errorResponse.detail ?? "Unauthorized")")
                    }
                    completion(.failure(.unauthorized))
                    return
                }
            }

            do {
                let decodedData = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("❌ Decoding Error: \(error)")
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }

    // Request without auth (for public APIs)
    func requestWithoutAuth<T: Decodable>(
        urlString: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<APIResponse<T>, NetworkError>) -> Void
    ) {
        request(urlString: urlString, method: method, parameters: parameters, requiresAuth: false, completion: completion)
    }
    
    // Raw request for non-standard responses
    func requestRaw<T: Decodable>(
        urlString: String,
        requiresAuth: Bool = false,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // ✅ FIX: Only add token if it exists and is not empty
        if requiresAuth {
            let token = Session.shared.accesstoken
            if !token.isEmpty {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            print("📦 RAW RESPONSE:")
            print(String(data: data, encoding: .utf8) ?? "nil")

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ DECODING ERROR:", error)
                completion(.failure(.decodingError(error.localizedDescription)))
            }

        }.resume()
    }
}

class Session {
    
    static let shared = Session()
    
    var userDetails: ProfileDetails? {
        get {
            if let data = UserDefaults.standard.data(forKey: "userDetails") {
                return try? JSONDecoder().decode(ProfileDetails.self, from: data)
            }
            return nil
        }
        set {
            if let value = newValue, let data = try? JSONEncoder().encode(value) {
                UserDefaults.standard.set(data, forKey: "userDetails")
            } else {
                UserDefaults.standard.removeObject(forKey: "userDetails")
            }
        }
    }
    var profileImage: UIImage? {
        get {
            if let data = UserDefaults.standard.data(forKey: "profileImageData") {
                return UIImage(data: data)
            }
            return nil
        }
        set {
            if let image = newValue,
               let data = image.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(data, forKey: "profileImageData")
            } else {
                UserDefaults.standard.removeObject(forKey: "profileImageData")
            }
        }
    }
    
    var totalEarnings: Double {
            get { UserDefaults.standard.double(forKey: "totalEarnings") }
            set { UserDefaults.standard.set(newValue, forKey: "totalEarnings") }
        }

    var isForgotPasswordFlow = false
    
    var isUserLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: "isUserLoggedIn") }
        set { UserDefaults.standard.set(newValue, forKey: "isUserLoggedIn") }
    }
    
    func logout() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    
    var mobileNumber: String {
        get { UserDefaults.standard.string(forKey: "mobileNumber") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "mobileNumber") }
    }
    var news_language: String {
        get { UserDefaults.standard.string(forKey: "language") ?? "TELUGU" }
        set { UserDefaults.standard.set(newValue, forKey: "language") }
    }
    
    var userName: String {
        get { UserDefaults.standard.string(forKey: "userName") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "userName") }
    }
    
    var accesstoken: String {
        get { UserDefaults.standard.string(forKey: "accesstoken") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "accesstoken") }
    }
    
    var refreshtoken: String {
        get { UserDefaults.standard.string(forKey: "refreshtoken") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "refreshtoken") }
    }
    
    var userroles : [String] {
        get { UserDefaults.standard.array(forKey: "userroles") as? [String] ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "userroles") }
    }
    
    var userLocation: LocationResponse? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "UserLocation") else { return nil }
            return try? JSONDecoder().decode(LocationResponse.self, from: data)
        }
        set {
            if let location = newValue,
               let data = try? JSONEncoder().encode(location) {
                UserDefaults.standard.set(data, forKey: "UserLocation")
            } else {
                UserDefaults.standard.removeObject(forKey: "UserLocation")
            }
        }
    }
    
}
extension NetworkManager {

    func requestRaw<T: Decodable>(
        urlString: String,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Authorization header (same as your request)
        if let token = UserDefaults.standard.string(forKey: "accesstoken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            print("📦 RAW LOCATION RESPONSE:")
            print(String(data: data, encoding: .utf8) ?? "nil")

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ DECODING ERROR:", error)
                completion(.failure(.decodingError(error.localizedDescription)))
            }

        }.resume()
    }
}
