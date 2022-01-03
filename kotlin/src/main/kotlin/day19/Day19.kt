package day19

import java.lang.Math.abs

fun readInput() = Unit.javaClass.getResource("/day19/input.txt")
    .readText()
    .split("\n\n")
    .filter { it.isNotEmpty() }
    .map {
        val id = Regex("--- scanner (\\d+) ---")
            .find(it)!!
            .groupValues
            .get(1)
            .toInt()

        val transposedPositions = it.lines()
            .drop(1)
            .filter { it.isNotEmpty() }
            .map { it.split(",").map { it.toInt() } }
            .map { Position(it[0], it[1], it[2]).rotations() }

        val positions = Array(48) { Array<Position?>(100) { null } }

        transposedPositions.forEachIndexed { i, rotations ->
            rotations.forEachIndexed { j, rotation ->
                positions[j][i] = rotation
            }
        }

        Scanner(
            id = id,
            possibleResults = positions.toList().map { it.toList().filterNotNull() }
        )
    }.mapIndexed { i, scanner ->
        if (i == 0) {
            scanner.copy(
                offset = Position(0, 0, 0),
                possibleResults = scanner.possibleResults.take(1)
            )
        } else {
            scanner
        }
    }


data class Position(
    val x: Int,
    val y: Int,
    val z: Int,
) {
    fun rotations() =
        listOf(
            this,
            Position(x = x, y = z, z = y),
            Position(x = y, y = x, z = z),
            Position(x = y, y = z, z = x),
            Position(x = z, y = x, z = y),
            Position(x = z, y = y, z = x),
        ).flatMap {
            listOf(
                it,
                it.copy(x = -1 * it.x),
                it.copy(y = -1 * it.y),
                it.copy(z = -1 * it.z),
                it.copy(x = -1 * it.x, y = -1 * it.y),
                it.copy(y = -1 * it.y, z = -1 * it.z),
                it.copy(x = -1 * it.x, z = -1 * it.z),
                it.copy(x = -1 * it.x, y = -1 * it.y, z = -1 * it.z)
            )
        }

    operator fun minus(other: Position): Position =
        Position(
            x - other.x,
            y - other.y,
            z - other.z
        )

    operator fun plus(other: Position): Position =
        Position(
            x + other.x,
            y + other.y,
            z + other.z
        )

    override fun equals(other: Any?): Boolean =
        if(other is Position)
            x ==other.x && y == other.y && z == other.z
        else false

    override fun hashCode(): Int {
        var result = x
        result = 31 * result + y
        result = 31 * result + z
        return result
    }
}

typealias ScannerResult = List<Position>

data class Scanner(
    val id: Int,
    val offset: Position? = null,
    val possibleResults: List<ScannerResult>
)

// Way too slow+messy, should speed/clean up
fun overlap(scanner1: Scanner, scanner2: Scanner): Scanner? {
    scanner1.possibleResults.forEachIndexed { r1i, rotation1 ->
        scanner2.possibleResults.forEachIndexed { r2i, rotation2 ->
            rotation1.forEachIndexed { p1i, position1 ->
                rotation2.forEachIndexed { p2i, position2 ->
                    val offset = position1 - position2
                    var overlap = 0
                    rotation2.forEachIndexed { p2i2, position22 ->
                        rotation1.forEachIndexed { p1i, position12 ->
                            if (position22 + offset == position12) {
                                overlap++
                            }
                        }
                    }
                    if (overlap >= 12) {
                        return scanner2.copy(
                            possibleResults = listOf(rotation2),
                            offset = offset + scanner1.offset!!
                        )
                    }
                }
            }
        }
    }
    return null
}

fun part1(scanners: List<Scanner>): List<Scanner> {
    var (foundScanners, unknownScanners) = scanners.partition { it.offset != null }


    while (unknownScanners.isNotEmpty()) {
        foundScanners.forEachIndexed { id1, s1 ->
            val result = unknownScanners.map { s2 ->
                s2.id to overlap(s1, s2)
            }.filter { it.second != null }

            val foundIds = result.map { it.first }.toSet()

            unknownScanners = unknownScanners.filter { !foundIds.contains(it.id) }
            foundScanners = foundScanners + result.mapNotNull { it.second }
        }
    }

    foundScanners.flatMap { scanner ->
        scanner.possibleResults.first().map {
            it + scanner.offset!!
        }
    }.distinct().count().also(::println)

    return foundScanners
}

fun part2(scanners: List<Scanner>) {
    var maxDistance = 0
    scanners.forEach { s1 ->
        scanners.forEach { s2 ->
            val manhattanDistance = s1.offset!!.manhattanDistance(s2.offset!!)
            if(manhattanDistance > maxDistance) {
                maxDistance = manhattanDistance
            }
        }
    }
    println(maxDistance)
}

fun Position.manhattanDistance(other: Position) =
    abs(x - other.x) + abs(y - other.y) + abs(z - other.z)

fun main() {
    val scanners = readInput()
    part2(part1(scanners))
}
