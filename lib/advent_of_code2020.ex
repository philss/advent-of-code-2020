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

end
