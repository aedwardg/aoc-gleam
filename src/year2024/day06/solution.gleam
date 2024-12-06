import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

import simplifile
import utils

pub type Direction {
  Up
  Down
  Left
  Right
}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day06/input.txt")

  input
  |> utils.trim_split("\n")
  |> list.map(string.to_graphemes)
  |> to_map()
}

fn to_map(input) {
  use acc, row, y <- list.index_fold(input, #(dict.new(), #(#(-1, -1), Up)))
  use acc, char, x <- list.index_fold(row, acc)
  let #(map, start) = acc
  case char {
    "<" | "^" | ">" | "v" -> #(dict.insert(map, #(x, y), char), #(
      #(x, y),
      to_dir(char),
    ))
    _ -> #(dict.insert(map, #(x, y), char), start)
  }
}

fn to_dir(char) {
  case char {
    "^" -> Up
    "v" -> Down
    "<" -> Left
    ">" -> Right
    _ -> panic as "WTF"
  }
}

fn rotate(dir: Direction) {
  case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn get_next(cur: #(#(Int, Int), Direction)) {
  case cur {
    #(point, Up) -> #(point.0, point.1 - 1)
    #(point, Down) -> #(point.0, point.1 + 1)
    #(point, Left) -> #(point.0 - 1, point.1)
    #(point, Right) -> #(point.0 + 1, point.1)
  }
}

fn traverse(cur, map, visited) {
  let next = get_next(cur)

  case dict.get(map, next) {
    Error(Nil) -> visited
    Ok("#") -> traverse(#(cur.0, rotate(cur.1)), map, visited)
    Ok(_) -> traverse(#(next, cur.1), map, set.insert(visited, next))
  }
}

fn traverse_with_dir(cur, map, visited: Set(#(#(Int, Int), Direction))) {
  let next = get_next(cur)

  case dict.get(map, next) {
    Error(Nil) -> visited
    Ok("#") -> traverse_with_dir(#(cur.0, rotate(cur.1)), map, visited)
    Ok(_) ->
      traverse_with_dir(
        #(next, cur.1),
        map,
        set.insert(visited, #(next, cur.1)),
      )
  }
}

fn check_obstacle(cur, pos, map, visited, acc) {
  let next = get_next(cur)

  case set.contains(visited, #(next, cur.1)), dict.get(map, next) {
    _, Error(Nil) -> acc
    True, _ -> set.insert(acc, pos)
    False, Ok("#") ->
      check_obstacle(#(cur.0, rotate(cur.1)), pos, map, visited, acc)
    False, Ok(_) ->
      check_obstacle(
        #(next, cur.1),
        pos,
        map,
        set.insert(visited, #(next, cur.1)),
        acc,
      )
  }
}

fn part_one(input: #(Dict(#(Int, Int), String), #(#(Int, Int), Direction))) {
  let #(map, start) = input

  start |> traverse(map, set.from_list([start.0])) |> set.size()
}

fn part_two(input: #(Dict(#(Int, Int), String), #(#(Int, Int), Direction))) {
  let #(map, start) = input
  let visited = traverse_with_dir(start, map, set.from_list([start]))

  visited
  |> set.to_list()
  |> list.fold(set.new(), fn(acc, pos) {
    let altered = dict.insert(map, pos.0, "#")
    check_obstacle(start, pos, altered, set.from_list([start]), acc)
  })
  |> set.to_list()
  |> list.map(fn(point) { point.0 })
  |> set.from_list()
  |> set.size()
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
