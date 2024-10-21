import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub type Shape {
  Rock
  Paper
  Scissors
}

pub fn run() {
  let input = parse()
  io.println("Part 1:")
  part_one(input)

  io.println("Part 2:")
  input
  |> part_two()
}

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2022/day02/input.txt")

  input
  |> string.split("\n")
  |> list.filter_map(fn(s) {
    case string.split(s, " ") {
      [""] -> Error([""])
      letters -> Ok(letters)
    }
  })
}

fn transform1(play) -> Result(Shape, String) {
  case play {
    "A" | "X" -> Ok(Rock)
    "B" | "Y" -> Ok(Paper)
    "C" | "Z" -> Ok(Scissors)
    _ -> Error("Not a Shape")
  }
}

fn transform2_and_score(plays) -> Int {
  case plays {
    // [Rock, Scissors]
    ["A", "X"] -> 3 + 0
    // [Rock, Rock]
    ["A", "Y"] -> 1 + 3
    // [Rock, Paper]
    ["A", "Z"] -> 2 + 6
    // [Paper, Rock]
    ["B", "X"] -> 1 + 0
    // [Paper, Paper]
    ["B", "Y"] -> 2 + 3
    // [Paper, Scissors]
    ["B", "Z"] -> 3 + 6
    // [Scissors, Paper]
    ["C", "X"] -> 2 + 0
    // [Scissors, Scissors]
    ["C", "Y"] -> 3 + 3
    // [Scissors, Rock]
    ["C", "Z"] -> 1 + 6
    _ -> 0
  }
}

fn score1(shapes: List(Shape)) {
  // if you are the second one, 
  // you base points off whether YOU win or lose
  case shapes {
    [Rock, Rock] -> 1 + 3
    [Rock, Paper] -> 2 + 6
    [Rock, Scissors] -> 3 + 0
    [Paper, Rock] -> 1 + 0
    [Paper, Paper] -> 2 + 3
    [Paper, Scissors] -> 3 + 6
    [Scissors, Rock] -> 1 + 6
    [Scissors, Paper] -> 2 + 0
    [Scissors, Scissors] -> 3 + 3
    _ -> 0
  }
}

fn part_one(input) {
  input
  |> list.map(fn(plays) {
    let assert [a, b] = plays
    let assert [Ok(x), Ok(y)] = [transform1(a), transform1(b)]
    score1([x, y])
  })
  |> int.sum()
  |> io.debug()
}

fn part_two(input) {
  input
  |> list.map(transform2_and_score)
  |> int.sum()
  |> io.debug()
}
