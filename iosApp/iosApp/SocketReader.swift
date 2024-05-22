import Foundation

import NIO
import NIOCore
import NIOPosix
import NIOCore
import NIOTransportServices

final class SocketReader: ChannelInboundHandler {
    
    let messageHandler: MessageHandler
    
    init(messageHandler: MessageHandler) {
        self.messageHandler = messageHandler
    }
    
    typealias InboundIn = AddressedEnvelope<ByteBuffer>

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let envelope = self.unwrapInboundIn(data)
        let buffer = envelope.data

        if let receivedMessage = buffer.getString(at: 0, length: buffer.readableBytes) {
            
            let messageId = parseMessageId(data: receivedMessage)
            
            messageHandler.handle(messageId: messageId, rawMessage: receivedMessage)
            
            print("command: \(messageId)")
            print("Received message: \(receivedMessage) from \(envelope.remoteAddress)")
        } else {
            print("Received unknown data from \(envelope.remoteAddress)")
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error: \(error)")
        context.close(promise: nil)
    }
}
