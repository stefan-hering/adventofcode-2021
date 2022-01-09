package day18

fun readInput() = Unit.javaClass.getResource("/day18/testinput.txt")
    .readText()
    .lines()
    .filter { it.isNotEmpty() }
    .map(::parsePair)

sealed class SnailfishPair(
    open var parent: ActualPair?,
    val id: Int = (Int.MAX_VALUE * Math.random()).toInt()
)

class Number(
    val x: Int,
    override var parent: ActualPair? = null
) : SnailfishPair(parent)

class ActualPair(
    var left: SnailfishPair,
    var right: SnailfishPair,
    override var parent: ActualPair? = null
) : SnailfishPair(parent)

fun parsePair(input: String): Pair<SnailfishPair, String> {
    val strippedBrackets = input.substring(1, input.length)
    val (left: SnailfishPair, rest: String) = if (strippedBrackets.startsWith("[")) {
        parsePair(strippedBrackets)
    } else {
        Number(strippedBrackets.first().digitToInt()) to strippedBrackets.substring(1)
    }
    val strippedComma = rest.substring(1)
    val (right, newRest) = if (strippedComma.startsWith("[")) {
        parsePair(strippedComma)
    } else {
        Number(strippedComma.first().digitToInt()) to strippedComma.substring(1)
    }

    val pair = ActualPair(left = left, right = right) to newRest.substring(1)
    left.parent = pair.first
    right.parent = pair.first
    return pair;
}

fun reduce(rootPair: ActualPair): ActualPair {
    var didExplode: Boolean
    var didSplit: Boolean

    do {
        didExplode = pairToExplode(rootPair)?.let { explosion ->
            explosion.parent?.let { parent: ActualPair ->
                if (parent.left.id == explosion.id) {
                    parent.left = Number(0, parent)
                    addRightChild(parent, (explosion.right as Number).x)
                    addLeftToParent(parent, (explosion.left as Number).x)
                } else {
                    parent.right = Number(0, parent)
                    addLeftChild(parent, (explosion.left as Number).x)
                    addRightToParent(parent, (explosion.right as Number).x)
                }
            }
            true
        } ?: false

        didSplit = split(rootPair)
    } while (didSplit || didExplode)

    return rootPair
}

fun addLeftChild(parent: ActualPair, value: Int, first: Boolean = true) {
    if (first) {
        when (parent.left) {
            is ActualPair -> addLeftChild(parent.left as ActualPair, value, false)
            is Number -> parent.left = Number(value + (parent.left as Number).x, parent)
        }
    } else {
        when (parent.right) {
            is ActualPair -> addLeftChild(parent.right as ActualPair, value, false)
            is Number -> parent.right = Number(value + (parent.right as Number).x, parent)
        }
    }
}

fun addRightChild(parent: ActualPair, value: Int, first: Boolean = true) {
    if (first) {
        when (parent.right) {
            is ActualPair -> addRightChild(parent.right as ActualPair, value, false)
            is Number -> parent.right = Number(value + (parent.right as Number).x, parent)
        }
    } else {
        when (parent.left) {
            is ActualPair -> addRightChild(parent.left as ActualPair, value, false)
            is Number -> parent.left = Number(value + (parent.left as Number).x, parent)
        }
    }
}

fun addLeftToParent(explosionSource: ActualPair, value: Int) {
    val parent = explosionSource.parent ?: return

    if (parent.left.id == explosionSource.id) {
        parent.parent?.let {
            addLeftToParent(it, value)
        }
    } else {
        addLeftChild(parent, value)
    }
}

fun addRightToParent(explosionSource: ActualPair, value: Int) {
    val parent = explosionSource.parent ?: return

    if (parent.right.id == explosionSource.id) {
        parent.parent?.let {
            addRightToParent(it, value)
        }
    } else {
        addRightChild(parent, value)
    }
}


fun pairToExplode(pair: SnailfishPair, currentDepth: Int = 1): ActualPair? {
    when (pair) {
        is Number -> return null
        is ActualPair -> {
            val left = pairToExplode(pair.left, currentDepth + 1)

            if (left != null) {
                return left
            }

            if (currentDepth >= 4 && pair.left is Number && pair.right is Number) {
                return pair
            }

            return pairToExplode(pair.right, currentDepth + 1)
        }
    }
}

fun split(pair: ActualPair): Boolean {
    return when {
        pair.left is Number && (pair.left as Number).x >= 10 -> {
            pair.left = ActualPair(
                left = Number((pair.left as Number).x / 2),
                right = Number((pair.left as Number).x - (pair.left as Number).x / 2)
            )
            true
        }
        pair.left is ActualPair -> split(pair.left as ActualPair)
        pair.right is Number && (pair.right as Number).x >= 10 -> {
            pair.right = ActualPair(
                left = Number((pair.right as Number).x / 2),
                right = Number((pair.right as Number).x - (pair.right as Number).x / 2)
            )
            true
        }
        pair.right is ActualPair -> split(pair.right as ActualPair)
        else -> false
    }
}

fun addInputs(pairs: List<SnailfishPair>) = pairs.reduce { left, right ->
    reduce(left as ActualPair)
    val newRoot = ActualPair(
        left = left,
        right = right
    )
    left.parent = newRoot
    right.parent = newRoot
    newRoot
}.let { reduce(it as ActualPair) }

fun magnitude(pair: ActualPair): Long = when (pair.left) {
    is Number -> 3 * (pair.left as Number).x
    is ActualPair -> 3 * magnitude(pair.left as ActualPair)
}.toLong() + when (pair.right) {
    is Number -> 2 * (pair.right as Number).x
    is ActualPair -> 2 * magnitude(pair.right as ActualPair)
}.toLong()

fun main() {
    val input = readInput()
        .map { it.first }

    val finalThing = addInputs(input)
    println(magnitude(finalThing))
}
