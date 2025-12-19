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

class NetworkManager {

    static let shared = NetworkManager()
    private init() {}

    // Generic request function
    func request<T: Decodable>(
        urlString: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
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

        // Authorization token
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

            do {
                print(String.init(data: data, encoding: .utf8))

                let decodedData = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                completion(.success(decodedData))
            } catch {
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
