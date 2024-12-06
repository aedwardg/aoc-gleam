import gleam/dict
import gleam/int
import gleam/list

pub type SplitOpts {
  Global
  Trim
  TrimAll
}

@external(erlang, "binary", "split")
pub fn erl_split(
  string: String,
  pattern: String,
  opts: List(SplitOpts),
) -> List(String)

pub fn trim_split(string, pattern) {
  erl_split(string, pattern, [Global, TrimAll])
}

pub fn force_int(string) {
  let assert Ok(i) = int.parse(string)
  i
}

pub fn safe_get(map, key, default) {
  case dict.get(map, key) {
    Ok(val) -> val
    Error(Nil) -> default
  }
}

pub fn to_int_matrix(str, delim_1, delim_2) {
  str
  |> trim_split(delim_1)
  |> list.map(fn(row) {
    row
    |> trim_split(delim_2)
    |> list.map(force_int)
  })
}

pub fn to_matrix(str, delim_1, delim_2) {
  str
  |> trim_split(delim_1)
  |> list.map(trim_split(_, delim_2))
}
