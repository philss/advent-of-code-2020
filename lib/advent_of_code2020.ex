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

  @required_passport_fields ~w(byr iyr eyr hgt hcl ecl pid)
  @doc """
  Passaport validator.

  ## Examples

      iex> passport = ~s(ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
      iex> byr:1937 iyr:2017 cid:147 hgt:183cm)
      iex> AdventOfCode2020.passport_valid?(passport)
      true

      iex> passport = ~s(hcl:#ae17e1 iyr:2013
      iex> eyr:2024
      iex> ecl:brn pid:760753108 byr:1931
      iex> hgt:179cm)
      iex> AdventOfCode2020.passport_valid?(passport)
      true

      iex> passport = ~s(
      iex> iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
      iex> hcl:#cfa07d byr:1929)
      iex> AdventOfCode2020.passport_valid?(passport)
      false


  """
  def passport_valid?(passport_fields) do
    pairs = String.split(passport_fields, ~r/[\s\n]/, trim: true)

    passport =
      for pair <- pairs, into: %{} do
        [key, value] = String.split(pair, ":", trim: true)
        {key, value}
      end

    @required_passport_fields -- Map.keys(passport) == []
  end

  @doc """
  Validate passport according to some rules.

  The rules are:

  - byr (Birth Year) - four digits; at least 1920 and at most 2002.
  - iyr (Issue Year) - four digits; at least 2010 and at most 2020.
  - eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
  - hgt (Height) - a number followed by either cm or in:
    - If cm, the number must be at least 150 and at most 193.
    - If in, the number must be at least 59 and at most 76.
  - hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
  - ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
  - pid (Passport ID) - a nine-digit number, including leading zeroes.
  - cid (Country ID) - ignored, missing or not.

  ## Examples

      iex> passport = ~s(pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980 hcl:#623a2f)
      iex> AdventOfCode2020.passport_valid_with_rules?(passport)
      true

      iex> passport = ~s(eyr:1972 cid:100 hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926)
      iex> AdventOfCode2020.passport_valid_with_rules?(passport)
      false

  """
  def passport_valid_with_rules?(passport_fields) do
    pairs = String.split(passport_fields, ~r/[\s\n]/, trim: true)

    fields =
      for pair <- pairs do
        [key, value] = String.split(pair, ":", trim: true)
        {key, value}
      end

    Enum.all?(fields, &valid_passport_field?(&1))
  end

  defp valid_passport_field?({"byr", year}) do
    parse_and_validate_integer_in_range(year, 1920..2002)
  end

  defp valid_passport_field?({"iyr", year}) do
    parse_and_validate_integer_in_range(year, 2010..2020)
  end

  defp valid_passport_field?({"eyr", expiration_year}) do
    parse_and_validate_integer_in_range(expiration_year, 2020..2030)
  end

  defp valid_passport_field?({"hgt", height}) do
    case Integer.parse(height) do
      {number, "cm"} ->
        number in 150..193

      {number, "in"} ->
        number in 59..76

      _ ->
        false
    end
  end

  defp valid_passport_field?({"hcl", color}) do
    String.match?(color, ~r/^#[a-f0-9]{6}$/)
  end

  defp valid_passport_field?({"ecl", eye_color})
       when eye_color in ~w(amb blu brn gry grn hzl oth) do
    true
  end

  defp valid_passport_field?({"pid", passport_id}) do
    String.match?(passport_id, ~r/^[0-9]{9}$/)
  end

  defp valid_passport_field?({"cid", _}), do: true

  defp valid_passport_field?(_), do: false

  defp parse_and_validate_integer_in_range(value, range) do
    case Integer.parse(value) do
      {number, ""} ->
        number in range

      _ ->
        false
    end
  end

  @doc """
  Searches for the seat id by looking to nearby passes.

  ## Example

      iex> AdventOfCode2020.binary_boarding("FBFBBFFRLR")
      357

      iex> AdventOfCode2020.binary_boarding("BFFFBBFRRR")
      567

  """
  def binary_boarding(binary_space_partioning) do
    coords = String.codepoints(binary_space_partioning)
    rows_coords = Enum.take(coords, 7)
    cols_coords = Enum.take(coords, -3)

    [row] = binary_boarding_search(rows_coords, Enum.to_list(0..127))
    [col] = binary_boarding_search(cols_coords, Enum.to_list(0..7))

    row * 8 + col
  end

  defp binary_boarding_search(coords, seats) do
    Enum.reduce(coords, seats, fn coord, remaining ->
      split_by = Integer.floor_div(length(remaining), 2)

      to_take =
        if coord in ~w(F L) do
          split_by
        else
          -1 * split_by
        end

      Enum.take(remaining, to_take)
    end)
  end
end
