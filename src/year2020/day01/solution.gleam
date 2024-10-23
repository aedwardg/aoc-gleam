import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2020/day01/input.txt")

  input
  |> string.split("\n")
  |> list.filter_map(int.parse)
}

fn find_two(input) {
  let assert [h, ..t] = input
  case list.find(t, fn(i) { h + i == 2020 }) {
    Ok(num) -> h * num
    Error(Nil) -> find_two(t)
  }
}

fn find_three(input) {
  let assert [[x, y, z], ..t] = input
  case x + y + z {
    2020 -> x * y * z
    _ -> find_three(t)
  }
}

fn part_one(input) {
  input
  |> find_two()
  |> io.debug()
}

fn part_two(input) {
  input
  |> list.combinations(by: 3)
  |> find_three()
  |> io.debug()
}

pub fn run() {
  let input = parse()
  io.println("Part 1:")
  part_one(input)
  io.println("Part 2:")
  part_two(input)
}
