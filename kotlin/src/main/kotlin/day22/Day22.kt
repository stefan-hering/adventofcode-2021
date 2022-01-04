package day22

fun readInput() = Unit.javaClass.getResource("/day22/input.txt")
    .readText()
    .lines()
    .filter { it.isNotBlank() }
    .map { it.split(" ") }
    .map { it[0] to parseCoordinates(it[1]) }
    .map { Instruction(it.first, it.second[0], it.second[1], it.second[2]) }

data class Instruction(
    val instruction: String,
    val x: IntRange,
    val y: IntRange,
    val z: IntRange
) {
    private fun overlaps(other: Instruction): Boolean =
        x.overlaps(other.x) && y.overlaps(other.y) && z.overlaps(other.z)

    private fun calculateOverlap(other: Instruction, type: String): Instruction =
        Instruction(
            instruction = type,
            x = IntRange(maxOf(x.first, other.x.first), minOf(x.last, other.x.last)),
            y = IntRange(maxOf(y.first, other.y.first), minOf(y.last, other.y.last)),
            z = IntRange(maxOf(z.first, other.z.first), minOf(z.last, other.z.last))
        )

    fun calculateOverlap(others: List<Instruction>, type: String) =
        others.filter { overlaps(it) }
            .map { calculateOverlap(it, type) }

    fun size(): Long = (x.last - x.start + 1).toLong() *
            (y.last - y.start + 1).toLong() *
            (z.last - z.start + 1).toLong()
}

fun IntRange.overlaps(other: IntRange) =
    first <= other.last && last >= other.first


fun parseCoordinates(coordinate: String) =
    coordinate.split(",")
        .mapNotNull {
            Regex("[xyz]=(-?\\d+)\\.\\.(-?\\d+)")
                .find(it)
                ?.let { IntRange(it.groupValues[1].toInt(), it.groupValues[2].toInt()) }
        }


fun part1(instructions: List<Instruction>): Long =
    part2(instructions.filter { it.x.first <= 50 && it.x.first >= -50 })

fun part2(instructions: List<Instruction>): Long {
    val cubes: MutableList<Instruction> = mutableListOf()

    instructions.forEach { instruction ->
        val (add, subtract) = cubes.partition { it.instruction == "add" }

        instruction.calculateOverlap(add, "subtract")
            .forEach { cubes.add(it) }

        instruction.calculateOverlap(subtract, "add")
            .forEach { cubes.add(it) }

        if (instruction.instruction == "on") {
            cubes.add(instruction.copy(instruction = "add"))
        }
    }

    return cubes.fold(0L) { acc, cube ->
        when (cube.instruction) {
            "add" -> acc + cube.size()
            "subtract" -> acc - cube.size()
            else -> acc
        }
    }
}

fun main() {
    val input = readInput()
    println(part1(input))
    println(part2(input))
}
