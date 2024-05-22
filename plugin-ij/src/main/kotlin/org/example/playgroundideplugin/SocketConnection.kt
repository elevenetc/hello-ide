package org.example.playgroundideplugin

import com.intellij.openapi.project.Project
import com.intellij.openapi.project.impl.ProjectImpl
import com.jetbrains.helloIde.MessageId
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.IOException
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.SocketException

class SocketConnection {

    companion object {

        private var _connection: SocketConnection? = null

        val connection: SocketConnection
            get() {
                MessageId
                if (_connection == null) {
                    _connection = SocketConnection().apply { this.connect() }
                }
                return _connection!!
            }
    }

    lateinit var socket: DatagramSocket
    private var running = false
    private val buf = ByteArray(256)
    private val openedProjects = mutableSetOf<Project>()
    private val clients = mutableSetOf<Client>()
    private val json = Json { prettyPrint = true }

    init {
        try {
            socket = DatagramSocket(4446)
        } catch (e: SocketException) {
            e.printStackTrace()
        }
    }

    fun onProjectOpened(project: Project) {
        openedProjects.add(project)
        broadcastMessage(projectsMessage())
    }

    fun onProjectClosed(project: Project) {
        openedProjects.remove(project)
        broadcastMessage(projectsMessage())
    }

    fun connect() {

        running = true
        val readThread = Thread {
            while (running) {
                val packet = DatagramPacket(buf, buf.size)
                try {
                    socket.receive(packet)
                    val message = packet.data.decodeToString().trimEnd('\u0000')
                    println("received packet: " + message)

                    if (message.startsWith(Commands.CONNECT)) {
                        val client = Client(packet.address, packet.port)
                        clients.add(client)
                        sendMessageToClient(client, projectsMessage())
                    }

                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
            socket.close()
        }
        readThread.start()
    }

    private fun broadcastMessage(message: String) {
        clients.forEach {
            sendMessageToClient(it, message)
        }
    }

    private fun sendMessageToClient(client: Client, message: String) {
        sendMessageToClient(client.ip, client.port, message)
    }

    private fun sendMessageToClient(address: InetAddress, port: Int, message: String) {
        val responseData = message.toByteArray()
        val responsePacket = DatagramPacket(responseData, responseData.size, address, port)
        socket.send(responsePacket)
    }

    fun disconnect() {
        running = false
        socket.close()
    }

    private fun projectsMessage(): String {
        return json.encodeToString(Message.Projects(openedProjects.map { project ->

            Message.Project(
                project.name,
                project.basePath.toString(),
                project.getUserData(ProjectImpl.CREATION_TIME)?.toLong() ?: -1
            )
        }))
    }
}

data object Commands {
    const val CONNECT = "cmd:connect"
}

@Serializable
open class Message(val id: String) {
    @Serializable
    data class Project(
        val name: String,
        val id: String,
        val created: Long
    )

    @Serializable
    data class Projects(val projects: List<Project>) : Message(MessageId.GET_PROJECTS)
}


data class Client(val ip: InetAddress, val port: Int)
