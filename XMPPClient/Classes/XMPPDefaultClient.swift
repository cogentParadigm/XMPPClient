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
    func xmppClient(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
    func xmppClient(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject)
}

public class XMPPDefaultClient: NSObject {

    public lazy var connection: XMPPClientConnection = {
        let connection = XMPPClientConnection()
        connection.delegate = self
        return connection
    }()
    
    public lazy var archive: XMPPClientArchive = {
        return XMPPClientArchive()
    }()
    
    public lazy var capabilities: XMPPClientCapabilities = {
        return XMPPClientCapabilities()
    }()
    
    public lazy var roster:XMPPClientRoster = {
        return XMPPClientRoster()
    }()
    
    public lazy var vcard:XMPPClientvCard = {
        return XMPPClientvCard()
    }()
    
    public lazy var receipts:XMPPClientDeliveryReceipts = {
        return XMPPClientDeliveryReceipts()
    }()
    
    public var enableArchiving = true
    public var delegate:XMPPClientDelegate?
    
    var messageCompletionHandler:XMPPMessageCompletionHandler?
    var isSetup = false
    
    public func setup() {
        roster.setup(connection)
        vcard.setup(connection)
        capabilities.setup(connection)
        receipts.setup(connection)
        if enableArchiving {
            archive.setup(connection)
        }
        
        connection.getStream().addDelegate(self, delegateQueue: dispatch_get_main_queue())
        isSetup = true
    }
    
    public func teardown() {
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
    
    public func connect(username username:String, password:String) {
        if !isSetup {
            setup()
        }
        connection.connect(username: username, password: password)
    }
    
    public func disconnect() {
        connection.disconnect()
        if isSetup {
            teardown()
        }
    }
    
    public func sendMessage(message: String, thread:String, to receiver: String, completionHandler completion:XMPPMessageCompletionHandler) {
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
    
    public func xmppStream(sender: XMPPStream, didSendMessage message: XMPPMessage) {
        if let completion = messageCompletionHandler {
            completion(stream: sender, message: message)
        }
    }
    
    public func xmppStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage) {
        let user = roster.storage.userForJID(message.from(), xmppStream: connection.getStream(), managedObjectContext: roster.storage.mainThreadManagedObjectContext)
        if message.isChatMessageWithBody() {
            delegate?.xmppClient(sender, didReceiveMessage: message, from: user)
        } else if let _ = message.elementForName("composing") {
            delegate?.xmppClient(sender, userIsComposing: user)
        }
    }
}

extension XMPPDefaultClient: XMPPClientConnectionDelegate {
    public func xmppConnectionDidAuthenticate(sender: XMPPStream) {
        //TODO: initiate retrieval of archives from server
    }
}
