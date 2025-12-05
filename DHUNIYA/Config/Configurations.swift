//
//  Configurations.swift
//  DHUNIYA
//
//  Created by Lifeboat on 28/11/25.
//

import Foundation


private enum BuildConfiguration {
    enum Error: Swift.Error {
        case missingkey, invalidValue
    }
    static func value<T>(for key: String) throws -> T where T : LosslessStringConvertible{
        
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else{
            throw Error.missingkey
        }
        switch object {
        case let string as String:
            guard let value = T(string) else {fallthrough}
            return value
        default:
            throw Error.invalidValue
        }
        
    }
}

enum PLISTVALUES {
    static var baseUrl : String {
        do{
            return try BuildConfiguration.value(for: "server_url")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct API {
    
    static let BASE_URL = PLISTVALUES.baseUrl.replacingOccurrences(of: "%2F", with: "/")
   
    static let SENDOTP = BASE_URL + "userservice/authentication/sendotp"
    static let LOGIN = BASE_URL + "userservice/authentication"
    static let VERIFY_OTP = BASE_URL + "user/authentication/mobile/verify-otp"
    static let SET_PASSWORD = BASE_URL + "user/authentication/set-password"
    static let CREATE_PASSWORD = BASE_URL + "userservice/authentication/password"
    static let RESET_PASSWORD = BASE_URL + "userservice/authentication/password/forgot"
    static let FORGOT_PASSWORD =  BASE_URL + "userservice/authentication/sendotp?is_forgot_password=True"
    static let NEWS_REPORTER_APPLY = BASE_URL + "news/reporter/apply"
    
    static let GET_PROFILE = BASE_URL + "userservice/profile"
    static let EDIT_PROFILE = BASE_URL + "userservice/profile"  // same URL, PUT method for edit
    static let GET_REFERRALS = BASE_URL + "userservice/profile/referral"
    static let UPDATE_REFERRAL_CODE = BASE_URL + "userservice/profile/referral" // POST update referral code

    
    
    
    
    static let NEWS_COMMENTS = BASE_URL + "news/posts/comments"
    static let NEWS_LIKE = BASE_URL + "news/posts/like"
    static let NEWS_DISLIKE = BASE_URL + "news/posts/dislike"


    
}
