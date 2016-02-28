//
//  Adapter.swift
//  BlueZ
//
//  Created by Alsey Coleman Miller on 12/6/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(Linux)
    import CBlueZ
    import CBlueZInternal
    import Glibc
#elseif os(OSX) || os(iOS)
    import Darwin.C
#endif

/// Manages connection / communication to the underlying Bluetooth hardware.
public final class Adapter {
    
    // MARK: - Properties
    
    /// The device identifier of the Bluetooth adapter.
    public let identifier: CInt
    
    // MARK: - Private Properties
    
    internal let socket: CInt
    
    // MARK: - Initizalization
    
    deinit {
        
        close(socket)
    }
    
    /// Initializes the Bluetooth Adapter with the specified address.
    ///
    /// If no address is specified then it tries to intialize the first Bluetooth adapter.
    public init?(address: Address? = nil) {
        
        // get device ID
        let addressPointer = UnsafeMutablePointer<bdaddr_t>.alloc(1)
        defer { addressPointer.dealloc(1) }
        
        if let address = address {
            
            addressPointer.memory = address
        }
        
        self.identifier = hci_get_route(addressPointer)
        
        guard self.identifier != -1
            else { self.socket = -1; return nil } // cant be -1
        
        self.socket = hci_open_dev(identifier)
        
        guard socket != -1 else { return nil } // cant be -1
    }
}

// MARK: - Darwin Stubs

#if os(OSX) || os(iOS)
    
    func hci_get_route(bytes: UnsafeMutablePointer<bdaddr_t>) -> CInt { stub() }
    
    func hci_open_dev(dev_id: CInt) -> CInt { stub() }
    
#endif

