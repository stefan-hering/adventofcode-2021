package day15

import java.lang.Math.min
import kotlin.system.measureTimeMillis

typealias Grid = List<List<Int>>

fun readInput() = Unit.javaClass.getResource("/input")
    .readText()
    .lines()
    .filter { it.isNotEmpty() }
    .map {
        it.toCharArray().map {
            it.digitToInt()
        }
    }

fun Array<IntArray>.setIfLower(x: Int, y: Int, value: Int): Boolean =
    if (this[x][y] > value) {
        this[x][y] = value
        true
    } else false


fun findMinimumRisk(grid: Grid) {
    val minRisks: Array<IntArray> = Array(grid.size) {
        IntArray(grid.size) { Integer.MAX_VALUE }
    }

    var i = 0
    var j = 0
    while (i < grid.size && j < grid.size) {
        val nextRisk = if (i > 0 && j > 0) {
            min(minRisks[i - 1][j], minRisks[i][j - 1]) + grid[i][j]
        } else if (j > 0) {
            minRisks[i][j - 1] + grid[i][j]
        } else if (i > 0) {
            minRisks[i - 1][j] + grid[i][j]
        } else 0

        minRisks.setIfLower(i, j, nextRisk)

        while (i > 0 &&
            minRisks.setIfLower(i - 1, j, minRisks[i][j] + grid[i - 1][j])
        ) i--
        while (j > 0 &&
            minRisks.setIfLower(i, j - 1, minRisks[i][j] + grid[i][j - 1])
        ) j--

        j++
        if (j == grid.size) {
            j = 0
            i++
        }
    }

    println(minRisks[grid.size - 1][grid.size - 1])
}

fun expandGrid(grid: Grid): Grid = (0..4).flatMap { x ->
    grid.map { row ->
        (0..4).flatMap { y ->
            row.map {
                (it + x + y - 1) % 9 + 1
            }
        }
    }
}

fun main() {
    measureTimeMillis {
        val grid = readInput()
        findMinimumRisk(grid)
        val expandedGrid = expandGrid(grid)
        findMinimumRisk(expandedGrid)
    }.also { println("Took $it ms") }
}
