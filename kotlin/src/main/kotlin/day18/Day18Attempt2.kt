package day18

fun readInputValues() = Unit.javaClass.getResource("/day18/input.txt")
    .readText()
    .lines()
    .filter { it.isNotEmpty() }

fun findIndexToExplode(number: String): Int? {
    number.toCharArray().foldIndexed(0) { i, acc, char ->
        if (acc > 4 && char.isDigit() && number.substring(i).substringAfter(',')[0].isDigit()) {
            return i - 1
        }
        if (char == '[') {
            acc + 1
        } else if (char == ']') {
            acc - 1
        } else {
            acc
        }
    }
    return null
}

fun explodeIndex(number: String, index: Int): String {
    val left = number.substring(0, index)
    val (pair, right) = number.substring(index + 1, number.length).let {
        it.substringBefore(']') to it.substringAfter(']')
    }

    val numbers = pair.split(",")

    val lastIndexLeft = left.indexOfLast {
        it.isDigit()
    }
    val firstIndexRight = right.indexOfFirst {
        it.isDigit()
    }

    val leftReplaced = if (lastIndexLeft != -1) {
        val firstIndexLeft = left.substring(0, lastIndexLeft).indexOfLast {
            !it.isDigit()
        }

        val replacement =
            (left.substring(firstIndexLeft + 1, lastIndexLeft + 1).toInt() + numbers[0].toInt()).toString()
        left.replaceRange(firstIndexLeft + 1, lastIndexLeft + 1, replacement)
    } else left

    val rightReplaced = if (firstIndexRight != -1) {
        val lastIndexRight = right.substring(firstIndexRight).indexOfFirst { !it.isDigit() } + firstIndexRight

        val replacement = (right.substring(firstIndexRight, lastIndexRight).toInt() + numbers[1].toInt()).toString()
        right.replaceRange(firstIndexRight, lastIndexRight, replacement)
    } else right

    return leftReplaced + "0" + rightReplaced
}

val splitFinder = Regex("[0-9]{2,}")
fun findSplitIndex(number: String) =
    splitFinder.find(number)?.range

fun splitIndex(number: String, splitIndex: IntRange): String {
    val left = number.substring(0, splitIndex.first)
    val toSplit = number.substring(splitIndex.first, splitIndex.last + 1).toInt()
    val right = number.substring(splitIndex.last + 1)

    return left + "[${toSplit / 2},${toSplit - toSplit / 2}]" + right
}

fun reduceNumber(initialNumber: String): String {
    var needsToExplode: Boolean
    var needsToSplit: Boolean
    var number: String = initialNumber
    do {
        needsToExplode = false
        needsToSplit = false
        val explodeIndex = findIndexToExplode(number)
        if (explodeIndex != null) {
            needsToExplode = true
            number = explodeIndex(number, explodeIndex)
        }
        if (!needsToExplode) {
            val splitIndex = findSplitIndex(number)
            if (splitIndex != null) {
                needsToSplit = true
                number = splitIndex(number, splitIndex)
            }
        }

    } while (needsToExplode || needsToSplit)
    return number
}

fun add(number1: String, number2: String) = "[$number1,$number2]"

fun part1(numbers: List<String>) = numbers.reduce { left, right ->
    add(reduceNumber(left), right)
}.let { reduceNumber(it) }
    .let { magnitude(it) }

// pop pop
fun magnitude(number: String) = magnitude(parsePair(number).first as ActualPair)

fun part2(numbers: List<String>) =
    numbers.maxOf { a ->
        numbers.maxOf { b ->
            part1(listOf(a, b))
        }
    }

fun main() {
    val input = readInputValues()
    println(part1(input))
    println(part2(input))
}
