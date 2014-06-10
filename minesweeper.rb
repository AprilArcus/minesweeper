#! /usr/bin/env ruby
# encoding: UTF-8
require_relative 'board'
require_relative 'computer_player'
require 'io/console'
require 'yaml'
require 'curses'

class Minesweeper
  SAVE_FILE = "savedgame.yaml"
  
  def initialize(options = {})
    defaults = {bombs: 150}
    options = defaults.merge(options)
    @board = Board.new(options)
    @lost = false 
    @cursor = [0, 0]
  end
  
  def explore(tile)
    if tile.flagged?
      toggle_flag(tile)
    else
      @lost = true if tile.bomb?
      explore_recursively(tile)
    end
  end
  
  def explore_recursively(tile)
    tile.explored = true
    if tile.neighboring_bombs == 0
      tile.neighbors.each do |neighbor|
        unless neighbor.bomb? || neighbor.flagged? || neighbor.explored?
          explore_recursively(neighbor)
        end
      end
    end
  end
  
  def toggle_flag(tile)
    tile.flagged = !tile.flagged?
  end
  
  def show(over = false)
    if not over
      view = @board.view
    else
      view = @board.view(:to_s_lost)
    end
    Curses.refresh
    view.each_with_index do |line, lineno|
      Curses.setpos(lineno, 0)
      line.each do |char|

        case char
        when '1' # blue
          Curses.attron(Curses.color_pair(78)) { Curses.addstr(char) }
        when '2' # green
          Curses.attron(Curses.color_pair(75)) { Curses.addstr(char) }
        when '3' # yellow
          Curses.attron(Curses.color_pair(226)) { Curses.addstr(char) }
        when '4' # orange
          Curses.attron(Curses.color_pair(208)) { Curses.addstr(char) }
        when '5', '6', '7', '8' # red
          Curses.attron(Curses.color_pair(160)) { Curses.addstr(char) }
        else
          Curses.addstr(char)
        end

        Curses.addch(' ')
      end

      x = @cursor[0]
      y = @cursor[1]
      Curses.setpos(y, x*2)
    end
  end
  
  def get_input
    input = Curses.getch
    case input
    when "w", "k", Curses::KEY_UP
      @cursor[1] -= 1 unless @cursor[1] == 0
    when "s", "j", Curses::KEY_DOWN
      @cursor[1] += 1 unless @cursor[1] == @board.rows-1
    when "a", "h", Curses::KEY_LEFT
      @cursor[0] -= 1 unless @cursor[0] == 0
    when "d", "l", Curses::KEY_RIGHT
      @cursor[0] += 1 unless @cursor[0] == @board.cols-1
    when " ", "e" # explore
      explore(@board[@cursor])
    when "f" # flag
      toggle_flag(@board[@cursor])
    when "q" # quit
      save
      exit
    else
      nil
    end
  end 
  
  def play
    until @board.won? || @lost
      show
      get_input
    end
    if @lost
      show(true)
      puts "You lost, sucker!"
    else
      show(true)
      puts "You won!"
    end
    File.delete(SAVE_FILE) if File.file?(SAVE_FILE)
  end
  
  def save
    yaml = self.to_yaml
    File.open(SAVE_FILE, "w") do |f|
      f.puts yaml
    end
  end
  
  def self.load
    YAML::load(File.read(SAVE_FILE))
  end
end

if __FILE__ == $PROGRAM_NAME
  screen = Curses.init_screen
  Curses.start_color
  Curses.use_default_colors
  Curses.init_pair( 78,  78, -1) # blue
  Curses.init_pair( 75,  75, -1) # green
  Curses.init_pair(226, 226, -1) # yellow
  Curses.init_pair(208, 208, -1) # orange
  Curses.init_pair(160, 160, -1) # red
  begin
    if File.file?(Minesweeper::SAVE_FILE)
      Minesweeper.load.play
    else
      Minesweeper.new(rows: screen.maxy, cols: screen.maxx, bombs: (width*height)/10).play
    end
  ensure
    Curses.close_screen
  end
end