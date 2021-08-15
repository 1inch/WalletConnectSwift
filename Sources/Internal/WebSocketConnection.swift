//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Starscream

class WebSocketConnection {
    let url: WCURL
    private let socket: WebSocket
    private let onConnect: (() -> Void)?
    private let onDisconnect: ((Error?) -> Void)?
    private let onTextReceive: ((String) -> Void)?
    // needed to keep connection alive
    private var pingTimer: Timer?
    // TODO: make injectable on server creation
    private let pingInterval: TimeInterval = 30

    private var requestSerializer: RequestSerializer = JSONRPCSerializer()
    private var responseSerializer: ResponseSerializer = JSONRPCSerializer()

    // serial queue for receiving the calls.
    private let serialCallbackQueue: DispatchQueue

    var isOpen: Bool {
        return socket.isConnected
    }

    init(url: WCURL,
         onConnect: (() -> Void)?,
         onDisconnect: ((Error?) -> Void)?,
         onTextReceive: ((String) -> Void)?) {
        self.url = url
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.onTextReceive = onTextReceive
        serialCallbackQueue = DispatchQueue(label: "org.walletconnect.swift.connection-\(url.bridgeURL)-\(url.topic)")
        socket = WebSocket(url: url.bridgeURL)
        socket.delegate = self
        socket.callbackQueue = serialCallbackQueue
    }

    func open() {
        socket.connect()
    }

    func close() {
        socket.disconnect()
    }
    
    func tearDown() {
        socket.delegate = nil
        socket.pongDelegate = nil
        socket.advancedDelegate = nil
        socket.onConnect = nil
        socket.onDisconnect = nil
        socket.onText = nil
        socket.onData = nil
        socket.onPong = nil
        socket.onHttpResponseHeaders = nil
        socket.respondToPingWithPong = false
        let error = NSError(domain: "teardown", code: 0, userInfo: nil)
        socket.streamDidError(error: error)
    }

    func send(_ text: String) {
        guard socket.isConnected else { return }
        socket.write(string: text)
        log(text)
    }

    private func log(_ text: String) {
        if let request = try? requestSerializer.deserialize(text, url: url).json().string {
            LogService.shared.log("WC: ==> \(request)")
        } else if let response = try? responseSerializer.deserialize(text, url: url).json().string {
            LogService.shared.log("WC: ==> \(response)")
        } else {
            LogService.shared.log("WC: ==> \(text)")
        }
    }
}

extension WebSocketConnection: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        pingTimer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true) { [weak self] _ in
            LogService.shared.log("WC: ==> ping")
            self?.socket.write(ping: Data())
        }
        onConnect?()
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        pingTimer?.invalidate()
        onDisconnect?(error)
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        onTextReceive?(text)
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // no-op
    }
}
