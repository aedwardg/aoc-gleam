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
