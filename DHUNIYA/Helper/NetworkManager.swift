//
//  NetworkManager.swift
//  DHUNIYA
//
//  Created by Lifeboat on 28/11/25.
//

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

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    /// this method will be used to connect to server and gibves us res[onse back
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
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        if let parameters = parameters, method == .POST || method == .PUT {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
                return
            }
        }
        if let at = UserDefaults.standard.string(forKey: "accesstoken") {
            request.setValue("Bearer \(at)", forHTTPHeaderField: "Authorization")
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
                print(String.init(data: data, encoding: .utf8) ?? "-----")
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...399).contains(httpResponse.statusCode)  {
                        print("✅ Success: Status code is \(httpResponse.statusCode)")
                        let decodedData = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                        completion(.success(decodedData))
                    }else {
                        if httpResponse.statusCode == 401 {
                            completion(.failure(.noaccess))
                        }else{
                            print("❌ Error: Status code is \(httpResponse.statusCode)")
                            completion(.failure(.noData))
                        }
                    }
                }
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }
}



struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let errorCode: Int
    let total : Int?
    let description: String
    let info: T?
}



class Session {
    static let shared = Session()
    
    
    var isUserLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: "isUserLoggedIn") }
        set { UserDefaults.standard.set(newValue, forKey: "isUserLoggedIn") }
    }
    
    var mobileNumber: String {
        get { UserDefaults.standard.string(forKey: "mobileNumber") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "mobileNumber") }
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
        get { UserDefaults.standard.value(forKey: "userroles") as! [String] }
        set { UserDefaults.standard.set(newValue, forKey: "userroles") }
    }
}
