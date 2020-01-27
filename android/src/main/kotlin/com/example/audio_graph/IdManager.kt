package com.example.audio_graph

class IdManager(val key: String) {
    companion object {
        private val ids: MutableMap<String, Int> = mutableMapOf()

        fun generateId(key: String): Int {
            val id = ids[key] ?: 0
            ids[key] = id + 1
            return id
        }
    }

    fun generateId(): Int {
        return IdManager.generateId(key)
    }
}