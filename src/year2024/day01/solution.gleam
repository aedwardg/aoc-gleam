import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result.{unwrap}

import simplifile
import utils.{Global, TrimAll}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day01/input.txt")

  input
  |> utils.erl_split("\n", [Global, TrimAll])
  |> list.fold([[], []], fn(acc, str) {
    let assert [l, r] = utils.erl_split(str, " ", [Global, TrimAll])
    let assert [ls, rs] = acc
    let assert Ok(left) = int.parse(l)
    let assert Ok(right) = int.parse(r)

    [[left, ..ls], [right, ..rs]]
  })
}

fn get_freqs(list) {
  let increment = fn(x) {
    case x {
      Some(i) -> i + 1
      None -> 1
    }
  }

  list.fold(list, dict.from_list([]), fn(acc, num) {
    dict.upsert(acc, num, increment)
  })
}

fn part_one(input) {
  let assert [lefts, rights] = list.map(input, list.sort(_, int.compare))

  lefts
  |> list.zip(rights)
  |> list.fold(0, fn(acc, pair) { acc + int.absolute_value(pair.0 - pair.1) })
}

fn part_two(input) {
  let assert [lefts, rights] = input
  let freqs = get_freqs(rights)

  list.fold(lefts, 0, fn(acc, num) {
    let n = freqs |> dict.get(num) |> unwrap(0)
    acc + num * n
  })
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
