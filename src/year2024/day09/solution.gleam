import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{Eq}
import gleam/string
import utils

import simplifile

pub type DiskItem {
  File(size: Int, value: Int)
  Space(size: Int)
}

pub type DoubleZipper {
  ZList(
    z1: DiskItem,
    z2: DiskItem,
    left: List(DiskItem),
    middle: List(DiskItem),
    right: List(DiskItem),
  )
}

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

fn to_disk_items(input, file_index) -> #(List(DiskItem), Int) {
  use #(items, file_index), size, i <- list.index_fold(input, #([], file_index))
  case int.is_even(i) {
    True -> #([File(size, file_index), ..items], file_index + 1)
    False -> #([Space(size), ..items], file_index)
  }
}

fn to_zlist(disk_items) {
  let assert [h, ..t] = disk_items
  let assert [last, ..rev_t] = list.reverse(t)
  ZList(z1: h, z2: last, left: [], middle: list.reverse(rev_t), right: [])
}

fn from_zlist(zlist: DoubleZipper) {
  list.flatten([
    list.reverse([zlist.z1, ..zlist.left]),
    zlist.middle,
    [zlist.z2, ..zlist.right],
  ])
}

fn reset_left(zlist: DoubleZipper) {
  case zlist.left {
    [] -> zlist
    [l1, ..l_rest] ->
      reset_left(
        ZList(..zlist, z1: l1, left: l_rest, middle: [zlist.z1, ..zlist.middle]),
      )
  }
}

fn find_next_space(zlist: DoubleZipper) {
  let ZList(z1, _z2, _left, middle, _right) = zlist
  case z1, middle {
    Space(_), _ -> zlist
    // z1 same as z2
    _, [] -> zlist
    File(_, _), [_, ..] -> find_next_space(z1_slide_right(zlist))
  }
}

fn find_next_file(zlist: DoubleZipper) {
  let ZList(_z1, z2, _left, _middle, _right) = zlist
  case z2 {
    File(_, _) -> zlist
    Space(_) -> find_next_file(z2_slide_left(zlist))
  }
}

fn z1_slide_right(zlist: DoubleZipper) {
  let ZList(z1, _z2, left, middle, _right) = zlist
  case middle {
    [] -> zlist
    [m1, ..m_rest] -> ZList(..zlist, z1: m1, left: [z1, ..left], middle: m_rest)
  }
}

fn z2_slide_left(zlist: DoubleZipper) {
  let ZList(_z1, z2, _left, middle, right) = zlist

  case middle {
    [] -> zlist
    _ -> {
      let assert [m_last, ..m_rest] = list.reverse(middle)
      ZList(
        ..zlist,
        z2: m_last,
        middle: list.reverse(m_rest),
        right: [z2, ..right],
      )
    }
  }
}

fn all_checked(zlist: DoubleZipper) {
  case zlist.left, zlist.middle {
    [], [] -> True
    _, _ -> False
  }
}

fn shift_files(zlist: DoubleZipper) {
  use <- bool.guard(all_checked(zlist), zlist)
  let zlist = find_next_file(zlist)
  do_shift_files(zlist)
}

fn do_shift_files(zlist: DoubleZipper) {
  let res = find_next_space(zlist)
  case res {
    _ if res == zlist ->
      zlist
      |> reset_left()
      |> z2_slide_left()
      |> shift_files()

    ZList(Space(s1), File(s2, _), ..) if s1 >= s2 -> shift_files(move_file(res))
    _ -> do_shift_files(z1_slide_right(res))
  }
}

fn move_file(zlist: DoubleZipper) {
  let ZList(z1, z2, left, _middle, _right) = zlist
  case int.compare(z1.size, z2.size) {
    Eq -> ZList(..zlist, z1: z2, z2: z1) |> merge_spaces()
    _ ->
      ZList(
        ..zlist,
        left: [z2, ..left],
        z1: Space(z1.size - z2.size),
        z2: Space(z2.size),
      )
      |> merge_spaces()
  }
}

fn merge_spaces(zlist: DoubleZipper) {
  zlist |> merge_left_spaces() |> merge_right_spaces() |> reset_left()
}

fn merge_left_spaces(zlist: DoubleZipper) {
  let ZList(z1, _z2, left, middle, _right) = zlist
  case list.pop(left, fn(_) { True }), list.pop(middle, fn(_) { True }) {
    Ok(#(Space(s1), l_rest)), Ok(#(Space(s2), m_rest)) ->
      ZList(..zlist, z1: Space(z1.size + s1 + s2), left: l_rest, middle: m_rest)
    Ok(#(Space(s), l_rest)), _ ->
      ZList(..zlist, left: l_rest, z1: Space(z1.size + s))
    _, Ok(#(Space(s), m_rest)) ->
      ZList(..zlist, z1: Space(z1.size + s), middle: m_rest)
    _, _ -> zlist
  }
}

fn merge_right_spaces(zlist: DoubleZipper) {
  let ZList(_z1, z2, _left, middle, right) = zlist
  let rev_mid = list.reverse(middle)
  case list.pop(rev_mid, fn(_) { True }), list.pop(right, fn(_) { True }) {
    Ok(#(Space(s1), m_rest)), Ok(#(Space(s2), r_rest)) ->
      ZList(
        ..zlist,
        z2: Space(z2.size + s1 + s2),
        middle: list.reverse(m_rest),
        right: r_rest,
      )
    Ok(#(Space(s), m_rest)), _ ->
      ZList(..zlist, middle: list.reverse(m_rest), z2: Space(z2.size + s))
    _, Ok(#(Space(s), r_rest)) ->
      ZList(..zlist, z2: Space(z2.size + s), right: r_rest)
    _, _ -> zlist
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

fn part_two(input) {
  let #(disk_items, _) =
    input
    |> to_disk_items(0)

  disk_items
  |> list.reverse()
  |> to_zlist()
  |> shift_files()
  |> from_zlist()
  |> list.flat_map(fn(item) {
    case item {
      File(size, val) -> list.repeat(val, size)
      Space(size) -> list.repeat(0, size)
    }
  })
  |> list.index_fold(0, fn(acc, num, i) { acc + i * num })
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
