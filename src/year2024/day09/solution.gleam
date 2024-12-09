import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

import simplifile

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day09/input.txt")

  input
  |> string.trim()
  |> string.to_graphemes()
  |> list.filter_map(int.parse)
}

fn to_disk_map(input, i, file_index, files, spaces) {
  case input {
    [] -> #(files, list.reverse(spaces))
    [h, ..tail] ->
      case int.is_even(i) {
        False -> to_disk_map(tail, i + 1, file_index, files, [h, ..spaces])
        True ->
          to_disk_map(
            tail,
            i + 1,
            file_index + 1,
            [list.repeat(int.to_string(file_index), h), ..files],
            spaces,
          )
      }
  }
}

fn fill(files: List(List(String)), spaces, blocks: List(String), acc) {
  case files, spaces {
    [], _ -> acc
    [f, ..t], [] -> fill(t, spaces, blocks, [f, ..acc])
    [f, ..fs], [sp, ..sps] ->
      fill(fs, sps, list.drop(blocks, sp), [
        list.reverse(list.take(blocks, sp)),
        f,
        ..acc
      ])
  }
}

fn part_one(input) {
  let #(files, spaces) = to_disk_map(input, 0, 0, [], [])
  let blocks = list.flatten(files)
  let files = list.reverse(files)
  let num_spaces = int.sum(spaces)

  files
  |> fill(spaces, blocks, [])
  |> list.flatten()
  |> list.drop(num_spaces)
  |> list.reverse()
  |> list.index_fold(0, fn(acc, num, i) { acc + i * utils.force_int(num) })
}

// fn part_two(input) {
//   let #(files, spaces) = to_disk_map(input, 0, 0, [], [])
// }

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  // io.debug(part_two(input))
}
