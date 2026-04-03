import Foundation
import Capacitor
import LinkrunnerKit

/**
 * Capacitor plugin for Linkrunner SDK
 * Provides a bridge between JavaScript/TypeScript and the native iOS Linkrunner SDK
 */
@objc(LinkrunnerPlugin)
public class LinkrunnerPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "LinkrunnerPlugin"
    public let jsName = "Linkrunner"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "init", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "signup", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setUserData", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "capturePayment", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "removePayment", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "trackEvent", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getAttributionData", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setAdditionalData", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "enablePIIHashing", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "handleDeeplink", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPackageVersion", returnType: CAPPluginReturnPromise)
    ]
    
    private var linkrunner: LinkrunnerSDK {
        return LinkrunnerSDK.shared
    }
    
    // MARK: - Initialization
    
    /**
     * Initialize the Linkrunner SDK
     */
    @objc func `init`(_ call: CAPPluginCall) {
        guard let token = call.getString("token"), !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            call.reject("Token is required")
            return
        }
        
        let secretKey = call.getString("secretKey")
        let keyId = call.getString("keyId")
        let disableIdfa = call.getBool("disableIdfa") ?? false
        let debug = call.getBool("debug") ?? false
        
        // Initialize the SDK asynchronously
        Task {
            if #available(iOS 15.0, *) {
                await linkrunner.initialize(
                    token: token,
                    secretKey: secretKey,
                    keyId: keyId,
                    disableIdfa: disableIdfa,
                    debug: debug
                )
                call.resolve()
            } else {
                call.reject("iOS 15.0 or later is required")
            }
        }
    }
    
    // MARK: - User Management
    
    /**
     * Register a new user signup
     */
    @objc func signup(_ call: CAPPluginCall) {
        guard let userDataObj = call.getObject("userData") else {
            call.reject("userData is required")
            return
        }
        
        do {
            let userData = try convertToUserData(userDataObj)
            let additionalData = call.getObject("data")
            let additionalDataDict = additionalData != nil ? convertJSObjectToDict(additionalData!) : nil
            
            Task {
                if #available(iOS 15.0, *) {
                    await linkrunner.signup(userData: userData, additionalData: additionalDataDict)
                    call.resolve()
                } else {
                    call.reject("iOS 15.0 or later is required")
                }
            }
        } catch {
            call.reject("Failed to convert user data: \(error.localizedDescription)")
        }
    }
    
    /**
     * Update user data
     */
    @objc func setUserData(_ call: CAPPluginCall) {
        guard let userDataObj = call.getObject("userData") else {
            call.reject("userData is required")
            return
        }
        
        do {
            let userData = try convertToUserData(userDataObj)
            
            Task {
                if #available(iOS 15.0, *) {
                    await linkrunner.setUserData(userData)
                    call.resolve()
                } else {
                    call.reject("iOS 15.0 or later is required")
                }
            }
        } catch {
            call.reject("Failed to convert user data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Payment Tracking
    
    /**
     * Capture a payment event
     */
    @objc func capturePayment(_ call: CAPPluginCall) {
        guard let userId = call.getString("userId"), !userId.isEmpty else {
            call.reject("userId is required")
            return
        }
        
        guard let amount = call.getDouble("amount") else {
            call.reject("amount is required")
            return
        }
        
        let paymentId = call.getString("paymentId")
        let typeStr = call.getString("type") ?? "DEFAULT"
        let statusStr = call.getString("status") ?? "PAYMENT_COMPLETED"
        
        let type = convertToPaymentType(typeStr)
        let status = convertToPaymentStatus(statusStr)
        
        Task {
            if #available(iOS 15.0, *) {
                await linkrunner.capturePayment(
                    amount: amount,
                    userId: userId,
                    paymentId: paymentId,
                    type: type,
                    status: status
                )
                call.resolve()
            } else {
                call.reject("iOS 15.0 or later is required")
            }
        }
    }
    
    /**
     * Remove a payment event
     */
    @objc func removePayment(_ call: CAPPluginCall) {
        guard let userId = call.getString("userId"), !userId.isEmpty else {
            call.reject("userId is required")
            return
        }
        
        let paymentId = call.getString("paymentId")
        
        Task {
            if #available(iOS 15.0, *) {
                await linkrunner.removePayment(userId: userId, paymentId: paymentId)
                call.resolve()
            } else {
                call.reject("iOS 15.0 or later is required")
            }
        }
    }
    
    // MARK: - Event Tracking and Attribution
    
    /**
     * Track a custom event
     */
    @objc func trackEvent(_ call: CAPPluginCall) {
        guard let eventName = call.getString("eventName"), !eventName.isEmpty else {
            call.reject("eventName is required")
            return
        }
        
        let eventData = call.getObject("eventData")
        let eventDataDict = eventData != nil ? convertJSObjectToDict(eventData!) : nil
        let eventId = call.getString("eventId")
        
        Task {
            if #available(iOS 15.0, *) {
                await linkrunner.trackEvent(
                    eventName: eventName,
                    eventData: eventDataDict,
                    eventId: eventId
                )
                call.resolve()
            } else {
                call.reject("iOS 15.0 or later is required")
            }
        }
    }
    
    /**
     * Get attribution data
     */
    @objc func getAttributionData(_ call: CAPPluginCall) {
        Task {
            if #available(iOS 15.0, *) {
                let attributionData = await linkrunner.getAttributionData()
                let result = convertAttributionDataToJSObject(attributionData)
                call.resolve(result)
            } else {
                call.reject("iOS 15.0 or later is required")
            }
        }
    }
    
    /**
     * Set additional integration data
     */
    @objc func setAdditionalData(_ call: CAPPluginCall) {
        guard let integrationDataObj = call.getObject("integrationData") else {
            call.reject("integrationData is required")
            return
        }
        
        let integrationData = convertToIntegrationData(integrationDataObj)
        
        Task {
            if #available(iOS 15.0, *) {
                await linkrunner.setAdditionalData(integrationData)
                call.resolve()
            } else {
                call.reject("iOS 15.0 or later is required")
            }
        }
    }
    
    /**
     * Enable or disable PII hashing
     */
    @objc func enablePIIHashing(_ call: CAPPluginCall) {
        let enabled = call.getBool("enabled") ?? true
        
        if #available(iOS 15.0, *) {
            linkrunner.enablePIIHashing(enabled)
            call.resolve()
        } else {
            call.reject("iOS 15.0 or later is required")
        }
    }
    
    /**
     * Handle a deeplink for re-engagement attribution
     * Call this method when the app is opened via a deeplink, regardless of app state
     */
    @objc func handleDeeplink(_ call: CAPPluginCall) {
        let deeplinkUrl = call.getString("deeplinkUrl")
        
        // Handle empty URLs gracefully (matches SDK behavior)
        if deeplinkUrl == nil || deeplinkUrl!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            call.resolve()
            return
        }
        
        Task {
            if #available(iOS 15.0, *) {
                await linkrunner.handleDeeplink(url: deeplinkUrl)
                call.resolve()
            } else {
                call.reject("iOS 15.0 or later is required")
            }
        }
    }
    
    /**
     * Get the package version
     */
    @objc func getPackageVersion(_ call: CAPPluginCall) {
        // Read version from package.json or return a default
        let version = "0.0.1" // This will be replaced with actual version reading logic
        call.resolve(["version": version])
    }
}


// MARK: - Type Conversion Helpers

extension LinkrunnerPlugin {
    /**
     * Convert JSObject to UserData
     */
    private func convertToUserData(_ jsObject: JSObject) throws -> UserData {
        guard let id = jsObject["id"] as? String, !id.isEmpty else {
            throw NSError(domain: "LinkrunnerPlugin", code: 1, userInfo: [NSLocalizedDescriptionKey: "User id is required"])
        }
        
        return UserData(
            id: id,
            name: jsObject["name"] as? String,
            phone: jsObject["phone"] as? String,
            email: jsObject["email"] as? String,
            isFirstTimeUser: jsObject["is_first_time_user"] as? Bool,
            userCreatedAt: jsObject["user_created_at"] as? String,
            mixPanelDistinctId: jsObject["mixpanel_distinct_id"] as? String,
            amplitudeDeviceId: jsObject["amplitude_device_id"] as? String,
            posthogDistinctId: jsObject["posthog_distinct_id"] as? String,
            brazeDeviceId: jsObject["braze_device_id"] as? String,
            gaAppInstanceId: jsObject["ga_app_instance_id"] as? String,
            gaSessionId: jsObject["ga_session_id"] as? String,
            netcoreDeviceGuid: jsObject["netcore_device_guid"] as? String
        )
    }
    
    /**
     * Convert JSObject to dictionary
     */
    private func convertJSObjectToDict(_ jsObject: JSObject) -> SendableDictionary {
        var dict: SendableDictionary = [:]
        for (key, value) in jsObject {
            dict[key] = value
        }
        return dict
    }
    
    /**
     * Convert string to PaymentType enum
     */
    private func convertToPaymentType(_ typeStr: String) -> PaymentType {
        switch typeStr.uppercased() {
        case "FIRST_PAYMENT":
            return .firstPayment
        case "WALLET_TOPUP":
            return .walletTopup
        case "FUNDS_WITHDRAWAL":
            return .fundsWithdrawal
        case "SUBSCRIPTION_CREATED":
            return .subscriptionCreated
        case "SUBSCRIPTION_RENEWED":
            return .subscriptionRenewed
        case "ONE_TIME":
            return .oneTime
        case "RECURRING":
            return .recurring
        default:
            return .default
        }
    }
    
    /**
     * Convert string to PaymentStatus enum
     */
    private func convertToPaymentStatus(_ statusStr: String) -> PaymentStatus {
        switch statusStr.uppercased() {
        case "PAYMENT_INITIATED":
            return .initiated
        case "PAYMENT_FAILED":
            return .failed
        case "PAYMENT_CANCELLED":
            return .cancelled
        default:
            return .completed
        }
    }
    
    /**
     * Convert JSObject to IntegrationData
     */
    private func convertToIntegrationData(_ jsObject: JSObject) -> IntegrationData {
        return IntegrationData(
            clevertapId: jsObject["clevertapId"] as? String
        )
    }
    
    /**
     * Convert AttributionData to JSObject
     */
    private func convertAttributionDataToJSObject(_ attributionData: LRAttributionDataResponse) -> JSObject {
        var result: JSObject = [:]
        var data: JSObject = [:]
        
        // Add deeplink if present
        if let deeplink = attributionData.deeplink {
            data["deeplink"] = deeplink
        }
        
        // Convert campaign data if present
        if let campaignData = attributionData.campaignData {
            var campaignDict: JSObject = [:]
            campaignDict["id"] = campaignData.id
            campaignDict["name"] = campaignData.name
            campaignDict["type"] = campaignData.type.rawValue
            
            // Add optional fields
            if let adNetwork = campaignData.adNetwork {
                campaignDict["adNetwork"] = adNetwork.rawValue
            }
            if let groupName = campaignData.groupName {
                campaignDict["groupName"] = groupName
            }
            if let assetName = campaignData.assetName {
                campaignDict["assetName"] = assetName
            }
            if let assetGroupName = campaignData.assetGroupName {
                campaignDict["assetGroupName"] = assetGroupName
            }
            
            // Format dates
            let dateFormatter = ISO8601DateFormatter()
            if let installedAt = campaignData.installedAt {
                campaignDict["installedAt"] = dateFormatter.string(from: installedAt)
            }
            if let storeClickAt = campaignData.storeClickAt {
                campaignDict["storeClickAt"] = dateFormatter.string(from: storeClickAt)
            }
            
            data["campaignData"] = campaignDict
        }
        
        result["data"] = data
        return result
    }
}
