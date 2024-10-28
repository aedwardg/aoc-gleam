import gleam/int
import gleam/io
import gleam/list
import gleam/string

import simplifile
import utils.{Global, TrimAll}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2017/day02/input.txt")

  input
  |> utils.erl_split("\n", [Global, TrimAll])
  |> list.map(fn(s) {
    s
    |> string.split("\t")
    |> list.filter_map(int.parse)
  })
}

fn part_one(input) {
  input
  |> list.map(fn(nums) {
    let assert Ok(max) = list.reduce(nums, int.max)
    let assert Ok(min) = list.reduce(nums, int.min)

    max - min
  })
  |> int.sum()
}

fn part_two(input) {
  input
  |> list.fold(0, fn(acc, nums) {
    let combos = list.combination_pairs(nums)
    let assert Ok(#(a, b)) =
      list.find(combos, fn(pair) {
        let #(a, b) = pair
        a % b == 0 || b % a == 0
      })

    acc + int.max(a, b) / int.min(a, b)
  })
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
