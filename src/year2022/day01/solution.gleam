import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn run() {
  io.println("Hello from day 1!")
  let assert Ok(input) = simplifile.read("src/year2022/day01/input.txt")

  let input =
    input
    |> string.split("\n\n")
    |> list.map(fn(s) {
      s
      |> string.split("\n")
      |> list.filter_map(int.parse)
    })

  io.println("Part 1:")

  input
  |> part_one()
  |> io.debug()

  io.println("Part 2:")
  input
  |> part_two()
  |> io.debug()
}

fn sum_calories(elves) {
  list.map(elves, int.sum)
}

fn part_one(input) {
  let assert Ok(max) =
    input
    |> sum_calories()
    |> list.reduce(int.max)

  max
}

fn part_two(input) {
  let assert [e1, e2, e3, ..] =
    input
    |> sum_calories()
    |> list.sort(fn(a, b) { int.compare(b, a) })

  int.sum([e1, e2, e3])
}
