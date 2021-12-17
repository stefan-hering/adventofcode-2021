package day15

import java.lang.Math.min
import kotlin.system.measureNanoTime
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

fun solveGrid(grid: Grid) {
    val minCosts: Array<IntArray> = Array(grid.size) {
        IntArray(grid.size) { Integer.MAX_VALUE }
    }

    var i = 0
    var j = 0
    while (i < grid.size && j < grid.size) {
        minCosts[i][j] = if (i > 0 && j > 0) {
            min(minCosts[i][j], min(minCosts[i - 1][j], minCosts[i][j - 1]) + grid[i][j])
        } else if (j > 0) {
            min(minCosts[i][j], minCosts[i][j - 1] + grid[i][j])
        } else if (i > 0) {
            min(minCosts[i][j], minCosts[i - 1][j] + grid[i][j])
        } else 0


        if (i > 0 &&
            minCosts[i - 1][j] > minCosts[i][j] + grid[i - 1][j]
        ) {
            while (i > 0 && minCosts[i - 1][j] > minCosts[i][j] + grid[i - 1][j]) {
                minCosts[i - 1][j] = minCosts[i][j] + grid[i - 1][j]
                i--
            }
        } else if (j > 0 && minCosts[i][j - 1] > minCosts[i][j] + grid[i][j - 1]) {
            while (j > 0 && minCosts[i][j - 1] > minCosts[i][j] + grid[i][j - 1]) {
                minCosts[i][j - 1] = minCosts[i][j] + grid[i][j - 1]
                j--
            }
        } else {
            j++;
            if (j == grid.size) {
                j = 0;
                i++;
            }
        }
    }

    println(minCosts[grid.size - 1][grid.size - 1])
}

fun main() {
    val grid = readInput()
    solveGrid(grid)

    val expandedGrid = (0..4).flatMap { x ->
        grid.map { row ->
            (0..4).flatMap { y ->
                row.map {
                    (it + x + y - 1) % 9 + 1
                }
            }
        }
    }
    measureTimeMillis {
        solveGrid(expandedGrid)
    }.also { println("Took $it ms") }
}
