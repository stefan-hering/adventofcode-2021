package day17

object TargetArea {
    val x: Pair<Int, Int> = 211 to 232
    val y: Pair<Int, Int> = -124 to -69

    fun isWithin(position: ProbePosition) = withinX(position) && withinY(position)

    fun withinY(position: ProbePosition) =
        position.y >= y.first && position.y <= y.second

    fun withinX(position: ProbePosition) =
        position.x >= x.first && position.x <= x.second
}

data class Trajectory(
    val x: Int = 0,
    val y: Int = 0
) {
    fun next() = copy(
        x = if (x < 0) x + 1 else if (x > 0) x - 1 else 0,
        y = y - 1
    )
}

data class ProbePosition(
    val x: Int = 0,
    val y: Int = 0
) {
    fun move(trajectory: Trajectory) = copy(x = x + trajectory.x, y = y + trajectory.y)
}

fun step(position: ProbePosition, trajectory: Trajectory) =
    position.move(trajectory) to trajectory.next()

fun hits(initialTrajectory: Trajectory): Boolean {
    var position = ProbePosition()
    var trajectory = initialTrajectory
    while (position.x < TargetArea.x.second && trajectory.x > 0 || position.y > TargetArea.y.first || trajectory.y > 0) {
        step(position, trajectory).let {
            position = it.first
            trajectory = it.second
        }
        if (TargetArea.isWithin(position)) {
            return true
        }
    }
    return false
}

fun maxHeight(yTrajectory: Int): Int {
    var y = yTrajectory
    var height = 0
    while(y > 0) {
        height += y
        y--
    }
    return height
}

fun part1(validValues: List<Pair<Int,Int>>) =
    validValues.map { it.second }.maxOf { it }.let(::maxHeight).also(::println)

fun part2() = (TargetArea.y.first - 1..200).flatMap { y ->
    (1..TargetArea.x.second).mapNotNull { x ->
        if (hits(Trajectory(x = x, y = y))) {
            x to y
        } else {
            null
        }
    }
}.also(::part1).distinct().count().also(::println)

fun main() {
    part2()
}
