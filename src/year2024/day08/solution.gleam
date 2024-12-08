import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string

import simplifile
import utils

type Loc {
  Loc(x: Int, y: Int)
}

type Bounds {
  Bounds(x: #(Int, Int), y: #(Int, Int))
}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day08/input.txt")

  let matrix =
    input
    |> utils.trim_split("\n")
    |> list.map(string.to_graphemes)

  let assert [h, ..] = matrix
  let bounds = Bounds(#(0, list.length(h)), #(0, list.length(matrix)))

  #(dict.values(to_map(matrix)), bounds)
}

fn to_map(input) {
  use acc, row, y <- list.index_fold(input, dict.new())
  use acc, char, x <- list.index_fold(row, acc)

  let insert_loc = fn(c) {
    case c {
      Some(r) -> [Loc(x, y), ..r]
      None -> [Loc(x, y)]
    }
  }

  case char {
    "." -> acc
    _ -> dict.upsert(acc, char, insert_loc)
  }
}

fn gen_antinodes(locs_list: List(List(Loc)), bounds: Bounds, resonant: Bool) {
  use locs <- list.flat_map(locs_list)
  use #(l1, l2) <- list.flat_map(list.combination_pairs(locs))

  let dist_x = int.absolute_value(l1.x - l2.x)
  let dist_y = int.absolute_value(l1.y - l2.y)
  let a1 = new_loc(l1.x, l2.x, l1.y, l2.y, dist_x, dist_y)
  let a2 = new_loc(l2.x, l1.x, l2.y, l1.y, dist_x, dist_y)

  case resonant {
    False -> list.filter([a1, a2], within_bounds(_, bounds))
    True -> {
      [l1, l2]
      |> find_resonant(l1, a1, bounds, #(dist_x, dist_y))
      |> find_resonant(l2, a2, bounds, #(dist_x, dist_y))
    }
  }
}

fn new_point(a, b, dist) {
  use <- bool.guard(a < b, a - dist)
  a + dist
}

fn new_loc(x1, x2, y1, y2, dist_x, dist_y) {
  Loc(new_point(x1, x2, dist_x), new_point(y1, y2, dist_y))
}

fn within_bounds(loc: Loc, bounds: Bounds) {
  loc.x >= bounds.x.0
  && loc.x < bounds.x.1
  && loc.y >= bounds.y.0
  && loc.y < bounds.y.1
}

fn find_resonant(acc, prev: Loc, cur: Loc, bounds: Bounds, dist: #(Int, Int)) {
  use <- bool.guard(!within_bounds(cur, bounds), acc)

  let new_cur = new_loc(cur.x, prev.x, cur.y, prev.y, dist.0, dist.1)
  find_resonant([cur, ..acc], cur, new_cur, bounds, dist)
}

fn part_one(input) {
  let #(vals, bounds) = input

  vals
  |> gen_antinodes(bounds, False)
  |> set.from_list()
  |> set.size()
}

fn part_two(input) {
  let #(vals, bounds) = input

  vals
  |> gen_antinodes(bounds, True)
  |> set.from_list()
  |> set.size()
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
