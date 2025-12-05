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
    let message: String?
    let isLoginWithPassword: Bool
    
    enum CodingKeys: String, CodingKey {
        case message
        case isLoginWithPassword = "is_login_with_password"
    }
}

struct LoginResponse: Codable {
    let isSetPassword: Bool
    let refreshToken: String
    let accessToken: String
    let profileDetails: ProfileDetails?

    enum CodingKeys: String, CodingKey {
        case isSetPassword = "is_set_password"
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
        case profileDetails = "profile_details"
    }
}

struct ProfileDetails: Codable {
    let id: Int?
    let full_name: String?
    let username: String?
    let referral_code: String?
    let can_change_referral_code: Bool?
    let profile_image: String?
    let email: String?
    let mobile: Int?
    let earnings: Double?
    let total_earnings: Double?
    let user_role: [String]?
    let can_change_username: Bool?
    let dob: String?
    let gender: String?
    
    // Added fields from API
    let password: String?
    let last_login: String?
    let is_superuser: Bool?
    let device_id: String?
    let fcm_id: String?
    let user_status: String?
    let is_active: Bool?
    let is_staff: Bool?
    let custom_permissions: [String]?
    let state: String?
    let district: String?
    let mandal: String?
    let village: String?
    let city: String?
    let new_district: String?
    let created_by: String?
    let updated_by: String?
    let groups: [String]?
    let user_permissions: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case password
        case last_login
        case is_superuser
        case full_name
        case username
        case profile_image
        case email
        case mobile
        case gender
        case dob
        case device_id
        case fcm_id
        case user_status
        case earnings
        case total_earnings
        case referral_code
        case can_change_referral_code
        case can_change_username
        case user_role
        case is_active
        case is_staff
        case custom_permissions
        case state
        case district
        case mandal
        case village
        case city
        case new_district
        case created_by
        case updated_by
        case groups
        case user_permissions
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
    var access_token: String?
    var refresh_token: String?
    var is_set_password: Bool?
    var referral_code: String?    
}


enum UserRole: String {
    case ENDUSER = "ENDUSER"
    case REPORTER = "REPORTER"
    case NEWSADMIN = "NEWS-ADMIN"
}
struct EmptyResponse: Codable {}

struct NewsReporterApplyInfo: Codable {
    let message: String
}

struct NewsReporterApplyResponse: Codable {
    let success: Bool
    let errorCode: Int
    let description: String
    let total: Int
    let info: NewsReporterApplyInfo
}
struct ProfileResponse: Codable {
    let success: Bool
    let errorCode: Int
    let description: String
    let total: Int
    let info: [ProfileDetails]   // Use ProfileDetails here
}

struct ProfileInfo: Codable {
    let id: Int
    let username: String
    let mobile: Int
    let dob: String?
    let gender: String
}
struct EditProfileRequest: Codable {
    let username: String?
    let mobile: String?
    let dob: String?
    let gender: String?
}
struct FeelItem: Identifiable, Codable, Hashable {
    let id: String
    let youtubeVideo: URL?
    let title: String
    let description: String
    let thumbnailImage: String?
    let likesCount: Int
    let shareCount: Int
    let viewsCount: Int
    let score: Int
    let category: String
    var isLiked: Bool
    
}
