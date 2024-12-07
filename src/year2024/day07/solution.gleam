import gleam/int
import gleam/io
import gleam/list
import gleam/string

import simplifile
import utils

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day07/input.txt")

  input
  |> utils.trim_split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(total, val_str)) = string.split_once(line, ": ")
    let vals =
      val_str
      |> utils.trim_split(" ")
      |> list.map(utils.force_int)

    #(utils.force_int(total), vals)
  })
}

fn fanout(equation, concat) {
  let assert #(_total, [h, ..t]) = equation
  use acc, val <- list.fold(t, [h])
  use prev <- list.flat_map(acc)
  case concat {
    False -> [prev + val, prev * val]
    True -> [prev + val, prev * val, concat_digits(prev, val)]
  }
}

fn concat_digits(prev, val) {
  utils.force_int(int.to_string(prev) <> int.to_string(val))
}

fn count_valid(input, concat) {
  input
  |> list.fold([], fn(acc, equation) {
    let possibles = fanout(equation, concat)
    case list.any(possibles, fn(num) { num == equation.0 }) {
      True -> [equation.0, ..acc]
      False -> acc
    }
  })
  |> int.sum()
}

fn part_one(input) {
  count_valid(input, False)
}

fn part_two(input) {
  count_valid(input, True)
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
