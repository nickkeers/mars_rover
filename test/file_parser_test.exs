defmodule MarsRoverTest.FileParserTest do
  use ExUnit.Case
  doctest MarsRover.FileParser

  @nice_file """
  4 8
  (2, 3, N) FLLFR
  (1, 0, S) FFRLF
  """

  @bad_file """
  6 4
  (2, 3) FFAB
  (2, 1, 1, N) FFAC
  """

  @bad_instructions """
  6 4
  (2, 3, N) FFLR
  (2, 1, N) FFA
  """

  describe "Internal NimbleParsec robotfile parser" do
    test "parses a file correctly" do
      assert MarsRover.FileParser.Internal.robotfile(@nice_file) ==
               {:ok,
                [
                  {4, 8},
                  [
                    %MarsRover.FileParser.Robot{
                      facing: "N",
                      x: 2,
                      y: 3,
                      instructions: ["F", "L", "L", "F", "R"]
                    },
                    %MarsRover.FileParser.Robot{
                      facing: "S",
                      x: 1,
                      y: 0,
                      instructions: ["F", "F", "R", "L", "F"]
                    }
                  ]
                ], "", %{}, {4, 36}, 36}
    end

    test "fails to parse a file with incorrect directions" do
      assert MarsRover.FileParser.Internal.robotfile(@bad_file) ==
               {:error, "expected direction must be N, E, S, W while processing robot",
                ") FFAB\n(2, 1, 1, N) FFAC\n", %{}, {2, 4}, 9}
    end

    test "fails to parse a file with incorrect instructions" do
      assert MarsRover.FileParser.Internal.robotfile(@bad_instructions) ==
               {:error, "expected end of string", "A\n", %{}, {3, 19}, 31}
    end

    test "fails to parse when only a header is included" do
      assert MarsRover.FileParser.Internal.robotfile("4 6\n") ==
               {:error, "expected direction must be N, E, S, W while processing robot", "", %{},
                {2, 4}, 4}
    end
  end

  describe "public facing module" do
    test "parses correctly" do
      assert MarsRover.FileParser.parse(@nice_file) ==
               {:ok,
                %MarsRover.FileParser.RobotsFile{
                  grid_size: {4, 8},
                  robots: [
                    %MarsRover.FileParser.Robot{
                      facing: "N",
                      x: 2,
                      y: 3,
                      instructions: ["F", "L", "L", "F", "R"]
                    },
                    %MarsRover.FileParser.Robot{
                      facing: "S",
                      x: 1,
                      y: 0,
                      instructions: ["F", "F", "R", "L", "F"]
                    }
                  ]
                }}
    end

    test "fails to parse with a simple error tuple" do
      assert MarsRover.FileParser.parse("4 6\n") ==
               {:error, :parsing_failure}
    end
  end
end
