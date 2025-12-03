import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read("input/day03.txt")

  let total =
    content
    |> string.trim
    |> string.split("\n")
    |> list.map(max_joltage)
    |> list.fold(0, fn(acc, x) { acc + x })

  io.println("Total output joltage: " <> int.to_string(total))
}

fn max_joltage(line: String) -> Int {
  let digits =
    string.to_graphemes(line)
    |> list.filter_map(int.parse)

  find_max_pair(digits)
}

// Find maximum 2-digit number from picking two digits in order
fn find_max_pair(digits: List(Int)) -> Int {
  case digits {
    [] -> 0
    [_] -> 0
    [first, ..rest] -> {
      // Best value when 'first' is the first digit
      let max_with_first = case list.reduce(rest, int.max) {
        Ok(max_second) -> first * 10 + max_second
        Error(_) -> 0
      }
      // Try other positions for first digit
      let max_without_first = find_max_pair(rest)
      int.max(max_with_first, max_without_first)
    }
  }
}
