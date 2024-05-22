//
//  initSocketConnection.swift
//  iosApp
//
//  Created by Eugene Levenetc on 21/05/2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation

import Foundation
import NIO
import NIOCore
import NIOPosix
import NIOCore
import NIOTransportServices

let IDE_PORT = 4446

func initSocketConnection(projectsStorage: ProjectsStorage) throws {
    
    
    print("initSocketConnection")
    
    var sendQueue: SocketWriter? = nil
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    defer {
        try! group.syncShutdownGracefully()
    }

    let matchingInterfaces = try System.enumerateDevices().filter {
        $0.name == "en0" && $0.broadcastAddress != nil
    }
    let en0Interface = matchingInterfaces.first
    
    let messageHandler = MessageHandler(projectsStorage: projectsStorage)

    let server = try! DatagramBootstrap(group: group)
        .channelOption(ChannelOptions.socket(SOL_SOCKET, SO_BROADCAST), value: 1)
        .channelInitializer { channel in
            return channel.pipeline.addHandler(SocketReader(messageHandler: messageHandler))
        }
        .bind(to: (en0Interface?.address!)!)
        .wait()
    
    print("bound to \(server.localAddress!)")
    
    sendQueue = SocketWriter(channel: server, group: group)
    
    group.next().scheduleRepeatedTask(initialDelay: .seconds(1),
                                    delay: .seconds(5),
                                    notifying: nil) { task in
        try! sendQueue?.enqueueBroadcast(message: "cmd:connect")
    }

    try server.closeFuture.wait()
}