import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/string

import simplifile

pub type Point {
  Point(x: Int, y: Int)
}

pub type Direction {
  Left
  Right
  Up
  Down
}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2019/day03/input.txt")
  let assert [wire1, wire2, _] =
    input
    |> string.split("\n")
    |> list.map(string.split(_, ","))

  #(wire1, wire2)
}

fn to_direction(char) {
  case char {
    "L" -> Left
    "R" -> Right
    "U" -> Up
    "D" -> Down
    _ -> panic as "Not a direction"
  }
}

fn create_path(wire) {
  let start = Point(0, 0)
  let #(_, _, updated_path) =
    list.fold(wire, #(start, 0, dict.new()), fn(acc, item) {
      let #(prev, steps, path) = acc
      let assert Ok(#(char, num)) = string.pop_grapheme(item)
      let dir = to_direction(char)
      let assert Ok(amt) = int.parse(num)

      let curr = case dir {
        Left -> Point(prev.x - amt, prev.y)
        Right -> Point(prev.x + amt, prev.y)
        Up -> Point(prev.x, prev.y + amt)
        Down -> Point(prev.x, prev.y - amt)
      }

      let updated_path = add_points(path, dir, prev, steps, amt)

      #(curr, steps + amt, updated_path)
    })

  updated_path
}

fn add_points(path, dir, begin: Point, steps, amt) {
  let range = case dir {
    Left -> iterator.range(begin.x, begin.x - amt)
    Right -> iterator.range(begin.x, begin.x + amt)
    Up -> iterator.range(begin.y, begin.y + amt)
    Down -> iterator.range(begin.y, begin.y - amt)
  }

  iterator.fold(range, path, fn(acc, loc) {
    case dir {
      Left | Right -> add_points_x_axis(acc, loc, begin, steps)
      Up | Down -> add_points_y_axis(acc, loc, begin, steps)
    }
  })
}

fn add_points_x_axis(acc, loc, begin: Point, steps) {
  dict.merge(
    dict.from_list([
      #(Point(loc, begin.y), steps + int.absolute_value(loc - begin.x)),
    ]),
    acc,
  )
}

fn add_points_y_axis(acc, loc, begin: Point, steps) {
  dict.merge(
    dict.from_list([
      #(Point(begin.x, loc), steps + int.absolute_value(loc - begin.y)),
    ]),
    acc,
  )
}

fn get_intersections(path1, path2) {
  let path1_vals =
    path1
    |> dict.drop([Point(0, 0)])
    |> dict.keys()

  list.fold(path1_vals, [], fn(acc, point) {
    case dict.has_key(path2, point) {
      True -> [point, ..acc]
      False -> acc
    }
  })
}

fn find_distance(point: Point) {
  int.absolute_value(point.x) + int.absolute_value(point.y)
}

fn find_steps(point: Point, path1, path2) {
  let assert Ok(steps1) = dict.get(path1, point)
  let assert Ok(steps2) = dict.get(path2, point)

  steps1 + steps2
}

fn get_paths_and_intersections(input) {
  let #(wire1, wire2) = input
  let path1 = create_path(wire1)
  let path2 = create_path(wire2)

  let intersections = get_intersections(path1, path2)
  #(path1, path2, intersections)
}

fn part_one(input) {
  let #(_, _, intersections) = get_paths_and_intersections(input)

  intersections
  |> list.map(find_distance)
  |> list.reduce(int.min)
}

fn part_two(input) {
  let #(path1, path2, intersections) = get_paths_and_intersections(input)

  intersections
  |> list.map(find_steps(_, path1, path2))
  |> list.reduce(int.min)
}

pub fn run() {
  let input = parse()
  let _ = io.debug(part_one(input))
  io.debug(part_two(input))
}
