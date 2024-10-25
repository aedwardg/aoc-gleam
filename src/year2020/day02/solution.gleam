import gleam/int
import gleam/io
import gleam/list
import gleam/regex
import gleam/string

import simplifile

fn parse() {
  let assert Ok(re) = regex.from_string("[ \\-:]")
  let assert Ok(input) = simplifile.read("src/year2020/day02/input.txt")

  input
  |> string.split("\n")
  |> list.filter_map(fn(s) {
    case s {
      "" -> Error(#())
      str -> Ok(transform(str, re))
    }
  })
}

fn transform(str, re) {
  let assert [low, high, char, _blank, pw] = regex.split(with: re, content: str)
  let assert Ok(low) = int.parse(low)
  let assert Ok(high) = int.parse(high)
  #(low, high, char, pw)
}

fn part_one(input) {
  input
  |> list.count(where: fn(policy) {
    let #(low, high, char, pw) = policy

    let char_count =
      pw
      |> string.to_graphemes()
      |> list.count(fn(c) { c == char })

    char_count >= low && char_count <= high
  })
  |> io.debug()
}

fn part_two(input) {
  input
  |> list.count(fn(policy) {
    let #(low, high, char, pw) = policy

    let char_at_idx =
      pw
      |> string.to_graphemes()
      |> list.index_fold(0, fn(acc, c, i) {
        case c == char {
          True if i + 1 == low || i + 1 == high -> acc + 1
          _ -> acc
        }
      })

    char_at_idx == 1
  })
  |> io.debug()
}

pub fn run() {
  let input = parse()
  io.println("Part 1:")
  part_one(input)
  io.println("Part 2:")
  part_two(input)
}
