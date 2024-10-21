import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn run() {
  let input = parse()
  io.println("Part 1:")
  part_one(input)

  io.println("Part 2:")
  part_two(input)
}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2022/day02/input.txt")

  input
  |> string.split("\n")
  |> list.filter_map(fn(s) {
    case string.is_empty(s) {
      True -> Error("Empty String")
      False -> Ok(s)
    }
  })
}

fn get_score_one(score, plays) {
  case plays {
    "A X" -> 4 + score
    "A Y" -> 8 + score
    "A Z" -> 3 + score
    "B X" -> 1 + score
    "B Y" -> 5 + score
    "B Z" -> 9 + score
    "C X" -> 7 + score
    "C Y" -> 2 + score
    "C Z" -> 6 + score
    _ -> 0 + score
  }
}

fn get_score_two(score, plays) {
  case plays {
    "A X" -> 3 + score
    "A Y" -> 4 + score
    "A Z" -> 8 + score
    "B X" -> 1 + score
    "B Y" -> 5 + score
    "B Z" -> 9 + score
    "C X" -> 2 + score
    "C Y" -> 6 + score
    "C Z" -> 7 + score
    _ -> 0 + score
  }
}

fn part_one(input) {
  input
  |> list.fold(0, get_score_one)
  |> io.debug()
}

fn part_two(input) {
  input
  |> list.fold(0, get_score_two)
  |> io.debug()
}
