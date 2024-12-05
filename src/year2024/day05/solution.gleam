import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}

import simplifile
import utils

fn parse() {
  let assert Ok(input) = simplifile.read("src/year2024/day05/input.txt")
  let assert [rules, pages] = utils.trim_split(input, "\n\n")
  let rules = to_int_matrix(rules, "\n", "|") |> build_rules()
  let pages = to_int_matrix(pages, "\n", ",")

  #(rules, pages)
}

fn to_int_matrix(str, delim_1, delim_2) {
  str
  |> utils.trim_split(delim_1)
  |> list.map(fn(row) {
    row
    |> utils.trim_split(delim_2)
    |> list.map(utils.force_int)
  })
}

fn build_rules(rules) {
  let rules_map: Dict(Int, List(Int)) = dict.new()

  use acc, rule <- list.fold(rules, rules_map)
  let assert [a, b] = rule
  let insert_rule = fn(x) {
    case x {
      Some(r) -> [b, ..r]
      None -> [b]
    }
  }

  dict.upsert(acc, a, insert_rule)
}

fn is_correct(pages, rules) {
  case pages {
    [_] -> True
    pages -> do_is_correct(pages, rules)
  }
}

fn do_is_correct(pages, rules) {
  let assert [h, ..t] = pages
  let after = utils.safe_get(rules, h, [])

  case list.all(t, list.contains(after, _)) {
    True -> is_correct(t, rules)
    False -> False
  }
}

fn reorder(pages, rules) {
  pages
  |> list.sort(fn(a, b) {
    let after_a = utils.safe_get(rules, a, [])
    let after_b = utils.safe_get(rules, b, [])

    int.compare(
      list.count(pages, list.contains(after_a, _)),
      list.count(pages, list.contains(after_b, _)),
    )
  })
  |> list.reverse()
}

fn get_middle(pages) {
  let middle = list.length(pages) / 2
  let assert #(_, [m, ..]) = list.split(pages, middle)
  m
}

fn part_one(input) {
  let #(rules, pages) = input

  pages
  |> list.filter(is_correct(_, rules))
  |> list.map(get_middle)
  |> int.sum()
}

fn part_two(input) {
  let #(rules, pages) = input

  pages
  |> list.filter(fn(page) { !is_correct(page, rules) })
  |> list.map(reorder(_, rules))
  |> list.map(get_middle)
  |> int.sum()
}

pub fn run() {
  let input = parse()
  io.debug(part_one(input))
  io.debug(part_two(input))
}
