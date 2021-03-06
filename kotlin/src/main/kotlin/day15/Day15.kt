package day15

import java.lang.Math.max
import java.lang.Math.min
import kotlin.system.measureTimeMillis

typealias Grid = List<List<Int>>

fun readInput() = Unit.javaClass.getResource("/day15/input")
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
        IntArray(grid.size) { Integer.MAX_VALUE - 10 }
    }
    minRisks[0][0] = 0

    var i = 0
    var j = 1
    var iteration = 1
    while (iteration < grid.size * 2 + 1) {
        val nextRisk = if (i > 0 && j > 0) {
            min(minRisks[i - 1][j], minRisks[i][j - 1]) + grid[i][j]
        } else if (j > 0) {
            minRisks[i][j - 1] + grid[i][j]
        } else if (i > 0) {
            minRisks[i - 1][j] + grid[i][j]
        } else 0

        minRisks.setIfLower(i, j, nextRisk)

        if (i > 0 &&
            minRisks.setIfLower(i - 1, j, minRisks[i][j] + grid[i - 1][j])
        ) {
            i--
            iteration--
        }
        if (j > 0 &&
            minRisks.setIfLower(i, j - 1, minRisks[i][j] + grid[i][j - 1])
        ) {
            j--
            iteration--
        }

        val maxValue = min(iteration, grid.size - 1)
        if (i < maxValue && j > 0) {
            i++
            j--
        } else {
            iteration++
            j = min(iteration, grid.size - 1)
            i = max(iteration - grid.size - 1, 0)
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
        try {
            val grid = readInput()
            findMinimumRisk(grid)
            val expandedGrid = expandGrid(grid)
            findMinimumRisk(expandedGrid)
        } catch (e: Exception) {
            println(e)
        }
    }.also { println("Cold run: $it ms") }

    (1..10).map {
        measureTimeMillis {
            val grid = readInput()
            findMinimumRisk(grid)
            val expandedGrid = expandGrid(grid)
            findMinimumRisk(expandedGrid)
        }
    }.average().also { println("Average of 10 warm runs: $it ms") }
}
