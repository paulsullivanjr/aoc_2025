import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read("input/day05.txt")

  let sections =
    content
    |> string.trim
    |> string.split("\n\n")

  let assert [ranges_section, ids_section] = sections

  let ranges = parse_ranges(ranges_section)
  let ingredient_ids = parse_ids(ids_section)

  // Part 1
  let fresh_count =
    ingredient_ids
    |> list.filter(fn(id) { is_fresh(id, ranges) })
    |> list.length

  io.println("Part 1 - Fresh ingredient IDs: " <> int.to_string(fresh_count))

  // Part 2
  let merged = merge_ranges(ranges)
  let total_fresh = count_total_fresh(merged)

  io.println(
    "Part 2 - Total fresh IDs in ranges: " <> int.to_string(total_fresh),
  )
}

fn parse_ranges(section: String) -> List(#(Int, Int)) {
  section
  |> string.split("\n")
  |> list.filter_map(fn(line) {
    case string.split(line, "-") {
      [start_str, end_str] -> {
        use start <- result.try(int.parse(start_str))
        use end <- result.try(int.parse(end_str))
        Ok(#(start, end))
      }
      _ -> Error(Nil)
    }
  })
}

fn parse_ids(section: String) -> List(Int) {
  section
  |> string.split("\n")
  |> list.filter_map(int.parse)
}

fn is_fresh(id: Int, ranges: List(#(Int, Int))) -> Bool {
  list.any(ranges, fn(range) {
    let #(start, end) = range
    id >= start && id <= end
  })
}

fn merge_ranges(ranges: List(#(Int, Int))) -> List(#(Int, Int)) {
  let sorted =
    list.sort(ranges, fn(a, b) {
      let #(a_start, _) = a
      let #(b_start, _) = b
      int.compare(a_start, b_start)
    })

  case sorted {
    [] -> []
    [first, ..rest] -> {
      list.fold(rest, [first], fn(acc, range) {
        let assert [current, ..others] = acc
        let #(curr_start, curr_end) = current
        let #(range_start, range_end) = range

        case range_start <= curr_end + 1 {
          True -> {
            let new_end = int.max(curr_end, range_end)
            [#(curr_start, new_end), ..others]
          }
          False -> [range, ..acc]
        }
      })
    }
  }
}

fn count_total_fresh(merged_ranges: List(#(Int, Int))) -> Int {
  list.fold(merged_ranges, 0, fn(acc, range) {
    let #(start, end) = range
    acc + { end - start + 1 }
  })
}
