import gleam/dict
import gleam/io
import gleam/list
import gleam/string

import simplifile
import utils

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day04/input.txt")

  input
  |> utils.trim_split("\n")
  |> list.map(string.to_graphemes)
  |> to_map()
}

fn to_map(input) {
  use acc, row, y <- list.index_fold(input, dict.new())
  use acc, char, x <- list.index_fold(row, acc)
  dict.insert(acc, #(x, y), char)
}

fn surrounding() {
  [
    fn(x, y) { #(x - 1, y - 1) },
    fn(x, y) { #(x, y - 1) },
    fn(x, y) { #(x + 1, y - 1) },
    fn(x, y) { #(x - 1, y) },
    fn(x, y) { #(x + 1, y) },
    fn(x, y) { #(x - 1, y + 1) },
    fn(x, y) { #(x, y + 1) },
    fn(x, y) { #(x + 1, y + 1) },
  ]
}

fn find_letter(input, letter) {
  input
  |> dict.filter(fn(_key, v) { v == letter })
  |> dict.to_list()
}

fn get_next(chars, x, y, next_fn, map) {
  let coord: #(Int, Int) = next_fn(x, y)
  case chars {
    [] -> True
    [cur, ..rest] ->
      case dict.get(map, coord) {
        Ok(char) if char == cur ->
          get_next(rest, coord.0, coord.1, next_fn, map)
        _ -> False
      }
  }
}

fn get_corners(entry, map) {
  let #(#(x, y), _) = entry
  [#(x - 1, y - 1), #(x + 1, y - 1), #(x - 1, y + 1), #(x + 1, y + 1)]
  |> list.map(dict.get(map, _))
}

fn check_xmas(corners) {
  case corners {
    [Ok(tl), Ok(tr), Ok(bl), Ok(br)] -> verify_x(tl, tr, bl, br)
    _ -> False
  }
}

fn verify_x(tl, tr, bl, br) {
  case tl, tr, bl, br {
    "M", "M", "S", "S" -> True
    "M", "S", "M", "S" -> True
    "S", "M", "S", "M" -> True
    "S", "S", "M", "M" -> True
    _, _, _, _ -> False
  }
}

fn part_one(input) {
  input
  |> find_letter("X")
  |> list.flat_map(fn(entry) {
    let #(#(x, y), _) = entry
    let next_fns = surrounding()

    list.map(next_fns, get_next(["M", "A", "S"], x, y, _, input))
  })
  |> list.count(fn(a) { a == True })
}

fn part_two(input) {
  input
  |> find_letter("A")
  |> list.map(get_corners(_, input))
  |> list.count(fn(cs) { check_xmas(cs) == True })
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
