import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/string

import simplifile
import utils

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day03/input.txt")

  input
  |> utils.trim_split("\n")
  |> string.concat()
}

fn parse_matches(input) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3})\\,(\\d{1,3})\\)")

  input
  |> regexp.scan(re, _)
  |> list.map(fn(match) {
    let assert Match(_, [Some(a), Some(b)]) = match
    let assert Ok(a) = int.parse(a)
    let assert Ok(b) = int.parse(b)

    #(a, b)
  })
}

fn split_donts(input) {
  let assert Ok(split_re) = regexp.from_string("don't\\(\\)((?!do\\(\\)).)*")
  regexp.split(split_re, input)
}

fn compute(pairs: List(#(Int, Int))) {
  pairs
  |> list.map(fn(pair) { pair.0 * pair.1 })
  |> int.sum()
}

fn part_one(input) {
  input
  |> parse_matches()
  |> compute()
}

fn part_two(input) {
  input
  |> split_donts()
  |> list.flat_map(parse_matches)
  |> compute()
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
