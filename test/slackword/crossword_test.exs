defmodule Slackword.ParserTest do
  use ExUnit.Case, async: true

  alias Slackword.Parser
  alias Slackword.Crossword

  @test_xml """
<crossword-compiler xmlns="http://crossword.info/xml/crossword-compiler">
  <rectangular-puzzle xmlns="http://crossword.info/xml/rectangular-puzzle" alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ">
    <metadata>
      <title>Test Crossword</title>
      <creator>Rohan</creator>
      <copyright>2016 Rohan</copyright>
      <description/>
    </metadata>
    <crossword>
      <grid width="3" height="3">
        <grid-look numbering-scheme="normal" clue-square-divider-width="0.7"/>
        <cell x="1" y="1" solution="C" number="1"/>
        <cell x="1" y="2" solution="A" number="3"/>
        <cell x="1" y="3" solution="P" number="4"/>
        <cell x="2" y="1" solution="A" number="2"/>
        <cell x="2" y="2" solution="N"/>
        <cell x="2" y="3" solution="T"/>
        <cell x="3" y="1" solution="T" />
        <cell x="3" y="2" type="block"/>
        <cell x="3" y="3" solution="O"/>
      </grid>
      <word id="1" x="1-3" y="1"/>
      <word id="2" x="1-2" y="2"/>
      <word id="3" x="1-3" y="3"/>
      <word id="4" x="1" y="1-3"/>
      <word id="5" x="2" y="1-3"/>
      <clues ordering="normal">
        <title>
          <b>Across</b>
        </title>
        <clue word="1" number="1" format="3">Animal that goes meow</clue>
        <clue word="2" number="3" format="2">Vowel a</clue>
        <clue word="3" number="4" format="3">Vacation</clue>
      </clues>
      <clues ordering="normal">
        <title>
          <b>Down</b>
        </title>
        <clue word="4" number="1" format="3">On your head</clue>
        <clue word="5" number="2" format="3">Insect</clue>
      </clues>
    </crossword>
  </rectangular-puzzle>
</crossword-compiler>
"""
  setup do
    crossword = Parser.parse(@test_xml)
    {:ok, crossword: crossword}
  end

  test "metadata", %{crossword: crossword} do
    assert crossword.metadata.title == "Test Crossword"
    assert crossword.metadata.creator == "Rohan"
    assert crossword.metadata.copyright == "2016 Rohan"
  end

  test "grid", %{crossword: crossword} do
    assert crossword.grid.width == 3
    assert crossword.grid.height == 3
    top_left = Crossword.get(crossword, 1, 1)
    assert top_left.number == "1"
    assert top_left.solution == "C"
    assert top_left.answer == ""
    assert Crossword.block?(top_left) == false
    block = Crossword.get(crossword, 3, 2)
    assert Crossword.block?(block) == true
    bottom_right = Crossword.get(crossword, 3, 3)
    assert bottom_right.number == ""
    assert bottom_right.solution == "O"
    assert bottom_right.answer == ""
    assert Crossword.block?(bottom_right) == false
  end

end
