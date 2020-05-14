package work.ksprogram.audio_graph

class IdManager(private val key: String) {
    companion object {
        private val ids: MutableMap<String, Int> = mutableMapOf()

        fun generateId(key: String): Int {
            val id = ids[key] ?: 0
            ids[key] = id + 1
            return id
        }
    }

    fun generateId(): Int {
        return generateId(key)
    }
}
