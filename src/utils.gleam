import gleam/dict
import gleam/int

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
