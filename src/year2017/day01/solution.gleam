import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import simplifile

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2017/day01/input.txt")

  input
  |> string.trim()
  |> string.to_graphemes()
}

fn to_int(str) {
  result.unwrap(int.parse(str), 0)
}

fn find_neighbors(input) {
  let assert [first, second, ..list] = input
  case first == second {
    True -> do_find_neighbors([second, ..list], first, [to_int(first)])
    False -> do_find_neighbors([second, ..list], first, [])
  }
}

fn do_find_neighbors(list, first, neighbors) {
  let assert [h, ..t] = list
  case t {
    [] if h == first -> [to_int(h), ..neighbors]
    [] -> neighbors
    [second, ..rest] if h == second ->
      do_find_neighbors([second, ..rest], first, [to_int(h), ..neighbors])
    tail -> do_find_neighbors(tail, first, neighbors)
  }
}

fn create_comp_list(list) {
  let mid_idx = list.length(list) / 2
  let #(front, back) = list.split(list, at: mid_idx)
  list.append(back, front)
}

fn compare(list, comp) {
  do_compare(list, comp, [])
}

fn do_compare(list, comp, matches) {
  case list, comp {
    [], [] -> matches
    [f1, ..rest1], [f2, ..rest2] if f1 == f2 ->
      do_compare(rest1, rest2, [to_int(f1), ..matches])
    l, c -> {
      let assert [_, ..rest1] = l
      let assert [_, ..rest2] = c
      do_compare(rest1, rest2, matches)
    }
  }
}

fn part_one(input) {
  input
  |> find_neighbors()
  |> int.sum()
}

fn part_two(input) {
  let comp = create_comp_list(input)

  input
  |> compare(comp)
  |> int.sum()
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
