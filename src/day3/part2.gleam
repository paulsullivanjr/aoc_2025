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
    |> list.map(max_joltage_12)
    |> list.fold(0, fn(acc, x) { acc + x })

  io.println("Total output joltage: " <> int.to_string(total))
}

fn max_joltage_12(line: String) -> Int {
  let digits =
    string.to_graphemes(line)
    |> list.filter_map(int.parse)

  let picked = pick_digits(digits, 12)
  digits_to_number(picked)
}

// Greedy: pick `remaining` digits to maximize the number
fn pick_digits(digits: List(Int), remaining: Int) -> List(Int) {
  case remaining {
    0 -> []
    _ -> {
      let n = list.length(digits)
      // Can pick from positions 0 to (n - remaining)
      let search_count = n - remaining + 1

      // Find max value and its position in that range
      let #(max_val, max_pos) = find_max_with_pos(digits, search_count)

      // Drop digits up to and including max_pos, recurse
      let rest = list.drop(digits, max_pos + 1)

      [max_val, ..pick_digits(rest, remaining - 1)]
    }
  }
}

// Find max value and its position in the first `count` elements
fn find_max_with_pos(digits: List(Int), count: Int) -> #(Int, Int) {
  find_max_helper(digits, count, 0, 0, 0)
}

fn find_max_helper(
  digits: List(Int),
  count: Int,
  current_pos: Int,
  best_val: Int,
  best_pos: Int,
) -> #(Int, Int) {
  case count, digits {
    0, _ -> #(best_val, best_pos)
    _, [] -> #(best_val, best_pos)
    _, [d, ..rest] -> {
      // Update best if this digit is strictly greater (leftmost wins ties)
      let #(new_best_val, new_best_pos) = case d > best_val {
        True -> #(d, current_pos)
        False -> #(best_val, best_pos)
      }
      find_max_helper(
        rest,
        count - 1,
        current_pos + 1,
        new_best_val,
        new_best_pos,
      )
    }
  }
}

// Convert list of digits to a number
fn digits_to_number(digits: List(Int)) -> Int {
  list.fold(digits, 0, fn(acc, d) { acc * 10 + d })
}
