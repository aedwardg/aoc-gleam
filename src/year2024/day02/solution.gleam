import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string

import simplifile

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day02/input.txt")

  input
  |> string.split("\n")
  |> list.map(fn(str) {
    str
    |> string.split(" ")
    |> list.filter_map(int.parse)
  })
}

fn check_for_safety(num_list) {
  let pairs = list.window_by_2(num_list)

  safe_distance(pairs) && all_asc_or_desc(pairs)
}

fn safe_distance(pairs: List(#(Int, Int))) {
  list.all(pairs, fn(pair) { safe_value(pair.0, pair.1) })
}

fn all_asc_or_desc(pairs: List(#(Int, Int))) {
  pairs
  |> list.map(fn(pair) { int.compare(pair.0, pair.1) })
  |> set.from_list()
  |> set.size()
  == 1
}

fn safe_value(a, b) {
  let dist = int.absolute_value(a - b)
  dist > 0 && dist < 4
}

fn create_possibles(num_list: List(Int)) {
  do_create_possibles(num_list, [num_list], [])
}

fn do_create_possibles(num_list, possibles, head) {
  case num_list, head {
    [], _ -> possibles
    [h, ..t], [] -> do_create_possibles(t, [t, ..possibles], [h])
    [h, ..t], head ->
      do_create_possibles(t, [list.append(list.reverse(head), t), ..possibles], [
        h,
        ..head
      ])
  }
}

fn part_one(input) {
  input
  |> list.fold(0, fn(acc, num_list) {
    case check_for_safety(num_list) {
      True -> acc + 1
      False -> acc
    }
  })
}

fn part_two(input) {
  input
  |> list.fold(0, fn(acc, num_list) {
    let possibles = create_possibles(num_list)
    case list.any(possibles, check_for_safety) {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
