import Foundation

import NIO
import NIOTransportServices

class SocketWriter {
    
    struct Packet {
        let data: ByteBuffer
        let destination: SocketAddress
    }
    
    private let IDE_PORT = 4446
    
    private var messageQueue: [Packet] = []
    private var isSending: Bool = false
    
    private let server: Channel
    private var group: MultiThreadedEventLoopGroup

    init(channel: Channel, group: MultiThreadedEventLoopGroup) {
        self.group = group
        self.server = channel
    }
    
    func enqueueBroadcast(message: String) throws {
        
        let matchingInterfaces = try System.enumerateDevices().filter {
            $0.name == "en0" && $0.broadcastAddress != nil
        }
        
        guard let en0Interface = matchingInterfaces.first, var broadcastAddress = en0Interface.broadcastAddress else {
            print("ERROR: No suitable interface found. en0 matches \(matchingInterfaces)")
            exit(1)
        }
        
        broadcastAddress.port = IDE_PORT
        
        enqueue(data: message, destination: broadcastAddress)
    }
    
    func enqueue(data: String, destination: SocketAddress) {
        var buffer = server.allocator.buffer(capacity: 32)
        buffer.writeString(data)
        enqueue(data: Packet(data: buffer, destination: destination))
    }

    func enqueue(data: Packet) {
        
        print("send queue: enqueue")
        
        group.next().scheduleTask(in: TimeAmount.seconds(1),  {
            print("send queue: enqueue: \(data)")
            self.messageQueue.append(data)
            self.sendNext()
        }).futureResult.whenFailure({ error in
            print("error task sending \(data): \(error)")
        })
    }

    private func sendNext() {
        
        print("send queue: send next")
        
        guard !self.messageQueue.isEmpty else {
            self.isSending = false
            return
        }

        let message = self.messageQueue.removeFirst()
        
        
        if self.server.isActive {
            let writeFuture = self.server.writeAndFlush(AddressedEnvelope(remoteAddress: message.destination, data: message.data))
            
            writeFuture.whenSuccess {
                print("message sent")
                self.sendNext()
            }
            
            writeFuture.whenFailure { error in
                print("message sending error: \(error)")
                self.server.close(promise: nil)
            }
        } else {
            print("send queue: channel is innactive")
        }
    }
}
