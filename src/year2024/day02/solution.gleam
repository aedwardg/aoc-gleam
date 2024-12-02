import gleam/int
import gleam/io
import gleam/list
import gleam/string

import simplifile
import utils

type Direction {
  Asc
  Desc
}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day02/input.txt")

  input
  |> utils.trim_split("\n")
  |> list.map(fn(str) {
    str
    |> string.split(" ")
    |> list.filter_map(int.parse)
  })
}

fn check_for_safety(num_list) {
  let pairs = list.window_by_2(num_list)
  safe_distance(pairs)
}

fn safe_distance(pairs: List(#(Int, Int))) {
  list.all(pairs, fn(pair) { safe_value(pair.0, pair.1, Asc) })
  || list.all(pairs, fn(pair) { safe_value(pair.0, pair.1, Desc) })
}

fn safe_value(a, b, direction: Direction) {
  case direction {
    Asc -> a - b > 0 && a - b < 4
    Desc -> a - b < 0 && a - b > -4
  }
}

fn create_groups(num_list: List(Int)) {
  do_create_groups(num_list, [num_list], [])
}

fn new_group(head, t) {
  list.append(list.reverse(head), t)
}

fn do_create_groups(num_list, groups, head) {
  case num_list, head {
    [], _ -> groups
    [h, ..t], [] -> do_create_groups(t, [t, ..groups], [h])
    [h, ..t], head ->
      do_create_groups(t, [new_group(head, t), ..groups], [h, ..head])
  }
}

fn part_one(input) {
  list.count(input, check_for_safety)
}

fn part_two(input) {
  list.count(input, fn(num_list) {
    let groups = create_groups(num_list)
    list.any(groups, check_for_safety)
  })
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
