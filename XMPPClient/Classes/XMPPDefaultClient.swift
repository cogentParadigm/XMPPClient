//
//  XMPPClient.swift
//  Pods
//
//  Created by Ali Gangji on 6/18/16.
//
//  a default XMPP Client with access to capabilities, roster, archiving, delivery receipts, and last activity

import Foundation
import XMPPFramework

public typealias XMPPMessageCompletionHandler = (stream: XMPPStream, message: XMPPMessage) -> Void

public protocol XMPPClientDelegate : NSObjectProtocol {
    func xmppClient(_ sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
    func xmppClient(_ sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject)
}

open class XMPPDefaultClient: NSObject {

    open lazy var connection: XMPPClientConnection = {
        let connection = XMPPClientConnection()
        connection.delegate = self
        return connection
    }()
    
    open lazy var archive: XMPPClientArchive = {
        return XMPPClientArchive()
    }()
    
    open lazy var capabilities: XMPPClientCapabilities = {
        return XMPPClientCapabilities()
    }()
    
    open lazy var roster:XMPPClientRoster = {
        return XMPPClientRoster()
    }()
    
    open lazy var vcard:XMPPClientvCard = {
        return XMPPClientvCard()
    }()
    
    open lazy var receipts:XMPPClientDeliveryReceipts = {
        return XMPPClientDeliveryReceipts()
    }()
    
    open var enableArchiving = true
    open var delegate:XMPPClientDelegate?
    
    var messageCompletionHandler:XMPPMessageCompletionHandler?
    var isSetup = false
    
    open func setup() {
        roster.setup(connection)
        vcard.setup(connection)
        capabilities.setup(connection)
        receipts.setup(connection)
        if enableArchiving {
            archive.setup(connection)
        }
        
        connection.getStream().addDelegate(self, delegateQueue: DispatchQueue.main)
        isSetup = true
    }
    
    open func teardown() {
        connection.getStream().removeDelegate(self)
        if enableArchiving {
            archive.teardown()
        }
        receipts.teardown()
        capabilities.teardown()
        vcard.teardown()
        roster.teardown()
        isSetup = false
    }
    
    open func connect(username:String, password:String) {
        if !isSetup {
            setup()
        }
        connection.connect(username: username, password: password)
    }
    
    open func disconnect() {
        connection.disconnect()
        if isSetup {
            teardown()
        }
    }
    
    open func sendMessage(_ message: String, thread:String, to receiver: String, completionHandler completion:XMPPMessageCompletionHandler) {
        let body = DDXMLElement.elementWithName("body") as! DDXMLElement
        let messageID = connection.getStream().generateUUID()
        
        body.setStringValue(message)
        
        let threadElement = DDXMLElement.elementWithName("thread") as! DDXMLElement
        threadElement.setStringValue(thread)
        
        let completeMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
        
        completeMessage.addAttributeWithName("id", stringValue: messageID)
        completeMessage.addAttributeWithName("type", stringValue: "chat")
        completeMessage.addAttributeWithName("to", stringValue: receiver)
        completeMessage.addChild(body)
        completeMessage.addChild(threadElement)
        
        messageCompletionHandler = completion
        connection.getStream().sendElement(completeMessage)
    }
    
}

extension XMPPDefaultClient: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream, didSendMessage message: XMPPMessage) {
        if let completion = messageCompletionHandler {
            completion(stream: sender, message: message)
        }
    }
    
    public func xmppStream(_ sender: XMPPStream, didReceiveMessage message: XMPPMessage) {
        let user = roster.storage.userForJID(message.from(), xmppStream: connection.getStream(), managedObjectContext: roster.storage.mainThreadManagedObjectContext)
        if message.isChatMessageWithBody() {
            delegate?.xmppClient(sender, didReceiveMessage: message, from: user)
        } else if let _ = message.elementForName("composing") {
            delegate?.xmppClient(sender, userIsComposing: user)
        }
    }
}

extension XMPPDefaultClient: XMPPClientConnectionDelegate {
    public func xmppConnectionDidAuthenticate(_ sender: XMPPStream) {
        //TODO: initiate retrieval of archives from server
    }
}
