import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read("input/day04.txt")

  let lines =
    content
    |> string.trim
    |> string.split("\n")

  let grid = build_grid(lines)

  let count =
    dict.fold(grid, 0, fn(acc, pos, cell) {
      case cell {
        "@" -> {
          let neighbors = count_neighbor_rolls(grid, pos)
          case neighbors < 4 {
            True -> acc + 1
            False -> acc
          }
        }
        _ -> acc
      }
    })

  io.println("Accessible rolls: " <> int.to_string(count))
}

fn build_grid(lines: List(String)) -> dict.Dict(#(Int, Int), String) {
  list.index_fold(lines, dict.new(), fn(acc, line, y) {
    let chars = string.to_graphemes(line)
    list.index_fold(chars, acc, fn(acc2, char, x) {
      dict.insert(acc2, #(x, y), char)
    })
  })
}

fn count_neighbor_rolls(
  grid: dict.Dict(#(Int, Int), String),
  pos: #(Int, Int),
) -> Int {
  let #(x, y) = pos
  let directions = [
    #(-1, -1),
    #(0, -1),
    #(1, -1),
    #(-1, 0),
    #(1, 0),
    #(-1, 1),
    #(0, 1),
    #(1, 1),
  ]

  list.fold(directions, 0, fn(acc, dir) {
    let #(dx, dy) = dir
    let neighbor_pos = #(x + dx, y + dy)

    case dict.get(grid, neighbor_pos) {
      Ok("@") -> acc + 1
      _ -> acc
    }
  })
}
