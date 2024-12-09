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

fn to_disk_map(input, i, file_index, blocks, spaces) {
  case input {
    [] -> #(blocks, list.reverse(spaces))
    [h, ..tail] ->
      case int.is_even(i) {
        False -> to_disk_map(tail, i + 1, file_index, blocks, [h, ..spaces])
        True ->
          to_disk_map(
            tail,
            i + 1,
            file_index + 1,
            [list.repeat(int.to_string(file_index), h), ..blocks],
            spaces,
          )
      }
  }
}

fn fill(blocks: List(List(String)), spaces, files: List(String), acc) {
  case blocks, spaces {
    [], _ -> acc
    [b, ..t], [] -> fill(t, spaces, files, [b, ..acc])
    [b, ..bs], [sp, ..sps] ->
      fill(bs, sps, list.drop(files, sp), [
        list.reverse(list.take(files, sp)),
        b,
        ..acc
      ])
  }
}

fn part_one(input) {
  let #(blocks, spaces) = to_disk_map(input, 0, 0, [], [])
  let files = list.flatten(blocks)
  let blocks = list.reverse(blocks)
  let num_spaces = int.sum(spaces)

  blocks
  |> fill(spaces, files, [])
  |> list.flatten()
  |> list.drop(num_spaces)
  |> list.reverse()
  |> list.index_fold(0, fn(acc, num, i) { acc + i * utils.force_int(num) })
}

// fn part_two(input) {
// }

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  // io.debug(part_two(input))
}
