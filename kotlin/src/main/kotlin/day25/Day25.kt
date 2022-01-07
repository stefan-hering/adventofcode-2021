package day25

fun readInput(): CucumberGrid = Unit.javaClass.getResource("/day25/input.txt")
    .readText()
    .lines()
    .filter { it.isNotBlank() }
    .map { it.toCharArray() }
    .toTypedArray()

typealias CucumberGrid = Array<CharArray>

fun CucumberGrid.length() = first().size

fun step(grid: CucumberGrid): Pair<Array<CharArray>, Int> {
    val nextStep = Array(grid.size) { CharArray(grid.length()) { '.' } }

    var moves = 0

    for (x in grid.indices) {
        for (y in grid[x].indices) {
            if (grid[x][y] == '>') {
                if (grid[x][(y + 1) % grid.length()] == '.') {
                    moves++
                    nextStep[x][(y + 1) % grid.length()] = '>'
                } else {
                    nextStep[x][y] = '>'
                }
            }
        }
    }

    for (x in grid.indices) {
        for (y in grid[x].indices) {
            if (grid[x][y] == 'v') {
                if (grid[(x + 1) % grid.size][y] != 'v' &&
                    nextStep[(x + 1) % grid.size][y] != '>') {
                    moves++
                    nextStep[(x + 1) % grid.size][y] = 'v'
                } else {
                    nextStep[x][y] = 'v'
                }
            }
        }
    }

    return nextStep to moves
}

fun part1(initialGrid: CucumberGrid): Int {
    var grid = initialGrid

    return (1..Int.MAX_VALUE).takeWhile {
        val result = step(grid)
        grid = result.first
        result.second != 0
    }.last() + 1
}

fun main() {
    println(part1(readInput()))
}
