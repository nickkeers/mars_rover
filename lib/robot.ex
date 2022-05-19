defmodule MarsRover.Robot do
  @moduledoc """
  Implements logic for moving a Robot according to a facing position and its set of instructions within
  a finite set of bounds
  """
  alias MarsRover.FileParser.Robot

  @type grid :: {integer(), integer()}

  @doc ~S"""
  Simulate the movement of a Robot, returns a string representing its final position, if the robot
  moves out of bounds then the string 'LOST' after it

  ## Examples

      iex> MarsRover.Robot.simulate({4, 4}, %MarsRover.FileParser.Robot{facing: "E", x: 0, y: 0, instructions: ["F"]})
      "(1, 0, E)"

      iex> MarsRover.Robot.simulate({4, 4}, %MarsRover.FileParser.Robot{facing: "S", x: 0, y: 0, instructions: ["F"]})
      "(0, 0, S) LOST"
  """
  @spec simulate(grid(), Robot.t()) :: String.t()
  def simulate(grid_size, %Robot{facing: facing, instructions: instructions, x: x, y: y}) do
    move(grid_size, {x, y}, facing, instructions)
  end

  # given a direction and a turn, perform the turn and return the new facing direction
  defp turn("N", "L"), do: "W"
  defp turn("N", "R"), do: "E"
  defp turn("E", "L"), do: "N"
  defp turn("E", "R"), do: "S"
  defp turn("S", "L"), do: "E"
  defp turn("S", "R"), do: "W"
  defp turn("W", "L"), do: "S"
  defp turn("W", "R"), do: "N"

  @doc """
  Move a robot using its starting position, its facing direction and its set of instructions

  ## Examples
      iex> MarsRover.Robot.move({4, 4}, {3, 3}, "N", ["F", "L", "F"])
      "(2, 4, W)"

      iex> MarsRover.Robot.move({4, 4}, {3, 3}, "N", ["F", "L", "F", "R", "F"])
      "(2, 4, N) LOST"
  """
  @spec move(
          bounds :: grid(),
          grid :: grid(),
          facing :: String.t(),
          instructions :: list(String.t())
        ) :: String.t()
  def move(_, {x, y}, facing, []), do: "(#{x}, #{y}, #{facing})"

  def move(bounds, grid, facing, [turn | rest]) when turn == "L" or turn == "R",
    do: move(bounds, grid, turn(facing, turn), rest)

  def move(bounds, grid = {x, y}, facing, ["F" | rest]) do
    if can_move(facing, bounds, grid) do
      move(bounds, do_move(grid, facing), facing, rest)
    else
      "(#{x}, #{y}, #{facing}) LOST"
    end
  end

  def do_move({grid_x, grid_y}, "N"), do: {grid_x, grid_y + 1}
  def do_move({grid_x, grid_y}, "E"), do: {grid_x + 1, grid_y}
  def do_move({grid_x, grid_y}, "S"), do: {grid_x, grid_y - 1}
  def do_move({grid_x, grid_y}, "W"), do: {grid_x - 1, grid_y}

  @doc ~S"""
  Check if a move can be performed in a certain direction given the bounds and current grid position

  ## Examples

      iex> MarsRover.Robot.can_move("N", {4, 4}, {2,2})
      true

      iex> MarsRover.Robot.can_move("S", {4, 4}, {0,0})
      false
  """
  def can_move("N", {_, max_y}, {_, grid_y}), do: grid_y + 1 <= max_y
  def can_move("E", {max_x, _}, {grid_x, _}), do: grid_x + 1 <= max_x
  def can_move("S", {_, _}, {_, grid_y}), do: grid_y - 1 >= 0
  def can_move("W", {_, _}, {grid_x, _}), do: grid_x - 1 >= 0
end
