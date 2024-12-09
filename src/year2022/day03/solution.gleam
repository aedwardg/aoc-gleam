import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2022/day03/input.txt")

  input
  |> string.trim_end()
  |> string.split("\n")
}

fn get_dup_priority(str) {
  let chars = string.to_graphemes(str)
  let #(c1, c2) = list.split(chars, at: list.length(chars) / 2)

  let assert [dup] =
    set.to_list(set.intersection(set.from_list(c1), set.from_list(c2)))

  priority(dup)
}

fn get_group_dup_priority(group) {
  let assert [a, b, c] =
    list.map(group, fn(g) {
      g
      |> string.to_graphemes()
      |> set.from_list()
    })

  let assert [dup] =
    a
    |> set.intersection(b)
    |> set.intersection(c)
    |> set.to_list()

  priority(dup)
}

fn priority(char) {
  let assert [codepoint] = string.to_utf_codepoints(char)

  let ord = string.utf_codepoint_to_int(codepoint)

  case ord > 90 {
    True -> ord - 96
    False -> ord - 38
  }
}

fn part_one(input) {
  input
  |> list.map(get_dup_priority)
  |> int.sum()
  |> io.debug()
}

fn part_two(input) {
  input
  |> list.sized_chunk(into: 3)
  |> list.map(get_group_dup_priority)
  |> int.sum()
  |> io.debug()
}

pub fn run() {
  let input = parse()
  io.println("Part 1:")
  part_one(input)
  io.println("Part 2:")
  part_two(input)
}
