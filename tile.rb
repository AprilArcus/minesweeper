# encoding: UTF-8
class Tile
  def initialize(board, pos, bomb)
    @board = board
    @pos = pos
    @bomb = bomb
    @flagged = false
    @explored = false
  end

  attr_reader :bomb
  alias_method :bomb?, :bomb
  attr_accessor :flagged, :explored
  alias_method :flagged?, :flagged
  alias_method :explored?, :explored
  
  def neighbors
    x = @pos[0]
    y = @pos[1]
    offsets = [1,-1,0].product([1,-1,0]).select { |e| e!=[0,0] }
    neighbors = offsets.map{ |x_offset,y_offset| [x+x_offset, y+y_offset] }
    neighbors.select! do |pos|
      pos[0].between?(0, @board.cols-1) && pos[1].between?(0,@board.rows-1)
    end
    neighbors.map { |pos| @board[pos] }
  end
  
  def neighboring_bombs
    neighbors.select { |neighbor| neighbor.bomb? }.count
  end
  
  def colorize_integer(int)
    case int
    when 0 # empty
      return " "
    when 1 # green
      return "\e[38;5;78m1\e[0m"
    when 2 # blue
      return "\e[38;5;75m2\e[0m"
    when 3 # yellow
      return "\e[38;5;226m3\e[0m"
    when 4 # orange
      return "\e[38;5;208m4\e[0m"
    else # red
      return "\e[38;5;160m#{int.to_s}\e[0m"
    end
  end
  
  def to_s
    return "⚑" if @flagged
    return "?" unless @explored
    colorize_integer(neighboring_bombs)
  end
  
  def to_s_lost
    return '☠' if @bomb
    return '⚑' if @flagged
    colorize_integer(neighboring_bombs)
  end
  
end