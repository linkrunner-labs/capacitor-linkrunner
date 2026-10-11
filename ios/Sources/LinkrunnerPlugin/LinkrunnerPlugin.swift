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
        CAPPluginMethod(name: "trackEvent", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getAttributionData", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setAdditionalData", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "enablePIIHashing", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setPushToken", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setCustomerUserId", returnType: CAPPluginReturnPromise),
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

        var payment: EventPayment?
        if let paymentObj = call.getObject("payment") {
            do {
                payment = try convertToEventPayment(paymentObj)
            } catch {
                call.reject(error.localizedDescription)
                return
            }
        }

        Task {
            if #available(iOS 15.0, *) {
                await linkrunner.trackEvent(
                    eventName: eventName,
                    eventData: eventDataDict,
                    eventId: eventId,
                    payment: payment
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
     * Set the push notification token
     */
    @objc func setPushToken(_ call: CAPPluginCall) {
        guard let pushToken = call.getString("pushToken")?.trimmingCharacters(in: .whitespacesAndNewlines),
              !pushToken.isEmpty else {
            call.reject("Push token cannot be empty")
            return
        }

        Task {
            if #available(iOS 15.0, *) {
                await linkrunner.setPushToken(pushToken)
                call.resolve()
            } else {
                call.reject("iOS 15.0 or later is required")
            }
        }
    }

    @objc func setCustomerUserId(_ call: CAPPluginCall) {
        guard let userId = call.getString("userId")?.trimmingCharacters(in: .whitespacesAndNewlines),
              !userId.isEmpty else {
            call.reject("Customer user ID cannot be empty")
            return
        }

        Task {
            if #available(iOS 15.0, *) {
                await linkrunner.setCustomerUserId(userId)
                call.resolve()
            } else {
                call.reject("iOS 15.0 or later is required")
            }
        }
    }

    /**
     * Handle a deeplink for re-engagement attribution
     */
    @objc func handleDeeplink(_ call: CAPPluginCall) {
        guard let deeplinkUrl = call.getString("deeplinkUrl")?.trimmingCharacters(in: .whitespacesAndNewlines),
              !deeplinkUrl.isEmpty else {
            call.resolve()
            return
        }

        Task {
            if #available(iOS 15.0, *) {
                let response = await linkrunner.handleDeeplink(url: deeplinkUrl)
                var data: JSObject = [
                    "isLinkrunner": response.isLinkrunner
                ]
                if let deeplink = response.deeplink {
                    data["deeplink"] = deeplink
                }
                if let processing = response.processing {
                    data["processing"] = processing
                }
                call.resolve(["data": data])
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
     * Convert the JS payment object to a native EventPayment
     */
    private func convertToEventPayment(_ jsObject: JSObject) throws -> EventPayment {
        guard let amount = (jsObject["amount"] as? NSNumber)?.doubleValue else {
            throw paymentError("payment.amount is required")
        }
        guard let paymentId = jsObject["paymentId"] as? String else {
            throw paymentError("payment.paymentId is required")
        }
        guard let currency = jsObject["currency"] as? String else {
            throw paymentError("payment.currency is required")
        }
        var status: PaymentStatus?
        if let statusStr = jsObject["status"] as? String, !statusStr.isEmpty {
            guard let parsed = PaymentStatus(rawValue: statusStr.uppercased()) else {
                throw paymentError("invalid payment status: \(statusStr)")
            }
            status = parsed
        }
        do {
            return try EventPayment(amount: amount, paymentId: paymentId, currency: currency, status: status)
        } catch EventPaymentError.invalidAmount {
            throw paymentError("payment.amount must be a finite number >= 0")
        } catch EventPaymentError.invalidPaymentId {
            throw paymentError("payment.paymentId is required")
        } catch EventPaymentError.invalidCurrency {
            throw paymentError("payment.currency must be a 3-letter ISO 4217 code")
        }
    }

    private func paymentError(_ message: String) -> NSError {
        return NSError(domain: "LinkrunnerPlugin", code: 2, userInfo: [NSLocalizedDescriptionKey: message])
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

        if let gaid = attributionData.gaid {
            data["gaid"] = gaid
        }
        if let idfa = attributionData.idfa {
            data["idfa"] = idfa
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
            if let adNetworkCampaignId = campaignData.adNetworkCampaignId {
                campaignDict["adNetworkCampaignId"] = adNetworkCampaignId
            }
            if let adSetId = campaignData.adSetId {
                campaignDict["adSetId"] = adSetId
            }
            if let adSetName = campaignData.adSetName {
                campaignDict["adSetName"] = adSetName
            }
            if let adCreativeId = campaignData.adCreativeId {
                campaignDict["adCreativeId"] = adCreativeId
            }
            if let adCreativeName = campaignData.adCreativeName {
                campaignDict["adCreativeName"] = adCreativeName
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
