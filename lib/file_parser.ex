defmodule MarsRover.FileParser do
  @moduledoc """
  This module uses NimbleParsec (a parser combinator library) to parse the input
  file consisting of a m x n grid size followed by 1 or more lines of instructions for robots
  in the form "(x, y, N | E | S | W) [F | L | R]+
  """

  defmodule Robot do
    @moduledoc """
    A small struct to nicely represent a robot
    """
    @type t :: %__MODULE__{}
    defstruct [:x, :y, :facing, :instructions]
  end

  defmodule RobotsFile do
    @moduledoc """
    A struct to represent the input file
    """
    @type t :: %__MODULE__{}
    defstruct [:grid_size, :robots]
  end

  defmodule Internal do
    @moduledoc """
    The module that wraps the NimbleParsec parser for the input file
    """
    import NimbleParsec

    # parse the first line which is a header m x n where m and n are integers separated by a space
    parse_header =
      integer(min: 1)
      |> ignore(string(" "))
      |> integer(min: 1)
      |> wrap()
      |> map({List, :to_tuple, []})

    # comma with 0 or more spaces after it
    comma_with_spaces = concat(ignore(string(",")), ignore(repeat(string(" "))))

    # an integer followed by the above combinator
    integer_before_comma = concat(integer(min: 1), comma_with_spaces)

    # match foward and turn left / right
    instructions =
      choice([string("F"), string("L"), string("R")])
      |> label("the instruction must be F, L or R")

    # parse the entire robot line (x, y, facing) [one or more instructions]
    parse_robot =
      ignore(string("("))
      |> label("must be a valid robot")
      |> times(integer_before_comma, 2)
      |> choice([string("N"), string("E"), string("S"), string("W")])
      |> label("direction must be N, E, S, W")
      |> ignore(string(")"))
      |> ignore(string(" "))
      |> wrap(times(instructions, min: 1))
      |> optional(ignore(string("\n")))
      |> post_traverse({:prettify_robot, []})

    # A nice helper function to parse the robot into an easier to use Robot struct
    defp prettify_robot(rest, args, context, _line, _offset) do
      [instructions, facing, y, x] = args

      {rest,
       List.wrap(%Robot{
         x: x,
         y: y,
         facing: facing,
         instructions: instructions
       }), context}
    end

    defparsec(
      :robotfile,
      parse_header
      |> ignore(string("\n"))
      |> concat(times(parse_robot, min: 1) |> wrap())
      |> label("robot")
      |> eos()
    )
  end

  @doc """
  Parse the contents of a mars rover robot input file
  """
  @spec parse(binary) ::
          {:error, :parsing_failure}
          | {:ok, MarsRover.FileParser.RobotsFile.t()}
  def parse(contents) do
    case Internal.robotfile(contents) do
      {:ok, [grid, robots], _, _, _, _} ->
        {:ok, %RobotsFile{grid_size: grid, robots: robots}}

      {:error, _, _, _, _, _} ->
        {:error, :parsing_failure}
    end
  end
end
