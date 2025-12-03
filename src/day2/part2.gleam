import gleam/int
import gleam/io
import gleam/list
import gleam/set
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
  find_all_invalid(start, end)
  |> set.to_list
  |> list.fold(0, fn(acc, n) { acc + n })
}

fn find_all_invalid(start: Int, end: Int) -> set.Set(Int) {
  let max_digits = num_digits(end)

  // Generate all (k, r) pairs and collect invalid numbers
  generate_kr_pairs(1, max_digits)
  |> list.fold(set.new(), fn(acc, kr) {
    let #(k, r) = kr
    let numbers = find_numbers_for_kr(start, end, k, r)
    list.fold(numbers, acc, fn(s, n) { set.insert(s, n) })
  })
}

// Generate all (k, r) pairs where k*r <= max_total and r >= 2
fn generate_kr_pairs(k: Int, max_total: Int) -> List(#(Int, Int)) {
  case k > max_total / 2 {
    True -> []
    False -> {
      let pairs_for_k = generate_r_values(k, 2, max_total)
      list.append(pairs_for_k, generate_kr_pairs(k + 1, max_total))
    }
  }
}

fn generate_r_values(k: Int, r: Int, max_total: Int) -> List(#(Int, Int)) {
  case k * r > max_total {
    True -> []
    False -> [#(k, r), ..generate_r_values(k, r + 1, max_total)]
  }
}

// Find all numbers X * multiplier that fall in [start, end]
fn find_numbers_for_kr(start: Int, end: Int, k: Int, r: Int) -> List(Int) {
  let multiplier = compute_multiplier(k, r)
  let min_base = case k {
    1 -> 1
    _ -> power(10, k - 1)
  }
  let max_base = power(10, k) - 1

  let min_x = int.max(min_base, ceiling_div(start, multiplier))
  let max_x = int.min(max_base, end / multiplier)

  case min_x <= max_x {
    True -> list.range(min_x, max_x) |> list.map(fn(x) { x * multiplier })
    False -> []
  }
}

// Multiplier for repeating a k-digit number r times
// Formula: (10^(k*r) - 1) / (10^k - 1)
// Example: k=2, r=3 -> 10101 (for numbers like 121212)
fn compute_multiplier(k: Int, r: Int) -> Int {
  let numerator = power(10, k * r) - 1
  let denominator = power(10, k) - 1
  numerator / denominator
}

fn num_digits(n: Int) -> Int {
  case n < 10 {
    True -> 1
    False -> 1 + num_digits(n / 10)
  }
}

fn ceiling_div(a: Int, b: Int) -> Int {
  case a % b {
    0 -> a / b
    _ -> a / b + 1
  }
}

fn power(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * power(base, exp - 1)
  }
}
