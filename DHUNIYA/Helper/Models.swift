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
    let video: [String]?
    let youtube_url: [String]?
    let created_date: String
    var likes_count: Int
    var is_liked: Bool?
    let language: String
    var comments_count: Int
    let is_global: Bool?

}

struct CheckUserMobileResponse: Codable {
    let message: String?
    let isLoginWithPassword: Bool
    
    enum CodingKeys: String, CodingKey {
        case message
        case isLoginWithPassword = "is_login_with_password"
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
    let min_withdrawable_amount: Int?
}

struct EditProfileRequest: Codable {
    let username: String?
    let mobile: String?
    let dob: String?
    let gender: String?
}

struct Transaction {
    let type: String
    let amountId: String
    let amount: String
    let closingBalance: String
    let time: String
    let date: String
    let status: String
}

struct BankDetails: Codable {
    let id: Int?
    let account_number: String?
    let user: Int?
    let ifsc: String?
    let bank_name: String?
    let branch: String?
    let account_holder_name: String?
    let is_primary: Bool?
    let order_id: String?
    let cf_status: String?
    let created_by: String?
    let updated_by: String?
    let creation_date: String?
    let updation_date: String?
}
class FeelItem: Codable {
    var id: String
    var title: String
    var description: String?
    var thumbnailImage: String?
    var youtubeVideo: String?
    var videoURL: String?
    var totalLikes: Int?
    var shareCount: Int?  // ✅ Changed from 'let' to 'var'
    var isLiked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case thumbnailImage = "thumbnail_image"
        case youtubeVideo = "youtube_video"
        case videoURL = "video_url"
        case totalLikes = "total_likes"
        case shareCount = "share_count"
        case isLiked = "is_liked"
    }
    
    // Initializer
    init(id: String, title: String, description: String? = nil,
         thumbnailImage: String? = nil, youtubeVideo: String? = nil,
         videoURL: String? = nil, totalLikes: Int? = nil,
         shareCount: Int? = nil, isLiked: Bool? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.thumbnailImage = thumbnailImage
        self.youtubeVideo = youtubeVideo
        self.videoURL = videoURL
        self.totalLikes = totalLikes
        self.shareCount = shareCount
        self.isLiked = isLiked
    }
}


// ReferralUser.swift
struct ReferralUser: Codable {
    let id: Int
    let username: String
    let joinedDate: String
    let fullName: String
    let mobileNumber: String
    let profileImageURL: String?
}
struct EmptyInfo: Decodable {}


struct NewsPayload: Codable {
    let title: String
    let description: String
    let city: [String]
    let district: [String]
    let language: String
    let categories: [String]
    let image: [String]
}

    
extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}


class UserSession {
    static let shared = UserSession()
    
    private init() {}

    var reporterId: Int?
    var reporterName: String?
}
struct FileUploadResponse: Codable {
    let success: Bool
    let errorCode: Int
    let description: String
    let total: Int
    let info: [String]
}

struct ShareFeelRequest: Encodable {
    let feel_id: String
}
struct ReporterProfile: Codable {
    let reporterName: String
    let about: String
    let languages: [String]
    let location: String
    let submittedNewsCount: Int
    let approvedNewsCount: Int
    let viewsCount: Int
    let likesCount: Int
    let sharesCount: Int
    let commentsCount: Int
    let whatsappSharesCount: Int
    let rank: Int
    let currentEarnings: Double
    let cashouts: Double

    enum CodingKeys: String, CodingKey {
        case reporterName = "reporter_name"
        case about
        case languages
        case location
        case submittedNewsCount = "submitted_news_count"
        case approvedNewsCount = "approved_news_count"
        case viewsCount = "views_count"
        case likesCount = "likes_count"
        case sharesCount = "shares_count"
        case commentsCount = "comments_count"
        case whatsappSharesCount = "whatsapp_shares_count"
        case rank
        case currentEarnings = "current_earnings"
        case cashouts
    }
}
struct ReporterPost: Codable {
    let id: Int
    let title: String
    let description: String
    let image: [String]?
    let video: [String]?
    let status: String
    let createdDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case image
        case video
        case status
        case createdDate = "created_date"
    }
}
struct ReporterPostsResponse: Codable {
    let success: Bool
    let info: [ReporterPost]
}
struct UserLocation: Codable {
    var country: String?
    var region: String?
    var city: String?
    var cityLatLong: String?
    var userIP: String?
    var requestHeaders: [String: String]?
}
struct LocationResponse: Codable {
    let country: String?
    let region: String?
    let city: String?
    let cityLatLong: String?
    let userIP: String?
}

    enum CodingKeys: String, CodingKey {
        case country, region, city
        case cityLatLong
        case userIP = "userIP"
        case requestHeaders = "request_headers"
    }


// Nested headers object
struct RequestHeaders: Codable {
    let host: String?
    let xForwardedFor: String?
    let xForwardedProto: String?
    let forwarded: String?
    let authorization: String?
    let userAgent: String?
    let postmanToken: String?
    let xCloudTraceContext: String?
    let xAppengineCitylatlong: String?
    let xAppengineRegion: String?
    let xAppengineCountry: String?
    let xAppengineCity: String?
    let traceparent: String?
    let xAppengineTimeoutMs: String?
    let xAppengineHttps: String?
    let xAppengineUserIp: String?
    let xAppengineApiTicket: String?
    let acceptEncoding: String?
    let xAppengineRequestLogId: String?
    let xAppengineDefaultVersionHostname: String?

    enum CodingKeys: String, CodingKey {
        case host
        case xForwardedFor = "x-forwarded-for"
        case xForwardedProto = "x-forwarded-proto"
        case forwarded
        case authorization
        case userAgent = "user-agent"
        case postmanToken = "postman-token"
        case xCloudTraceContext = "x-cloud-trace-context"
        case xAppengineCitylatlong = "x-appengine-citylatlong"
        case xAppengineRegion = "x-appengine-region"
        case xAppengineCountry = "x-appengine-country"
        case xAppengineCity = "x-appengine-city"
        case traceparent
        case xAppengineTimeoutMs = "x-appengine-timeout-ms"
        case xAppengineHttps = "x-appengine-https"
        case xAppengineUserIp = "x-appengine-user-ip"
        case xAppengineApiTicket = "x-appengine-api-ticket"
        case acceptEncoding = "accept-encoding"
        case xAppengineRequestLogId = "x-appengine-request-log-id"
        case xAppengineDefaultVersionHostname = "x-appengine-default-version-hostname"
    }
}
struct HomeResponse: Codable {
    let success: Bool
    let errorCode: Int
    let description: String
    let total: Int
    let info: HomeInfo
}

struct HomeInfo: Codable {
    let banners: [MediaItem]?
    let new_releases: [MediaItem]?
    let trending: [MediaItem]?
}

struct MediaItem: Codable {
    let thumbnail_image: String?
    let cover_image: String?
    let title: String?
    let id: String?
}
struct MovieResponseItem: Codable {
    
    let id: String?
    let title: String?
    let synopsis: String?
    
    let cast: [String]?
    let genres: [String]?
    
    let director_name: String?
    let language: String?
    
    let thumbnail_image: String?
    let cover_image: String?
    
    let movie_data: MovieData?
    let trailer_data: MovieData?
    
    let movie_maker_data: MovieMakerData?
}

struct MovieData: Codable {
    let converted_url: String?
    let video_url: String?
}
struct MovieMakerData: Codable {
    let name: String?
    let logo: String?
    let description: String?
}
struct BannerModel: Decodable {
    let id: Int
    let ref_id: String
    let priority: Int
    let name: String
    let images: [String?]?
    let videos: [String?]?
    let content_type: String
    let banner_type: String
    let status: String
    let date: String?
    let created_date: String
    let created_by: String
    let updation_date: String
    let updated_by: String
}
// MARK:  Send OTP Response
struct SendOtpInfo: Codable {
    var message: String?
    var is_login_with_password: Bool?
    var profile_image: String?
    var username: String?
}

// MARK: Login/Verify OTP Response
struct LoginResponse: Codable {
    let refreshToken: String
    let accessToken: String
    let profileDetails: ProfileDetails?

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
        case profileDetails = "profile_details"
    }
}

// MARK: Profile Details (keep existing, ensure all fields are there)
struct ProfileDetails: Codable {
    let id: Int?
    let full_name: String?
    let username: String?
    var referral_code: String?
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
    let reporterId: String?
    let reporterName: String?
    let name: String?
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
}
struct AdvertisementModel: Codable {
    let id: Int?
    let title: String?
    let description: String?
    let images: [String]?
    let destination_url: String?
    let whatsapp_number: String?
    let mobile_number: String?
    let position: Int?
    let display_type: String?
    let action_title: String?
}

struct AdvertisementResponse: Codable {
    let success: Bool
    let info: [AdvertisementModel]?
}
