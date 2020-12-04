defmodule AdventOfCode2020 do
  @moduledoc false

  @spec report_repair([integer()]) :: integer() | nil
  def report_repair(expenses) do
    report = for i <- expenses, j <- expenses, i + j == 2020, uniq: true, do: i * j

    List.first(report)
  end

  def report_repair_sum_three(expenses) do
    report =
      for i <- expenses,
          j <- expenses,
          k <- expenses,
          i + j + k == 2020,
          uniq: true,
          do: i * j * k

    List.first(report)
  end

  @spec password_philosophy(binary()) :: integer()
  def password_philosophy(policies_with_passwords) do
    policies_with_passwords
    |> parse_password_lines()
    |> Enum.map(fn {min, max, letter, password} ->
      occurrencies =
        password
        |> String.codepoints()
        |> Enum.reduce(0, fn char, acc ->
          if char == letter do
            acc + 1
          else
            acc
          end
        end)

      {min..max, occurrencies}
    end)
    |> Enum.filter(fn {range, occurrencies} ->
      occurrencies in range
    end)
    |> Enum.count()
  end

  @spec password_philosophy_positional(binary()) :: integer()
  def password_philosophy_positional(policies_with_passwords) do
    policies_with_passwords
    |> parse_password_lines()
    |> Enum.filter(fn {first, second, letter, password} ->
      at_first = String.at(password, first - 1)
      at_second = String.at(password, second - 1)

      (letter == at_first || letter == at_second) && at_first != at_second
    end)
    |> Enum.count()
  end

  defp parse_password_lines(policies_with_passwords) do
    split_pattern = :binary.compile_pattern(["-", ": ", " "])

    policies_with_passwords
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [min, max, letter, password] = String.split(line, split_pattern)

      min = String.to_integer(min)
      max = String.to_integer(max)

      {min, max, letter, password}
    end)
  end

  @doc """
  Traverse the forest (that has a repeatable pattern) looking for trees.

  It does in a way that always walk to the south in diagonal, counting
  the trees that finds in the way.

  ## Example

      iex> forest = ~s(..##.......
      iex> #...#...#..
      iex> .#....#..#.
      iex> ..#.#...#.#
      iex> .#...##..#.
      iex> ..#.##.....
      iex> .#.#.#....#
      iex> .#........#
      iex> #.##...#...
      iex> #...##....#
      iex> .#..#...#.#)
      iex> AdventOfCode2020.tobogan_trajectory(forest)
      7
      iex> AdventOfCode2020.tobogan_trajectory(forest, [right: 1, down: 1])
      2
      iex> AdventOfCode2020.tobogan_trajectory(forest, [right: 5, down: 1])
      3
      iex> AdventOfCode2020.tobogan_trajectory(forest, [right: 7, down: 1])
      4
      iex> AdventOfCode2020.tobogan_trajectory(forest, [right: 1, down: 2])
      2

  """
  def tobogan_trajectory(forest, opts \\ []) do
    opts = Keyword.merge([right: 3, down: 1], opts)

    forest
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.replace(~r/[\s->]+/, "")
      |> String.codepoints()
      |> Stream.cycle()
    end)
    |> read_map(0, 0, 0, opts)
  end

  defp read_map(lines, row, _col, trees, _opts) when row > length(lines) - 1, do: trees

  defp read_map(lines, row, col, trees, opts) do
    row = row + Keyword.fetch!(opts, :down)
    col = col + Keyword.fetch!(opts, :right)

    line = Enum.at(lines, row)
    maybe_tree = line && Enum.at(line, col)

    trees =
      if maybe_tree == "#" do
        trees + 1
      else
        trees
      end

    read_map(lines, row, col, trees, opts)
  end

  @doc """
  Traverse the forest trying different slopes and multiply the number of trees.

  It does in a way that always walk to the south in diagonal, counting
  the trees that finds in the way. Again, the pattern repeats.

  The slopes define the way it will be traversed, from left-up to right-bottom.

  ## Example

      iex> forest = ~s(..##.......
      iex> #...#...#..
      iex> .#....#..#.
      iex> ..#.#...#.#
      iex> .#...##..#.
      iex> ..#.##.....
      iex> .#.#.#....#
      iex> .#........#
      iex> #.##...#...
      iex> #...##....#
      iex> .#..#...#.#)
      iex> slopes = [[right: 1], [right: 3], [right: 5], [right: 7], [right: 1, down: 2]]
      iex> AdventOfCode2020.multiply_tobogan_trajectories_slopes_trees(forest, slopes)
      336

  """
  def multiply_tobogan_trajectories_slopes_trees(forest, slopes) do
    slopes
    |> Enum.map(fn slope ->
      tobogan_trajectory(forest, slope)
    end)
    |> Enum.reduce(fn
      trees, nil ->
        trees

      trees, total ->
        trees * total
    end)
  end
end
