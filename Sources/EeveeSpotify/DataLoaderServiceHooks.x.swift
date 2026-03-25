import Foundation
import Orion

// Restore the global access token variable
public var spotifyAccessToken: String?

class SPTDataLoaderServiceHook: ClassHook<NSObject>, SpotifySessionDelegate {
    static let targetName = "SPTDataLoaderService"
    // orion:new
    static var cachedCustomizeData: Data?
    // orion:new
    static var handledCustomizeTasks = Set<Int>()
    // orion:new
    func shouldBlock(_ url: URL) -> Bool {
        let elapsed = Date().timeIntervalSince(tweakInitTime)
        
        // Always block explicit session destroy/token delete
        if url.isDeleteToken || url.isSessionInvalidation || url.path.contains("session/purge") || url.path.contains("token/revoke") {
            return true
        }
        
        // NEW: Always block ad-logic, sponsored content, and in-app messaging (popups)
        if url.isAdLogic {
            return true
        }
        
        // Only block these after startup (30s) to allow initial login/initialization
        if elapsed > 30 {
            return url.isAccountValidate || url.isOndemandSelector
                || url.isTrialsFacade || url.isPremiumMarketing || url.isPendragonFetchMessageList
                || url.isPushkaTokens || url.path.contains("signup/public") || url.path.contains("apresolve")
                || url.path.contains("pses/screenconfig") || url.path.contains("bootstrap/v1/bootstrap")
        }
        
        return false
    }
    // orion:new
    func shouldModify(_ url: URL) -> Bool {
        let shouldPatchPremium = BasePremiumPatchingGroup.isActive
        let shouldReplaceLyrics = BaseLyricsGroup.isActive
        
        let isLyricsURL = url.isLyrics
        if isLyricsURL {
        }
        
        return (shouldReplaceLyrics && isLyricsURL)
            || (shouldPatchPremium && (url.isCustomize || url.isPremiumPlanRow || url.isPremiumBadge || url.isPlanOverview))
    }
    
    // orion:new
    func respondWithCustomData(_ data: Data, task: URLSessionDataTask, session: URLSession) {
        orig.URLSession(session, dataTask: task, didReceiveData: data)
    }
    // orion:new
    func handleBlockedEndpoint(_ url: URL, task: URLSessionDataTask, session: URLSession) {
        if url.isDeleteToken {
            respondWithCustomData(Data(), task: task, session: session)
        } else if url.isAccountValidate {
            let response = "{\"status\":1,\"country\":\"US\",\"is_country_launched\":true}".data(using: .utf8)!
            respondWithCustomData(response, task: task, session: session)
        } else if url.isOndemandSelector {
            respondWithCustomData(Data(), task: task, session: session)
        } else if url.isTrialsFacade {
            let response = "{\"result\":\"NOT_ELIGIBLE\"}".data(using: .utf8)!
            respondWithCustomData(response, task: task, session: session)
        } else if url.isPremiumMarketing {
            respondWithCustomData("{}".data(using: .utf8)!, task: task, session: session)
        } else if url.isPendragonFetchMessageList {
            respondWithCustomData(Data(), task: task, session: session)
        } else if url.isPushkaTokens {
            respondWithCustomData(Data(), task: task, session: session)
        } else if url.isAdLogic {
            // Return empty JSON to satisfy the ad loader without rendering anything
            respondWithCustomData("{}".data(using: .utf8)!, task: task, session: session)
        } else if url.isSessionInvalidation || url.path.contains("session/purge") || url.path.contains("token/revoke") {
            // Return synthetic OK to prevent internal logout triggers
            respondWithCustomData("{\"status\":\"OK\"}".data(using: .utf8)!, task: task, session: session)
        } else if url.path.contains("signup/public") {
            respondWithCustomData("{\"status\":\"OK\"}".data(using: .utf8)!, task: task, session: session)
        } else if url.path.contains("apresolve") {
            respondWithCustomData("{\"status\":\"OK\"}".data(using: .utf8)!, task: task, session: session)
        } else if url.path.contains("pses/screenconfig") {
            respondWithCustomData("{}".data(using: .utf8)!, task: task, session: session)
        } else if url.path.contains("bootstrap/v1/bootstrap") {
            respondWithCustomData("{}".data(using: .utf8)!, task: task, session: session)
        }
        orig.URLSession(session, task: task, didCompleteWithError: nil)
    }
    
    func URLSession(
        _ session: URLSession,
        task: URLSessionDataTask,
        didCompleteWithError error: Error?
    ) {
        // Capture authorization token from any request
        if let request = task.currentRequest,
           let headers = request.allHTTPHeaderFields,
           let auth = headers["Authorization"] ?? headers["authorization"],
           auth.hasPrefix("Bearer ") {
            spotifyAccessToken = auth
        }
        
        guard
            let url = task.currentRequest?.url
        else {
            orig.URLSession(session, task: task, didCompleteWithError: error)
            return
        }
        
        do {
            // If we are blocking the endpoint, prevent the original completion handler from being called
            if shouldBlock(url) {
                handleBlockedEndpoint(url, task: task, session: session)
                return
            }

            // If we are modifying the endpoint, ensure we have the data
            if shouldModify(url) {
                guard let buffer = URLSessionHelper.shared.obtainData(for: url) else {
                    orig.URLSession(session, task: task, didCompleteWithError: error)
                    return
                }
                
                if url.isPremiumPlanRow {
                    respondWithCustomData(
                        try getPremiumPlanRowData(
                            originalPremiumPlanRow: try PremiumPlanRow(serializedBytes: buffer)
                        ),
                        task: task,
                        session: session
                    )
                    orig.URLSession(session, task: task, didCompleteWithError: nil)
                    return
                }
                
                if url.isPremiumBadge {
                    respondWithCustomData(try getPremiumPlanBadge(), task: task, session: session)
                    orig.URLSession(session, task: task, didCompleteWithError: nil)
                    return
                }
                
                if url.isCustomize {
                    var customizeMessage = try CustomizeMessage(serializedBytes: buffer)
                    modifyRemoteConfiguration(&customizeMessage.response)
                    let modifiedData = try customizeMessage.serializedData()
                    SPTDataLoaderServiceHook.cachedCustomizeData = modifiedData
                    respondWithCustomData(modifiedData, task: task, session: session)
                    orig.URLSession(session, task: task, didCompleteWithError: nil)
                    return
                }
                
                if url.isPlanOverview {
                    respondWithCustomData(try getPlanOverviewData(), task: task, session: session)
                    orig.URLSession(session, task: task, didCompleteWithError: nil)
                    return
                }
            }
        }
        catch {
            orig.URLSession(session, task: task, didCompleteWithError: error)
            return
        }
        
        orig.URLSession(session, task: task, didCompleteWithError: error)
    }
    func URLSession(
        _ session: URLSession,
        dataTask task: URLSessionDataTask,
        didReceiveResponse response: HTTPURLResponse,
        completionHandler handler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        // Handle customize 304 — prevent free-account data leaking from URLSession cache
        if let url = task.currentRequest?.url, url.isCustomize, response.statusCode == 304 {
            if let cached = SPTDataLoaderServiceHook.cachedCustomizeData {
                let fakeResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "2.0", headerFields: [:])!
                orig.URLSession(session, dataTask: task, didReceiveResponse: fakeResponse, completionHandler: handler)
                respondWithCustomData(cached, task: task, session: session)
                SPTDataLoaderServiceHook.handledCustomizeTasks.insert(task.taskIdentifier)
                return
            }
        }
        guard
            let url = task.currentRequest?.url,
            url.isLyrics,
            response.statusCode != 200
        else {
            orig.URLSession(session, dataTask: task, didReceiveResponse: response, completionHandler: handler)
            return
        }
        do {
            let data = try getLyricsDataForCurrentTrack(url.path)
            let okResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "2.0", headerFields: [:])!
            
            orig.URLSession(session, dataTask: task, didReceiveResponse: okResponse, completionHandler: handler)
            respondWithCustomData(data, task: task, session: session)
        } catch {
            orig.URLSession(session, task: task, didCompleteWithError: error)
        }
    }
    func URLSession(
        _ session: URLSession,
        dataTask task: URLSessionDataTask,
        didReceiveData data: Data
    ) {
        guard let url = task.currentRequest?.url else {
            return
        }
        // Suppress data for blocked endpoints (prevent original data from reaching handler)
        if shouldBlock(url) {
            return
        }
        if shouldModify(url) {
            URLSessionHelper.shared.setOrAppend(data, for: url)
            return
        }
        orig.URLSession(session, dataTask: task, didReceiveData: data)
    }
}
