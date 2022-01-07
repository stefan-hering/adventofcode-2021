package day24

import org.antlr.v4.kotlinruntime.CharStreams
import org.antlr.v4.kotlinruntime.CommonTokenStream
import kotlin.random.Random
import day24.Day24Parser.LineContext as Line

fun readInput() = Day24Parser(
    CommonTokenStream(
        Day24Lexer(
            CharStreams.fromStream(
                Unit.javaClass.getResourceAsStream("/day24/input.txt")
            )
        )
    )
)

data class Parameter(
    val variable: String? = null,
    val value: Long? = null,
)

data class ProgramState(
    val inputs: List<Long>,
    val vars: MutableMap<String, Long> = mutableMapOf(),
) {
    private var currentInput: Int = 0

    fun get(param: Parameter): Long =
        if (param.variable != null) {
            vars[param.variable]
        } else {
            param.value
        } ?: 0L

    fun nextInput() =
        inputs[currentInput].also { currentInput++ }
}

fun Line.isInput(): Boolean = findInput() != null

fun Line.getInputVar(): String =
    findInput()?.TARGET()
        ?.text
        ?: throw RuntimeException("Not valid input: $this")

fun Line.getInstruction(): String =
    findCommand()?.INSTRUCTION()
        ?.text
        ?: throw RuntimeException("Not a valid command: $this")

fun Line.getParameters(): Pair<String, Parameter> {
    val command = this.findCommand() ?: throw RuntimeException("Not a command: $this")
    return if (command.TARGET().size == 2) {
        command.TARGET(0).text to
                Parameter(variable = command.TARGET(1).text)
    } else {
        command.TARGET(0).text to
                Parameter(value = command.VALUE()!!.text.toLong())
    }
}

fun execute(inputs: List<Long>, lines: List<Line>): ProgramState {
    val programState = ProgramState(inputs)
    lines.forEach {
        executeLine(it, programState)
    }
    return programState
}

fun executeLine(line: Line, state: ProgramState) {
    if (line.isInput()) {
        state.vars.put(line.getInputVar(), state.nextInput())
    } else {
        val params = line.getParameters()
        val firstValue = state.vars.get(params.first) ?: 0L
        when (line.getInstruction()) {
            "add" -> state.vars.put(params.first, firstValue + state.get(params.second))
            "mul" -> state.vars.put(params.first, firstValue * state.get(params.second))
            "div" -> state.vars.put(params.first, firstValue / state.get(params.second))
            "mod" -> state.vars.put(params.first, firstValue % state.get(params.second))
            "eql" -> state.vars.put(
                params.first, if (firstValue == state.get(params.second)) 1 else 0
            )
        }
    }
}

fun printProgram(lines: List<Line>) {
    lines.map {
        val input = it.findInput()
        if (input != null) {
            println("Input for : " + input.TARGET())
        } else {
            it.findCommand()?.let {
                println("${it.INSTRUCTION()} ${it.TARGET()}")
            }
        }
    }
}

fun main() {
    val parser = readInput()
    val lines = parser.program().findLine().let {
        // Not quite sure why it's reading the input twice
        it.subList(0, it.size / 2)
    }

    execute(listOf(0, 1, 6, 9, 8, 7, 5, 2, 4, 4, 9, 4, 9, 0), lines).also { println(it) }

    part1(lines)
    part2(lines)
}


fun part1(lines: List<Line>) {
    bruteForce(lines, 9 downTo 1)
}

fun part2(lines: List<Line>) {
    bruteForce(lines, 1 .. 9)
}

fun bruteForce(lines: List<Line>, direction: IntProgression) {
    var knownPrefix = listOf<Long>()
    while(knownPrefix.size < 14) {
        for(i in direction) {
            val triedPrefix = knownPrefix + i.toLong()
            var input = triedPrefix + (1..(14 - triedPrefix.size)).map { Random.nextLong(1, 10) }
            var previousZ = execute(input, lines).vars["z"]!!
            var iteration = 0
            var totalIteration = 0
            while (previousZ > 0) {
                for (i in (triedPrefix.size + 1) until 14) {
                    (1..9).forEach {
                        val newInput = input.map { it }.toMutableList()
                        newInput[i] = it.toLong()
                        val result = execute(newInput, lines)
                        if (result.vars["z"]!! < previousZ) {
                            input = newInput
                            iteration = 0
                            previousZ = result.vars["z"]!!
                        }
                    }
                }
                iteration++
                totalIteration++
                if(iteration > 1) {
                    input = triedPrefix + (1..(14 - triedPrefix.size)).map { Random.nextLong(1, 10) }
                    previousZ = execute(input, lines).vars["z"]!!
                    iteration = 0
                }
                if(totalIteration > 1000) {
                    break
                }
            }

            if(previousZ == 0L) {
                println("found prefix: $i, $knownPrefix")
                knownPrefix = knownPrefix + i.toLong()
                break
            } else {
                println("not finding number for $i")
            }
        }
    }
    println(knownPrefix.joinToString(""))
}
