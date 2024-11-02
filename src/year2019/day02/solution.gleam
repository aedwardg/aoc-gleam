import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string

import simplifile
import utils.{Global, TrimAll}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2019/day02/input.txt")
  input
  |> utils.erl_split("\n", [Global, TrimAll])
  |> list.flat_map(string.split(_, ","))
  |> list.filter_map(int.parse)
}

fn construct_map(input) {
  list.index_fold(input, dict.new(), fn(acc, num, i) {
    dict.insert(acc, i, num)
  })
}

fn get_vals(map, cur) {
  let assert Ok(pos1) = dict.get(map, cur + 1)
  let assert Ok(pos2) = dict.get(map, cur + 2)
  let assert Ok(val1) = dict.get(map, pos1)
  let assert Ok(val2) = dict.get(map, pos2)
  let assert Ok(save_at) = dict.get(map, cur + 3)
  #(val1, val2, save_at)
}

fn get_combos() {
  let vals = list.range(0, 99)
  let vals = list.append(vals, vals)

  vals
  |> list.combination_pairs()
}

fn add(map, cur) {
  let #(val1, val2, save_at) = get_vals(map, cur)
  let map = dict.insert(map, save_at, val1 + val2)
  process(map, cur + 4)
}

fn multiply(map, cur) {
  let #(val1, val2, save_at) = get_vals(map, cur)
  let map = dict.insert(map, save_at, val1 * val2)
  process(map, cur + 4)
}

fn process(map, cur) {
  let assert Ok(start) = dict.get(map, cur)
  case start {
    99 -> dict.get(map, 0)
    1 -> add(map, cur)
    2 -> multiply(map, cur)
    _ -> panic as "Something went wrong"
  }
}

fn brute_force(map, combos) {
  let assert [#(noun, verb), ..rest] = combos
  let altered_map =
    map
    |> dict.insert(1, noun)
    |> dict.insert(2, verb)

  case process(altered_map, 0) {
    Ok(19_690_720) -> #(noun, verb)
    Ok(..) -> brute_force(map, rest)
    _ -> panic as "failed brute force"
  }
}

fn part_one(input) {
  let assert Ok(output) =
    input
    |> construct_map()
    |> dict.insert(1, 12)
    |> dict.insert(2, 2)
    |> process(0)

  output
}

fn part_two(input) {
  let combos = get_combos()
  let map = construct_map(input)
  let #(noun, verb) = brute_force(map, combos)
  100 * noun + verb
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
