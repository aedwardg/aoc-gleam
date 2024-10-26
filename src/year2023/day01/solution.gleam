import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regex.{Match}

import simplifile
import utils.{Global, TrimAll}

const digit = "[[:digit:]]"

const all_digits = "(?=([[:digit:]]|one|two|three|four|five|six|seven|eight|nine))"

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2023/day01/input.txt")

  input
  |> utils.erl_split("\n", [Global, TrimAll])
}

fn to_num(n) {
  case n {
    "1" | "one" -> "1"
    "2" | "two" -> "2"
    "3" | "three" -> "3"
    "4" | "four" -> "4"
    "5" | "five" -> "5"
    "6" | "six" -> "6"
    "7" | "seven" -> "7"
    "8" | "eight" -> "8"
    "9" | "nine" -> "9"
    _ -> "not a number"
  }
}

fn extract_match(m, s) {
  case m {
    "" -> {
      let assert [Some(sub), ..] = s
      to_num(sub)
    }
    _ -> to_num(m)
  }
}

fn sum_first_and_last(input, pattern) {
  list.fold(input, 0, fn(acc, s) {
    let assert [Match(first_match, first_sub), ..rest] = regex.scan(pattern, s)

    let first = extract_match(first_match, first_sub)

    let calibration_val = case list.last(rest) {
      Ok(Match(last_match, last_sub)) ->
        first <> extract_match(last_match, last_sub)
      Error(Nil) -> first <> first
    }

    let assert Ok(int_val) = int.parse(calibration_val)
    int_val + acc
  })
}

fn part_one(input) {
  let assert Ok(pattern) = regex.from_string(digit)
  sum_first_and_last(input, pattern)
}

fn part_two(input) {
  let assert Ok(pattern) = regex.from_string(all_digits)
  sum_first_and_last(input, pattern)
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
