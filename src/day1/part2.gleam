import gleam/int
import gleam/io
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read("input/day01.txt")

  let lines =
    content
    |> string.trim
    |> string.split("\n")

  let zero_count = process_rotations(lines, 50, 0)

  io.println("Password: " <> int.to_string(zero_count))
}

fn process_rotations(lines: List(String), position: Int, count: Int) -> Int {
  case lines {
    [] -> count
    [line, ..rest] -> {
      let #(new_position, zero_hits) = apply_rotation(line, position)
      process_rotations(rest, new_position, count + zero_hits)
    }
  }
}

fn apply_rotation(line: String, position: Int) -> #(Int, Int) {
  let direction = string.slice(line, 0, 1)
  let distance =
    line
    |> string.drop_start(1)
    |> int.parse
    |> result.unwrap(0)

  case direction {
    "L" -> {
      let new_pos = wrap(position - distance)
      let hits = count_zeros_left(position, distance)
      #(new_pos, hits)
    }
    "R" -> {
      let new_pos = wrap(position + distance)
      let hits = count_zeros_right(position, distance)
      #(new_pos, hits)
    }
    _ -> #(position, 0)
  }
}

// Count how many times we pass through 0 going LEFT
fn count_zeros_left(position: Int, distance: Int) -> Int {
  case position {
    // From 0, first hit is at step 100
    0 -> distance / 100
    // From P>0, first hit is at step P, then P+100, P+200...
    p ->
      case distance >= p {
        True -> { distance - p } / 100 + 1
        False -> 0
      }
  }
}

// Count how many times we pass through 0 going RIGHT
fn count_zeros_right(position: Int, distance: Int) -> Int {
  let steps_to_zero = 100 - position
  case distance >= steps_to_zero {
    True -> { distance - steps_to_zero } / 100 + 1
    False -> 0
  }
}

fn wrap(value: Int) -> Int {
  let wrapped = value % 100
  case wrapped < 0 {
    True -> wrapped + 100
    False -> wrapped
  }
}
