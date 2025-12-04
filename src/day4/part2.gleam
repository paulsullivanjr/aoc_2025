import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read("input/day04.txt")

  let lines =
    content
    |> string.trim
    |> string.split("\n")

  let grid = build_grid(lines)

  let total_removed = remove_until_stable(grid, 0)

  io.println("Total rolls removed: " <> int.to_string(total_removed))
}

fn build_grid(lines: List(String)) -> dict.Dict(#(Int, Int), String) {
  list.index_fold(lines, dict.new(), fn(acc, line, y) {
    let chars = string.to_graphemes(line)
    list.index_fold(chars, acc, fn(acc2, char, x) {
      dict.insert(acc2, #(x, y), char)
    })
  })
}

fn remove_until_stable(grid: dict.Dict(#(Int, Int), String), total: Int) -> Int {
  let accessible = find_accessible(grid)

  case set.size(accessible) {
    0 -> total
    count -> {
      let new_grid = remove_rolls(grid, accessible)
      remove_until_stable(new_grid, total + count)
    }
  }
}

fn find_accessible(grid: dict.Dict(#(Int, Int), String)) -> set.Set(#(Int, Int)) {
  dict.fold(grid, set.new(), fn(acc, pos, cell) {
    case cell {
      "@" -> {
        let neighbors = count_neighbor_rolls(grid, pos)
        case neighbors < 4 {
          True -> set.insert(acc, pos)
          False -> acc
        }
      }
      _ -> acc
    }
  })
}

fn remove_rolls(
  grid: dict.Dict(#(Int, Int), String),
  to_remove: set.Set(#(Int, Int)),
) -> dict.Dict(#(Int, Int), String) {
  set.fold(to_remove, grid, fn(g, pos) { dict.insert(g, pos, ".") })
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
