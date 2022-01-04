package day21

data class GameState(
    val positions: MutableList<Int> = mutableListOf(3, 10),
    val scores: MutableList<Int> = mutableListOf(0, 0),
    var turn: Int = 0
)

class Dice {
    private var nextRoll = 1
    private var rolls = 0

    private fun roll() = nextRoll.also { rolls++;nextRoll++; if (nextRoll == 101) nextRoll = 1; }

    fun roll(times: Int) = (1..times).fold(0) { acc, _ ->
        acc + roll()
    }

    fun totalRolls() = rolls
}


fun playPart1(gameState: GameState = GameState()): Pair<GameState, Dice> {
    val dice = Dice()

    while (gameState.scores.none { it >= 1000 }) {
        val diceRoll = dice.roll(3)

        with(gameState) {
            positions[turn] = (positions[turn] + diceRoll - 1) % 10 + 1
            scores[turn] = scores[turn] + positions[turn]
            turn = (turn + 1) % positions.size
        }
    }

    return gameState to dice
}

val quantumRoll = listOf(1, 2, 3)
    .flatMap { r1 -> listOf(1, 2, 3).map { it + r1 } }
    .flatMap { r2 -> listOf(1, 2, 3).map { it + r2 } }
    .groupBy { it }
    .map { it.key to it.value.size.toLong() }

// score+current position p1
// score+current position p2
data class SingleGameState(
    val position1: Int,
    val position2: Int,
    val score1: Int,
    val score2: Int
)

data class QuantumGameState(
    var scores: Map<SingleGameState, Long> = mutableMapOf(SingleGameState(3, 10, 0, 0) to 1),
    var tallyP1: Long = 0,
    var tallyP2: Long = 0
)

fun playPart2(gameState: QuantumGameState = QuantumGameState()) {
    var turn = 0
    with(gameState) {
        while (scores.isNotEmpty()) {
            val nextScores: MutableMap<SingleGameState, Long> = mutableMapOf()
            quantumRoll.forEach { (roll, rollCount) ->
                gameState.scores.forEach { (state, stateCount) ->
                    val newState = if (turn == 0) {
                        val newPosition = (state.position1 + roll - 1) % 10 + 1
                        state.copy(
                            position1 = newPosition,
                            score1 = state.score1 + newPosition
                        )
                    } else {
                        val newPosition = (state.position2 + roll - 1) % 10 + 1
                        state.copy(
                            position2 = newPosition,
                            score2 = state.score2 + newPosition
                        )
                    }
                    nextScores.putOrInc(newState, rollCount * stateCount)
                }
            }
            val (winning, playing) = nextScores.entries.partition {
                it.key.score1 >= 21 || it.key.score2 >= 21
            }
            gameState.scores = playing.map { it.key to it.value }.toMap()
            winning.partition { it.key.score1 >= 21 }.let {
                gameState.tallyP1 += it.first.sumOf { it.value }
                gameState.tallyP2 += it.second.sumOf { it.value }
            }
            turn = (turn + 1) % 2
        }
    }
    println(maxOf(gameState.tallyP1, gameState.tallyP2))
}

fun MutableMap<SingleGameState, Long>.putOrInc(state: SingleGameState, count: Long) =
    (get(state) ?: 0L).let {
        put(state, count + it)
    }

fun main() {
    val (finalState, dice) = playPart1()
    println(finalState.scores.minOf { it } * dice.totalRolls())

    playPart2()
}
