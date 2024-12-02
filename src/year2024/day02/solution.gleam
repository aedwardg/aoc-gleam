import gleam/int
import gleam/io
import gleam/list
import gleam/string

import simplifile
import utils.{Global, TrimAll}

type Direction {
  Increasing
  Decreasing
}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day02/input.txt")

  input
  |> utils.erl_split("\n", [Global, TrimAll])
  |> list.map(fn(str) {
    str
    |> string.split(" ")
    |> list.filter_map(int.parse)
  })
}

fn check_for_safety(num_list) {
  let assert [first, second, ..] = num_list
  case int.absolute_value(first - second) {
    1 | 2 | 3 if first < second -> do_check_for_safety(num_list, Increasing)
    1 | 2 | 3 if first > second -> do_check_for_safety(num_list, Decreasing)
    _ -> False
  }
}

fn do_check_for_safety(num_list, direction) {
  let assert [first, ..rest] = num_list
  case direction {
    Increasing -> is_increasing(first, rest)
    Decreasing -> is_decreasing(first, rest)
  }
}

fn safe_value(a, b) {
  let dist = int.absolute_value(a - b)
  dist > 0 && dist < 4
}

fn is_increasing(first, rest) {
  case rest {
    [] -> True
    [next, ..] if next < first -> False
    [next, ..rem] -> safe_value(first, next) && is_increasing(next, rem)
  }
}

fn is_decreasing(first, rest) {
  case rest {
    [] -> True
    [next, ..] if next > first -> False
    [next, ..rem] -> safe_value(first, next) && is_decreasing(next, rem)
  }
}

fn create_possibles(num_list) {
  do_create_possibles(num_list, [num_list], [])
}

fn do_create_possibles(
  num_list: List(Int),
  possibles: List(List(Int)),
  head: List(Int),
) {
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
