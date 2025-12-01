//
//  Models.swift
//  DHUNIYA
//
//  Created by Lifeboat on 28/11/25.
//

import Foundation

struct NewsModel: Codable {
    let id: Int
    let title: String
    let description: String
    let image: [String]?       // <-- changed to array
    let created_date: String
    var likes_count: Int
    var is_liked: Bool?
}

struct CheckUserMobileResponse: Codable {
    let message: String
    let isLoginWithPassword: Bool
    let profileImage: String?
    let username: String

    enum CodingKeys: String, CodingKey {
        case message
        case isLoginWithPassword = "is_login_with_password"
        case profileImage = "profile_image"
        case username
    }
}

struct LoginResponse: Codable {
    let isSetPassword: Bool
    let refreshToken: String
    let accessToken: String
    let profileDetails: ProfileDetails

    enum CodingKeys: String, CodingKey {
        case isSetPassword = "is_set_password"
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
        case profileDetails = "profile_details"
    }
}

struct ProfileDetails: Codable {
    let id: Int
    let password: String
    let lastLogin: String?
    let isSuperuser: Bool
    let fullName: String
    let username: String
    let profileImage: String
    let email: String?
    let mobile: Int64
    let gender: String
    let dob: String
    let deviceId: String
    let fcmId: String
    let userStatus: String
    let earnings: Double
    let totalEarnings: Double
    let referralCode: String
    let canChangeReferralCode: Bool
    let canChangeUsername: Bool
    let userRole: [String]
    let isActive: Bool
    let isStaff: Bool
    let customPermissions: [String]
    let state: String?
    let district: String?
    let mandal: String?
    let village: String?
    let city: String?
    let newDistrict: String?
    let createdBy: String
    let updatedBy: String
    let groups: [String]
    let userPermissions: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case password
        case lastLogin = "last_login"
        case isSuperuser = "is_superuser"
        case fullName = "full_name"
        case username
        case profileImage = "profile_image"
        case email
        case mobile
        case gender
        case dob
        case deviceId = "device_id"
        case fcmId = "fcm_id"
        case userStatus = "user_status"
        case earnings
        case totalEarnings = "total_earnings"
        case referralCode = "referral_code"
        case canChangeReferralCode = "can_change_referral_code"
        case canChangeUsername = "can_change_username"
        case userRole = "user_role"
        case isActive = "is_active"
        case isStaff = "is_staff"
        case customPermissions = "custom_permissions"
        case state
        case district
        case mandal
        case village
        case city
        case newDistrict = "new_district"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case groups
        case userPermissions = "user_permissions"
    }
}
struct LikeResponse: Codable {
    let success: Bool
    let errorCode: Int
    let description: String
    let total: Int
    let info: LikeInfo?
}

struct LikeInfo: Codable {
    let message: String
}
struct DislikeResponse: Codable {
    let success: Bool
    let errorCode: Int
    let description: String
    let total: Int
    let info: DislikeInfo?
}

struct DislikeInfo: Codable {
    let message: String
}

struct CommentModel: Codable {
    let comment_id: String
    let created_date: String
    let updation_date: String?      
    let user_master_id: String
    let username: String?
    let profile_image: String?
    let comment: String
    let parent_comment_id: String?
    let child_comment_count: Int
    let created_by: String?
    let updated_by: String?
    let news: Int
}

struct CommentResponse: Codable {
    let message: String?
}
struct SendOtpResponse: Codable {
    let success: Bool
    let errorCode: Int
    let description: String
    let total: Int?
    let info: SendOtpInfo?
}

struct SendOtpInfo: Codable {
    let message: String?
    let isLoginWithPassword: Bool?
    let profileImage: String?
    let username: String?
    
    private enum CodingKeys: String, CodingKey {
        case message
        case isLoginWithPassword = "is_login_with_password"
        case profileImage = "profile_image"
        case username
    }
}
struct VerifyInfo: Codable {
    var access_token = ""
    var refresh_token = ""
    var is_set_password = false
    
    init(json: [String: Any]) {
        if let token = json["access_token"] as? String { self.access_token = token }
        if let token = json["refresh_token"] as? String { self.refresh_token = token }
        if let isSet = json["is_set_password"] as? Bool { self.is_set_password = isSet }
    }
}
struct ForgotPasswordResponse: Codable {
    let success: Bool
    let description: String?
    let info: ProfileDetails?
}
var isForgotPasswordFlow = false

struct CreatePasswordResponse: Codable {
    let success: Bool
    let description: String?
    let info: ProfileDetails?
}
extension Notification.Name {
    static let login = Notification.Name("login")
    static let dismissLoginPopups = Notification.Name("dismiss_login_popups")
}
