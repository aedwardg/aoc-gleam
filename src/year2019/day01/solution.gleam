import gleam/int
import gleam/io
import gleam/list

import simplifile
import utils.{Global, TrimAll}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2019/day01/input.txt")
  utils.erl_split(input, "\n", [Global, TrimAll])
}

fn calculate_fuel(num) {
  num / 3 - 2
}

fn calculate_all_fuel(num, acc) {
  case calculate_fuel(num) {
    n if n < 1 -> acc
    n -> calculate_all_fuel(n, acc + n)
  }
}

fn part_one(input) {
  input
  |> list.fold(0, fn(acc, num) {
    let assert Ok(n) = int.parse(num)
    acc + calculate_fuel(n)
  })
}

fn part_two(input) {
  input
  |> list.filter_map(int.parse)
  |> list.map(calculate_all_fuel(_, 0))
  |> int.sum()
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
