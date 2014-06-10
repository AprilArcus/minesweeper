require_relative 'board'
require_relative 'minesweeper'

class ComputerPlayer

  def initialize
    @board = nil
  end

  public
  def move(board)
    @board = board
    (flag_bomb || safe_move || random_move).pos
  end
  
  private
  def all_tiles
    all_coords = (0...@board.cols).to_a.product(0...@board.rows).to_a
    all_coords.map { |pos| @board[pos] }
  end 
  
  def explored_tiles_with_unexplored_neighbors
    all_tiles.select do |tile|
      tile.explored? && tile.neighbors.any? { |tile| !tile.explored? }
    end
  end
  
  def num_neighboring_flags(tile)
    tile.neighbors.select { |tile| tile.flagged? }.count
  end
  
  def num_unexplored_neighbors(tile)
    tile.neighbors.select { |tile| tile.explored? }.count
  end
  
  def safe_move
    safe_tiles = explored_tiles_with_unexplored_neighbors.find do |tile|
      tile.neighboring_bombs == num_neighboring_flags(tile)
    end
    safe_tiles.sample
  end
  
  def unexplored_tiles
    all_tiles.select { |tile| !tile.flagged? && !tile.explored? }
  end
  
  def flag_bomb
    definitely_surrounded = explored_tiles_with_unexplored_neighbors.select do |tile|
      num_unexplored_neighbors(tile) - num_neighboring_flags(tile) == tile.neighboring_bombs
    end
    definitely_surrounded.sample
  end
  
  def random_move    
    unexplored_tiles.sample
  end

end