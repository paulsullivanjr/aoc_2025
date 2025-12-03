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
      let new_position = apply_rotation(line, position)
      let new_count = case new_position {
        0 -> count + 1
        _ -> count
      }
      process_rotations(rest, new_position, new_count)
    }
  }
}

fn apply_rotation(line: String, position: Int) -> Int {
  let direction = string.slice(line, 0, 1)
  let distance =
    line
    |> string.drop_start(1)
    |> int.parse
    |> result.unwrap(0)

  let new_position = case direction {
    "L" -> position - distance
    "R" -> position + distance
    _ -> position
  }

  // Wrap around 0-99
  let wrapped = new_position % 100
  case wrapped < 0 {
    True -> wrapped + 100
    False -> wrapped
  }
}
