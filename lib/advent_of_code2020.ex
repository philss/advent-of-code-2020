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
end
