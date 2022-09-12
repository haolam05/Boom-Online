require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_2'

class PirateBossMapLevel3 < PirateBossMap
    # draws level 3 map
    def generate_level_3_map
        # possible player positions
        player_positions = [[0, 0], [0, @map.tile_h], [@map.tile_w, 0], [@map.tile_w, @map.tile_h]]
        @map.players.each { |player| player.x, player.y = player_positions.sample }        

        # obstacles
        x, y = 2 * @map.tile_w, 0
        2.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) ; y += @map.tile_h }
        3.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) ; x -= @map.tile_w }

        x, y = 2 * @map.tile_w, @map.screen_h - @map.tile_h
        2.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) ; y -= @map.tile_h }
        3.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) ; x -= @map.tile_w }

        x, y = @map.tile_w * 4, @map.tile_h * 4
        (@map.screen_h / 2 / @map.tile_h).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) ; y += @map.tile_h }
        (@map.screen_w / 2 / @map.tile_w).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) ; x += @map.tile_w }
        (@map.screen_h / 2 / @map.tile_h).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) ; y -= @map.tile_h }
        (@map.screen_w / 2 / @map.tile_w).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) ; x -= @map.tile_w }

        x, y = @map.screen_w - (3 * @map.tile_w), 0
        (@map.screen_h / @map.tile_h).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; y += @map.tile_h }

        # items positions other than default(under soft stones --- removable obstacles). Instead, in empty space
        x, y = @map.screen_w - (2 * @map.tile_w), 0 ; item_positions = []
        2.times { (@map.screen_h / @map.tile_h).times { item_positions << [x, y] ; y += @map.tile_h } ; x += @map.tile_w ; y = 0 }
        @map.generate_items(item_positions, 1)

        # slave pirates
        x, y = @map.tile_w * 4 + @map.tile_w, @map.tile_h * 4 + @map.tile_h
        20.times do
            rand_x         = x + (0..8).to_a.map { |n| n * @map.tile_w }.sample
            rand_y         = y + (0..7).to_a.map { |n| n * @map.tile_h }.sample
            rand_direction = ["l", "r", "u", "d"].sample 
            @map.opponent_players << PirateSlave.new(rand_x, rand_y, 4, rand_direction, 8)
        end
    end
    
    # generate next move for all pirates in level 3 map --- pirates has same behavior as level 2 but has wider scanning radius when looking for players to chase
    def generate_level_3_moves
        @map.opponent_players.each { |opponent| PirateBossMapLevel2.new(@map).generate_level_2_move(opponent, 8) }
    end
end
