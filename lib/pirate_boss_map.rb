require_relative 'obstacle'
require_relative 'pirate_slave'
require_relative 'pirate_boss'

class PirateBossMap
    def initialize(map)
        @map = map
    end

private
    # draws a "square shape" walls based on given dimensions
    def draw_square_walls(x, y, n, incr_x = @map.tile_w, incr_y = @map.tile_h)
        (@map.screen_w / @map.tile_w - (n * 2    )).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; x += incr_x } ; x, y = x - incr_x, y + incr_y
        (@map.screen_h / @map.tile_h - (n * 2 + 1)).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; y += incr_y } ; x, y = x - incr_x, y - incr_y
        (@map.screen_w / @map.tile_w - (n * 2 + 1)).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; x -= incr_x } ; x, y = x + incr_x, y - incr_y
        (@map.screen_h / @map.tile_h - (n * 2 + 1)).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; y -= incr_y }
    end

    # draws a surrounding shape based on given dimensions
    def draw_surround_shape(x1, y1, x2, y2, x3, y3, irremovable_pct, removable_pct)
        3.times { 2.times { @map.add_obstacle(Obstacle.new(x1, y1, @map.removable?(irremovable_pct, removable_pct))) ; y1 += (2 * @map.tile_h) } ; y1 += @map.tile_h       }
        3.times {           @map.add_obstacle(Obstacle.new(x2, y2, @map.removable?(irremovable_pct, removable_pct))) ; y2 += (2 * @map.tile_h)   ; y2 += (3 * @map.tile_h) }
        3.times {           @map.add_obstacle(Obstacle.new(x3, y3, @map.removable?(irremovable_pct, removable_pct))) ; y3 += (2 * @map.tile_h)   ; y3 += (3 * @map.tile_h) }
    end
end
