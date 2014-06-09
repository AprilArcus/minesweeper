# encoding: UTF-8
require_relative 'board'
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
    @lost = true if tile.bomb?
    explore_recursively(tile)
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
    x = @cursor[0]
    y = @cursor[1]
    if not over
      view = @board.view
      view[y][x] = '█'
    else
      view = @board.view(:to_s_lost)
    end
    system 'clear'
    view.each { |line| print line.join(' ')+"\n" }
  end
  
  def get_input
    input = STDIN.getch
    case input
    when "w", "k" #up
      @cursor[1] -= 1 unless @cursor[1] == 0
    when "s", "j" # down
      @cursor[1] += 1 unless @cursor[1] == @board.rows-1
    when "a", "h" # left
      @cursor[0] -= 1 unless @cursor[0] == 0
    when "d", "l" # right
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
  # screen = Curses.init_screen
  # width = screen.maxx
  # height = screen.maxy

  if File.file?(Minesweeper::SAVE_FILE)
    Minesweeper.load.play
  else
    Minesweeper.new(rows: 24, cols: 40).play
  end
end