package io.linkrunner.capacitor

import android.util.Log
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import io.linkrunner.sdk.LinkRunner
import io.linkrunner.sdk.models.EventPayment
import io.linkrunner.sdk.models.PaymentStatus
import io.linkrunner.sdk.models.request.UserDataRequest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * Capacitor plugin for Linkrunner SDK
 * Provides a bridge between JavaScript/TypeScript and the native Android Linkrunner SDK
 */
@CapacitorPlugin(name = "Linkrunner")
class LinkrunnerPlugin : Plugin() {

    companion object {
        private const val TAG = "LinkrunnerPlugin"
    }

    private lateinit var linkrunner: LinkRunner
    private val coroutineScope = CoroutineScope(Dispatchers.IO)

    override fun load() {
        super.load()
        // Initialize the Linkrunner SDK instance
        linkrunner = LinkRunner.getInstance()
    }

    /**
     * Initialize the Linkrunner SDK
     */
    @PluginMethod
    fun init(call: PluginCall) {
        val token = call.getString("token")
        val secretKey = call.getString("secretKey")
        val keyId = call.getString("keyId")
        val debug = call.getBoolean("debug", false) ?: false
        val packageVersion = call.getString("packageVersion")

        if (token.isNullOrBlank()) {
            call.reject("INVALID_PARAMETER", "Token is required")
            return
        }

        val context = context
        if (context == null) {
            call.reject("CONTEXT_UNAVAILABLE", "Context is not available")
            return
        }

        // Configure SDK for Capacitor platform
        if (!packageVersion.isNullOrEmpty()) {
            LinkRunner.configureSDK("CAPACITOR", packageVersion)
        }

        // Launch coroutine to call suspend function
        coroutineScope.launch {
            try {
                val result = linkrunner.init(
                    context = context,
                    token = token,
                    link = null,
                    source = null,
                    secretKey = secretKey,
                    keyId = keyId,
                    debug = debug
                )

                if (result.isSuccess) {
                    call.resolve()
                } else {
                    val exception = result.exceptionOrNull()
                    Log.e(TAG, "Init failed", exception)
                    call.reject("INIT_FAILED", exception?.message ?: "Initialization failed")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Init failed", e)
                call.reject("INIT_FAILED", e.message ?: "Initialization failed")
            }
        }
    }

    /**
     * Register a new user signup
     */
    @PluginMethod
    fun signup(call: PluginCall) {
        val userDataObj = call.getObject("userData")
        val additionalData = call.getObject("data")

        if (userDataObj == null) {
            call.reject("INVALID_PARAMETER", "userData is required")
            return
        }

        try {
            val userData = convertToUserDataRequest(userDataObj)
            val dataMap = additionalData?.let { convertJSObjectToMap(it) }

            coroutineScope.launch {
                try {
                    val result = linkrunner.signup(userData, dataMap)

                    if (result.isSuccess) {
                        call.resolve()
                    } else {
                        val exception = result.exceptionOrNull()
                        Log.e(TAG, "Signup failed", exception)
                        call.reject("SIGNUP_FAILED", exception?.message ?: "Signup failed")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Signup failed", e)
                    call.reject("SIGNUP_FAILED", e.message ?: "Signup failed")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to convert user data", e)
            call.reject("DATA_CONVERSION_FAILED", e.message ?: "Failed to convert user data")
        }
    }

    /**
     * Update user data
     */
    @PluginMethod
    fun setUserData(call: PluginCall) {
        val userDataObj = call.getObject("userData")

        if (userDataObj == null) {
            call.reject("INVALID_PARAMETER", "userData is required")
            return
        }

        try {
            val userData = convertToUserDataRequest(userDataObj)

            coroutineScope.launch {
                try {
                    val result = linkrunner.setUserData(userData)

                    if (result.isSuccess) {
                        call.resolve()
                    } else {
                        val exception = result.exceptionOrNull()
                        Log.e(TAG, "SetUserData failed", exception)
                        call.reject("SET_USER_DATA_FAILED", exception?.message ?: "SetUserData failed")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "SetUserData failed", e)
                    call.reject("SET_USER_DATA_FAILED", e.message ?: "SetUserData failed")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to convert user data", e)
            call.reject("DATA_CONVERSION_FAILED", e.message ?: "Failed to convert user data")
        }
    }

    /**
     * Convert JSObject to UserDataRequest
     */
    private fun convertToUserDataRequest(jsObject: JSObject): UserDataRequest {
        val id = jsObject.getString("id")
            ?: throw IllegalArgumentException("User id is required")

        return UserDataRequest(
            id = id,
            name = jsObject.getString("name"),
            phone = jsObject.getString("phone"),
            email = jsObject.getString("email"),
            mixpanelDistinctId = jsObject.getString("mixpanel_distinct_id"),
            amplitudeDeviceId = jsObject.getString("amplitude_device_id"),
            posthogDistinctId = jsObject.getString("posthog_distinct_id"),
            brazeDeviceId = jsObject.getString("braze_device_id"),
            gaAppInstanceId = jsObject.getString("ga_app_instance_id"),
            gaSessionId = jsObject.getString("ga_session_id"),
            userCreatedAt = jsObject.getString("user_created_at"),
            isFirstTimeUser = jsObject.getBool("is_first_time_user"),
            netcoreDeviceGuid = jsObject.getString("netcore_device_guid")
        )
    }

    /**
     * Convert JSObject to Map
     */
    private fun convertJSObjectToMap(jsObject: JSObject): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val iterator = jsObject.keys()
        while (iterator.hasNext()) {
            val key = iterator.next()
            val value = jsObject.get(key)
            if (value != null) {
                map[key] = value
            }
        }
        return map
    }

    /**
     * Convert string to PaymentStatus enum, null when the status is unknown
     */
    private fun convertToPaymentStatus(statusStr: String): PaymentStatus? {
        return PaymentStatus.values().firstOrNull { it.name == statusStr.uppercase() }
    }

    /**
     * Convert the JS payment object to a native EventPayment, throwing IllegalArgumentException when invalid
     */
    private fun convertToEventPayment(paymentObj: JSObject): EventPayment {
        val amountValue = paymentObj.opt("amount")
        if (amountValue !is Number) {
            throw IllegalArgumentException("payment.amount is required")
        }
        val paymentId = paymentObj.getString("paymentId")
        if (paymentId.isNullOrBlank()) {
            throw IllegalArgumentException("payment.paymentId is required")
        }
        val currency = paymentObj.getString("currency")
        if (currency.isNullOrBlank()) {
            throw IllegalArgumentException("payment.currency is required")
        }
        val statusStr = paymentObj.getString("status")
        val status = if (statusStr.isNullOrBlank()) {
            null
        } else {
            convertToPaymentStatus(statusStr)
                ?: throw IllegalArgumentException("invalid payment status: $statusStr")
        }
        return EventPayment(
            amount = amountValue.toDouble(),
            paymentId = paymentId,
            currency = currency,
            status = status
        )
    }

    /**
     * Track a custom event
     */
    @PluginMethod
    fun trackEvent(call: PluginCall) {
        val eventName = call.getString("eventName")
        val eventData = call.getObject("eventData")
        val eventId = call.getString("eventId")

        if (eventName.isNullOrBlank()) {
            call.reject("INVALID_PARAMETER", "eventName is required")
            return
        }

        val payment = try {
            call.getObject("payment")?.let { convertToEventPayment(it) }
        } catch (e: IllegalArgumentException) {
            call.reject("INVALID_PARAMETER", e.message ?: "Invalid payment")
            return
        }

        try {
            val eventDataMap = eventData?.let { convertJSObjectToMap(it) }

            coroutineScope.launch {
                try {
                    val result = linkrunner.trackEvent(
                        eventName = eventName,
                        eventData = eventDataMap,
                        eventId = eventId,
                        payment = payment
                    )

                    if (result.isSuccess) {
                        call.resolve()
                    } else {
                        val exception = result.exceptionOrNull()
                        Log.e(TAG, "TrackEvent failed", exception)
                        call.reject("TRACK_EVENT_FAILED", exception?.message ?: "TrackEvent failed")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "TrackEvent failed", e)
                    call.reject("TRACK_EVENT_FAILED", e.message ?: "TrackEvent failed")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to convert event data", e)
            call.reject("DATA_CONVERSION_FAILED", e.message ?: "Failed to convert event data")
        }
    }

    /**
     * Get attribution data
     */
    @PluginMethod
    fun getAttributionData(call: PluginCall) {
        coroutineScope.launch {
            try {
                val result = linkrunner.getAttributionData()

                if (result.isSuccess) {
                    val attributionData = result.getOrNull()
                    if (attributionData != null) {
                        val response = convertAttributionDataToJSObject(attributionData)
                        call.resolve(response)
                    } else {
                        call.reject("GET_ATTRIBUTION_DATA_FAILED", "Attribution data is null")
                    }
                } else {
                    val exception = result.exceptionOrNull()
                    Log.e(TAG, "GetAttributionData failed", exception)
                    call.reject("GET_ATTRIBUTION_DATA_FAILED", exception?.message ?: "GetAttributionData failed")
                }
            } catch (e: Exception) {
                Log.e(TAG, "GetAttributionData failed", e)
                call.reject("GET_ATTRIBUTION_DATA_FAILED", e.message ?: "GetAttributionData failed")
            }
        }
    }

    /**
     * Set additional integration data
     */
    @PluginMethod
    fun setAdditionalData(call: PluginCall) {
        val integrationDataObj = call.getObject("integrationData")

        if (integrationDataObj == null) {
            call.reject("INVALID_PARAMETER", "integrationData is required")
            return
        }

        try {
            val integrationData = convertToIntegrationData(integrationDataObj)

            if (integrationData.isEmpty()) {
                call.reject("INVALID_PARAMETER", "integrationData cannot be empty")
                return
            }

            coroutineScope.launch {
                try {
                    val result = linkrunner.setAdditionalData(integrationData)

                    if (result.isSuccess) {
                        call.resolve()
                    } else {
                        val exception = result.exceptionOrNull()
                        Log.e(TAG, "SetAdditionalData failed", exception)
                        call.reject("SET_ADDITIONAL_DATA_FAILED", exception?.message ?: "SetAdditionalData failed")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "SetAdditionalData failed", e)
                    call.reject("SET_ADDITIONAL_DATA_FAILED", e.message ?: "SetAdditionalData failed")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to convert integration data", e)
            call.reject("DATA_CONVERSION_FAILED", e.message ?: "Failed to convert integration data")
        }
    }

    /**
     * Enable or disable PII hashing
     */
    @PluginMethod
    fun enablePIIHashing(call: PluginCall) {
        val enabled = call.getBoolean("enabled", true) ?: true

        try {
            linkrunner.enablePIIHashing(enabled)
            call.resolve()
        } catch (e: Exception) {
            Log.e(TAG, "EnablePIIHashing failed", e)
            call.reject("ENABLE_PII_HASHING_FAILED", e.message ?: "EnablePIIHashing failed")
        }
    }

    /**
     * Set the push notification token
     */
    @PluginMethod
    fun setPushToken(call: PluginCall) {
        val pushToken = call.getString("pushToken")

        if (pushToken.isNullOrBlank()) {
            call.reject("INVALID_PARAMETER", "Push token cannot be empty")
            return
        }

        coroutineScope.launch {
            try {
                val result = linkrunner.setPushToken(pushToken)

                if (result.isSuccess) {
                    call.resolve()
                } else {
                    val exception = result.exceptionOrNull()
                    Log.e(TAG, "SetPushToken failed", exception)
                    call.reject("SET_PUSH_TOKEN_FAILED", exception?.message ?: "SetPushToken failed")
                }
            } catch (e: Exception) {
                Log.e(TAG, "SetPushToken failed", e)
                call.reject("SET_PUSH_TOKEN_FAILED", e.message ?: "SetPushToken failed")
            }
        }
    }

    @PluginMethod
    fun setCustomerUserId(call: PluginCall) {
        val userId = call.getString("userId")

        if (userId.isNullOrBlank()) {
            call.reject("INVALID_PARAMETER", "Customer user ID cannot be empty")
            return
        }

        coroutineScope.launch {
            try {
                val result = linkrunner.setCustomerUserId(userId)

                if (result.isSuccess) {
                    call.resolve()
                } else {
                    val exception = result.exceptionOrNull()
                    Log.e(TAG, "SetCustomerUserId failed", exception)
                    call.reject("SET_CUSTOMER_USER_ID_FAILED", exception?.message ?: "SetCustomerUserId failed")
                }
            } catch (e: Exception) {
                Log.e(TAG, "SetCustomerUserId failed", e)
                call.reject("SET_CUSTOMER_USER_ID_FAILED", e.message ?: "SetCustomerUserId failed")
            }
        }
    }

    /**
     * Handle a deeplink for re-engagement attribution
     */
    @PluginMethod
    fun handleDeeplink(call: PluginCall) {
        val deeplinkUrl = call.getString("deeplinkUrl")

        if (deeplinkUrl.isNullOrBlank()) {
            call.resolve()
            return
        }

        coroutineScope.launch {
            try {
                val result = linkrunner.handleDeeplink(deeplinkUrl)

                if (result.isSuccess) {
                    val response = result.getOrNull()
                    val data = JSObject()
                    if (response != null) {
                        data.put("isLinkrunner", response.isLinkrunner)
                        response.deeplink?.let { data.put("deeplink", it) }
                        response.processing?.let { data.put("processing", it) }
                    } else {
                        data.put("isLinkrunner", false)
                    }
                    val wrapper = JSObject()
                    wrapper.put("data", data)
                    call.resolve(wrapper)
                } else {
                    val exception = result.exceptionOrNull()
                    Log.e(TAG, "HandleDeeplink failed", exception)
                    call.reject("HANDLE_DEEPLINK_FAILED", exception?.message ?: "HandleDeeplink failed")
                }
            } catch (e: Exception) {
                Log.e(TAG, "HandleDeeplink failed", e)
                call.reject("HANDLE_DEEPLINK_FAILED", e.message ?: "HandleDeeplink failed")
            }
        }
    }

    /**
     * Get the package version
     */
    @PluginMethod
    fun getPackageVersion(call: PluginCall) {
        try {
            // Read version from package.json in assets or return a default
            val version = "0.0.1" // This will be replaced with actual version reading logic
            val result = JSObject()
            result.put("version", version)
            call.resolve(result)
        } catch (e: Exception) {
            Log.e(TAG, "GetPackageVersion failed", e)
            call.reject("GET_PACKAGE_VERSION_FAILED", e.message ?: "GetPackageVersion failed")
        }
    }

    /**
     * Convert AttributionData to JSObject
     */
    private fun convertAttributionDataToJSObject(attributionData: io.linkrunner.sdk.models.response.AttributionData): JSObject {
        val result = JSObject()
        val data = JSObject()

        // Add deeplink if present
        attributionData.deeplink?.let {
            data.put("deeplink", it)
        }

        attributionData.gaid?.let { data.put("gaid", it) }
        attributionData.idfa?.let { data.put("idfa", it) }

        // Convert campaign data
        val campaignData = JSObject()
        campaignData.put("id", attributionData.campaignData.id)
        campaignData.put("name", attributionData.campaignData.name)
        campaignData.put("type", attributionData.campaignData.type)
        campaignData.put("installedAt", attributionData.campaignData.installedAt)
        campaignData.put("groupName", attributionData.campaignData.groupName)
        campaignData.put("assetName", attributionData.campaignData.assetName)
        campaignData.put("assetGroupName", attributionData.campaignData.assetGroupName)
        campaignData.put("adNetworkCampaignId", attributionData.campaignData.adNetworkCampaignId)
        campaignData.put("adSetId", attributionData.campaignData.adSetId)
        campaignData.put("adSetName", attributionData.campaignData.adSetName)
        campaignData.put("adCreativeId", attributionData.campaignData.adCreativeId)
        campaignData.put("adCreativeName", attributionData.campaignData.adCreativeName)

        // Add optional fields
        attributionData.campaignData.adNetwork?.let {
            campaignData.put("adNetwork", it)
        }
        attributionData.campaignData.storeClickAt?.let {
            campaignData.put("storeClickAt", it)
        }

        data.put("campaignData", campaignData)
        result.put("data", data)

        return result
    }

    /**
     * Convert JSObject to IntegrationData
     */
    private fun convertToIntegrationData(jsObject: JSObject): io.linkrunner.sdk.models.IntegrationData {
        return io.linkrunner.sdk.models.IntegrationData(
            clevertapId = jsObject.getString("clevertap_id")
        )
    }
}
