# encoding: UTF-8
class Tile
  def initialize(board, pos, bomb)
    @board = board
    @pos = pos
    @bomb = bomb
    @flagged = false
    @explored = false
  end

  attr_reader :bomb, :pos
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
  
  def to_s
    return "F" if @flagged
    return "?" unless @explored
    (neighboring_bombs > 0) ? neighboring_bombs.to_s : ' '
  end
  
  def to_s_lost
    return '*' if @bomb
    return 'F' if @flagged
    (neighboring_bombs > 0) ? neighboring_bombs.to_s : ' '
  end
  
end