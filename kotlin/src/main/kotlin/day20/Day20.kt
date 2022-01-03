package day20

fun readInput() = Unit.javaClass.getResource("/day20/input.txt")
    .readText()
    .split("\n\n")

fun parseGrid(grid: String) =
    grid.split("\n")
        .filter { it.isNotBlank() }
        .map { it.toCharArray() }
        .toTypedArray()

typealias Grid = Array<CharArray>

fun Grid.expand(): Grid = Array(size + 2) { CharArray(first().size + 2) { 'Ü' } }

fun Grid.neighbors(x: Int, y: Int, default: Char): String {
    return "" +
            get(x - 1, y - 1, default) +
            get(x - 1, y, default) +
            get(x - 1, y + 1, default) +
            get(x, y - 1, default) +
            get(x, y, default) +
            get(x, y + 1, default) +
            get(x + 1, y - 1, default) +
            get(x + 1, y, default) +
            get(x + 1, y + 1, default)
}

fun Grid.get(x: Int, y: Int, default: Char): Char =
    if (x >= 0 && y >= 0 && size > x && first().size > y)
        get(x)[y]
    else
        default

fun String.lightToInt() =
    replace('#', '1')
        .replace('.', '0')
        .toInt(2)

fun applyEnhancement(grid: Grid, algorithm: String, i: Int): Grid {
    val newGrid = grid.expand()

    for (x in newGrid.indices) {
        for (y in newGrid.first().indices) {
            // should have thought about the possible inputs :)
            newGrid[x][y] = grid.neighbors(x - 1, y - 1, if (algorithm[0] == '#' && i % 2 == 0) '#' else '.')
                .lightToInt()
                .let { algorithm[it] }
        }
    }

    return newGrid
}

fun Grid.countLights() = flatMap { it.toList() }.count { it == '#' }

fun main() {
    val (algorithm, initialGrid) = readInput().let {
        it[0].replace("\n", "") to parseGrid(it[1])
    }

    (1..2).fold(initialGrid) { grid, i ->
        applyEnhancement(grid, algorithm, i)
    }.also {
        println(it.countLights())
    }.let {
        (3..50).fold(it) { grid, i ->
            applyEnhancement(grid, algorithm, i)
        }
    }.also {
        println(it.countLights())
    }
}
