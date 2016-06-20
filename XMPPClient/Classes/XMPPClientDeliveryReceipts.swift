//
//  XMPPClientDeliveryReceipts.swift
//  Pods
//
//  Created by Ali Gangji on 6/19/16.
//
//

import Foundation
import XMPPFramework

public class XMPPClientDeliveryReceipts: NSObject {
    public lazy var receipts: XMPPMessageDeliveryReceipts = {
        let receipts = XMPPMessageDeliveryReceipts(dispatchQueue: dispatch_get_main_queue())
        receipts.autoSendMessageDeliveryReceipts = true
        receipts.autoSendMessageDeliveryRequests = true
        return receipts
    }()
    
    public func setup(connection:XMPPClientConnection) {
        connection.activate(receipts)
    }
    
    public func teardown() {
        receipts.deactivate()
    }
}
