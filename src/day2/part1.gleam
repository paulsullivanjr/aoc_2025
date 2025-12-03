import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read("input/day02.txt")

  let ranges = parse_ranges(string.trim(content))

  let total =
    list.fold(ranges, 0, fn(acc, range) {
      acc + sum_invalid_in_range(range.0, range.1)
    })

  io.println("Sum of invalid IDs: " <> int.to_string(total))
}

fn parse_ranges(input: String) -> List(#(Int, Int)) {
  input
  |> string.split(",")
  |> list.filter_map(fn(range_str) {
    case string.split(range_str, "-") {
      [start_str, end_str] -> {
        case int.parse(start_str), int.parse(end_str) {
          Ok(start), Ok(end) -> Ok(#(start, end))
          _, _ -> Error(Nil)
        }
      }
      _ -> Error(Nil)
    }
  })
}

fn sum_invalid_in_range(start: Int, end: Int) -> Int {
  // For each possible base length n, find doubled numbers in range
  find_doubled_numbers(start, end, 1, 0)
}

fn find_doubled_numbers(start: Int, end: Int, n: Int, acc: Int) -> Int {
  let multiplier = power(10, n) + 1
  let min_base = power(10, n - 1)
  let max_base = power(10, n) - 1

  // Special case: for n=1, min_base should be 1
  let min_base = case n {
    1 -> 1
    _ -> min_base
  }

  // Smallest doubled number with base length n
  let smallest_doubled = min_base * multiplier

  // If smallest possible is already > end, we're done
  case smallest_doubled > end {
    True -> acc
    False -> {
      // Find X range that produces doubled numbers in [start, end]
      let min_x = int.max(min_base, ceiling_div(start, multiplier))
      let max_x = int.min(max_base, end / multiplier)

      let sum = case min_x <= max_x {
        True -> sum_range_times_multiplier(min_x, max_x, multiplier)
        False -> 0
      }

      find_doubled_numbers(start, end, n + 1, acc + sum)
    }
  }
}

fn ceiling_div(a: Int, b: Int) -> Int {
  case a % b {
    0 -> a / b
    _ -> a / b + 1
  }
}

fn sum_range_times_multiplier(min_x: Int, max_x: Int, multiplier: Int) -> Int {
  // Sum of X * multiplier for X from min_x to max_x
  // = multiplier * (count * (min_x + max_x) / 2)
  let count = max_x - min_x + 1
  let sum_x = count * { min_x + max_x } / 2
  sum_x * multiplier
}

fn power(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * power(base, exp - 1)
  }
}
