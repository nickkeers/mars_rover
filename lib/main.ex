defmodule MarsRover.Main do
  @moduledoc """
  CLI entry point to run the project
  """
  alias MarsRover.FileParser.RobotsFile
  alias MarsRover.FileParser
  alias MarsRover.Robot

  def main([]) do
    main(["test_file.txt"])
  end

  def main([filename]) do
    with {:ok, data} <- File.read(filename),
         {:ok, %RobotsFile{grid_size: grid, robots: robots}} <- FileParser.parse(data) do
      Enum.each(robots, fn robot ->
        Robot.simulate(grid, robot)
        |> IO.puts()
      end)
    end
  end
end
