import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import simplifile
import utils.{Global, TrimAll}

pub type Pick {
  Pick(reds: Int, greens: Int, blues: Int)
}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2023/day02/input.txt")

  input
  |> utils.erl_split("\n", [Global, TrimAll])
  |> list.map(fn(s) {
    let assert [_game, picks] = string.split(s, ": ")
    build_picks(picks)
  })
}

fn build_picks(pick_str) {
  pick_str
  |> string.split("; ")
  |> list.map(fn(s) {
    s
    |> string.split(", ")
    |> list.fold(Pick(reds: 0, greens: 0, blues: 0), fn(acc, p) {
      let assert [num, color] = string.split(p, " ")
      case color {
        "red" -> Pick(..acc, reds: result.unwrap(int.parse(num), 0))
        "green" -> Pick(..acc, greens: result.unwrap(int.parse(num), 0))
        "blue" -> Pick(..acc, blues: result.unwrap(int.parse(num), 0))
        _ -> acc
      }
    })
  })
}

fn valid_game(game: List(Pick)) {
  list.all(game, fn(pick) {
    pick.reds <= 12 && pick.greens <= 13 && pick.blues <= 14
  })
}

fn min_power(game: List(Pick)) {
  let assert Ok(mins) =
    list.reduce(game, fn(acc, p) {
      Pick(
        reds: int.max(acc.reds, p.reds),
        greens: int.max(acc.greens, p.greens),
        blues: int.max(acc.blues, p.blues),
      )
    })

  mins.reds * mins.greens * mins.blues
}

fn part_one(games) {
  games
  |> list.index_fold(0, fn(acc, game, i) {
    case valid_game(game) {
      True -> acc + i + 1
      False -> acc
    }
  })
}

fn part_two(games) {
  games
  |> list.map(min_power)
  |> int.sum()
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
