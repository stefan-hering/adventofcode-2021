package day16

fun readInput() = Unit.javaClass.getResource("/day16/input")
    .readText()
    .lines()
    .filter { it.isNotEmpty() }
    .first()

fun toBinaryString(hexString: String) =
    hexString.toCharArray()
        .map { it.toString() }
        .map { it.toInt(16) }
        .map { it.toString(2) }
        .map { it.padStart(4, '0') }
        .joinToString(separator = "")

sealed class Packet

data class DataPacket(
    val headers: PacketHeaders,
    val data: List<String>,
    val remaining: String
) : Packet()

data class OperatorPacket(
    val headers: PacketHeaders,
    val subPackets: List<Packet>,
    val lengthTypeId: String,
    val remaining: String
) : Packet()

data class PacketHeaders(
    val version: Int,
    val typeID: Int,
)

fun parseHeader(header: String) =
    PacketHeaders(
        version = header.substring(0, 3).toInt(2),
        typeID = header.substring(3, 6).toInt(2)
    )

data class ParserState(
    val maxPackets: Int = Int.MAX_VALUE,
    val currentPackets: Int = 0
) {
    fun next() = copy(currentPackets = currentPackets + 1)
}

fun parsePacket(hexString: String, state: ParserState = ParserState()): List<Packet> {
    if (hexString.length < 6 || hexString.matches(Regex("0+"))) {
        return listOf()
    }

    val header = parseHeader(hexString.substring(0, 6))

    return if (header.typeID == 4) {
        var rest = hexString.substring(6)
        val values = mutableListOf<String>()
        while (rest.startsWith("1")) {
            values.add(rest.substring(1, 5))
            rest = rest.substring(5)
        }
        values.add(rest.substring(1, 5))

        val currentPacket =
            DataPacket(
                headers = header,
                data = values,
                remaining = rest.substring(5)
            )

        if (state.currentPackets < state.maxPackets) {
            listOf(currentPacket) + parsePacket(
                currentPacket.remaining,
                state.next()
            )
        } else {
            listOf(currentPacket)
        }
    } else {
        val lengthTypeId = hexString.substring(6, 7)
        if (lengthTypeId == "0") {
            val subPacketsLength = hexString.substring(7, 22)
                .toInt(2)

            val currentPacket = OperatorPacket(
                header, parsePacket(
                    hexString.substring(22, 22 + subPacketsLength)
                ),
                remaining = hexString.substring(
                    22 + subPacketsLength
                ),
                lengthTypeId = "0"
            )

            if (state.currentPackets < state.maxPackets) {
                listOf(currentPacket) + parsePacket(
                    currentPacket.remaining,
                    state.next()
                )
            } else {
                listOf(currentPacket)
            }
        } else {
            val subPacketCount = hexString.substring(7, 18)

            val subPackets = parsePacket(
                hexString.substring(18), ParserState(subPacketCount.toInt(2), 1)
            )

            val currentPacket = OperatorPacket(
                headers = header,
                subPackets = subPackets,
                remaining = findRemaining(subPackets),
                lengthTypeId = "1"
            )

            if (state.currentPackets < state.maxPackets) {
                listOf(
                    currentPacket
                ) + parsePacket(currentPacket.remaining, state.next())
            } else {
                listOf(currentPacket)
            }
        }
    }
}

fun findRemaining(packets: List<Packet>): String = packets.last().let {
    when {
        it is DataPacket -> it.remaining
        it is OperatorPacket && it.lengthTypeId == "0" -> it.remaining
        it is OperatorPacket -> findRemaining(it.subPackets)
        else -> throw Exception()
    }
}

fun versionSum(packets: List<Packet>): Int =
    packets.fold(0) { acc, packet ->
        when (packet) {
            is DataPacket -> acc + packet.headers.version
            is OperatorPacket -> acc + packet.headers.version + versionSum(packet.subPackets)
        }
    }

fun calculate(packet: Packet): Long = when (packet) {
    is DataPacket -> packet.data.joinToString(separator = "").toLong(2)
    is OperatorPacket -> packet.subPackets.map { calculate(it) }.let {
        when (packet.headers.typeID) {
            0 -> it.sum()
            1 -> it.fold(1L) { acc, i -> acc * i }
            2 -> it.minOf { it }
            3 -> it.maxOf { it }
            5 -> if (it[0] > it[1]) 1L else 0L
            6 -> if (it[0] < it[1]) 1L else 0L
            7 -> if (it[0] == it[1]) 1L else 0L
            else -> throw RuntimeException()
        }
    }
}


fun main() {
    val hexString = readInput()

    val packets = parsePacket(toBinaryString(hexString))
    println(versionSum(packets))

    println(calculate(packets.first()))
}
