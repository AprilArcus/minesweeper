require_relative 'tile'

class Board
  attr_reader :rows, :cols
  
  def initialize(options={})
    defaults = {cols: 9, rows: 9, bombs: 9}
    options = defaults.merge(options)
    @rows = options[:rows]
    @cols = options[:cols]
    @board = Array.new(@rows) { Array.new(@cols) }
    set_up(options[:bombs])
  end
  
  def set_up(bombs)
    bomb_coords = (0...@cols).to_a.product((0...@rows).to_a).sample(bombs)
    @board.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        self[[x, y]] = Tile.new( self, [x, y], bomb_coords.include?([x,y]) )
      end
    end
  end
  
  def [](pos)
    x,y = pos[0], pos[1]
    @board[y][x]
  end
  
  def []=(pos, tile)
    x, y = pos[0], pos[1]
    @board[y][x] = tile
  end
  
  def view(method = :to_s)
    @board.reduce([]) do |view, row|
      view << row.map(&method)
      view
    end
  end
  
  def won?
    @board.all? do |row|
      row.all? do |tile|
        tile.explored? || tile.bomb?
      end
    end
  end
  
end