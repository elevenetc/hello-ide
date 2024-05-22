package org.example.playgroundideplugin

import com.intellij.openapi.project.Project
import com.intellij.openapi.project.ProjectManager
import com.intellij.openapi.project.ProjectManagerListener
import com.intellij.openapi.startup.ProjectActivity


class StartupActivity : ProjectActivity {
    override suspend fun execute(project: Project) {

        SocketConnection.connection.onProjectOpened(project)

        project.messageBus.connect().subscribe(ProjectManager.TOPIC, object : ProjectManagerListener {

            override fun projectClosing(project: Project) {
                SocketConnection.connection.onProjectClosed(project)
            }
        })
    }
}
