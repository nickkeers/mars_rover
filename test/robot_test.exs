defmodule MarsRover.RobotTest do
  use ExUnit.Case
  doctest MarsRover.Robot

  alias MarsRover.FileParser.Robot

  describe "can move a robot using simulate" do
    test "can move a robot east" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "E", x: 0, y: 0, instructions: ["F"]}) == "(1, 0, E)"
    end

    test "can move a robot west" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "W", x: 1, y: 0, instructions: ["F"]}) == "(0, 0, W)"
    end

    test "can move a robot south" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "S", x: 0, y: 1, instructions: ["F"]}) == "(0, 0, S)"
    end

    test "can move a robot north" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "N", x: 0, y: 0, instructions: ["F"]}) == "(0, 1, N)"
    end
  end

  describe "out of bounds checks" do
    test "the robot reports its last known position when moving out of bounds south" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "S", x: 0, y: 0, instructions: ["F"]}) == "(0, 0, S) LOST"
    end

    test "the robot reports its last known position when moving out of bounds north" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "N", x: 0, y: 4, instructions: ["F"]}) == "(0, 4, N) LOST"
    end

    test "the robot reports its last known position when moving out of bounds east" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "E", x: 4, y: 0, instructions: ["F"]}) == "(4, 0, E) LOST"
    end

    test "the robot reports its last known position when moving out of bounds west" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "W", x: 0, y: 0, instructions: ["F"]}) == "(0, 0, W) LOST"
    end

    test "the robot reports its last known position when moving out of max bounds north" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "N", x: 4, y: 4, instructions: ["F"]}) == "(4, 4, N) LOST"
    end

    test "the robot reports its last known position when moving out of max bounds east" do
      assert MarsRover.Robot.simulate({4, 4}, %Robot{facing: "E", x: 4, y: 4, instructions: ["F"]}) == "(4, 4, E) LOST"
    end
  end

  describe "do_move can move in all four directions" do
    test "can move east" do
      assert MarsRover.Robot.do_move({0, 0}, "E") == {1, 0}
    end

    test "can move west" do
      assert MarsRover.Robot.do_move({1, 0}, "W") == {0, 0}
    end

    test "can move north" do
      assert MarsRover.Robot.do_move({0, 0}, "N") == {0, 1}
    end

    test "can move south" do
      assert MarsRover.Robot.do_move({0, 1}, "S") == {0, 0}
    end
  end
end
