package work.ksprogram.audio_graph

class PluginError {
    companion object {
        const val invalidOperation = "ERR_INVALID_OPERATION"
        const val nodeNotFound = "ERR_NODE_NOTFOUND"
        const val graphBuildFailed = "ERR_GRAPH_BUILD_FAILED"
    }
}