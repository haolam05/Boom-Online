require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_4'

class PirateBossMapLevel5 < PirateBossMap
    # draws level 5 map
    def generate_level_5_map(irremovable_pct = 0, removable_pct = 100, slave_speed = 4, num_slaves = 20)
        # obstacles
        x1, y1, x2, y2, x3, y3 = @map.tile_w * 1 , @map.tile_h * 2, @map.tile_w * 0 , @map.tile_h * 3, @map.tile_w * 2 , @map.tile_h * 3 ; draw_surround_shape(x1, y1, x2, y2, x3, y3, irremovable_pct, removable_pct)
        x1, y1, x2, y2, x3, y3 = @map.tile_w * 5 , @map.tile_h * 3, @map.tile_w * 4 , @map.tile_h * 4, @map.tile_w * 6 , @map.tile_h * 4 ; draw_surround_shape(x1, y1, x2, y2, x3, y3, irremovable_pct, removable_pct)
        x1, y1, x2, y2, x3, y3 = @map.tile_w * 9 , @map.tile_h * 4, @map.tile_w * 8 , @map.tile_h * 5, @map.tile_w * 10, @map.tile_h * 5 ; draw_surround_shape(x1, y1, x2, y2, x3, y3, irremovable_pct, removable_pct)
        x1, y1, x2, y2, x3, y3 = @map.tile_w * 13, @map.tile_h * 3, @map.tile_w * 12, @map.tile_h * 4, @map.tile_w * 14, @map.tile_h * 4 ; draw_surround_shape(x1, y1, x2, y2, x3, y3, irremovable_pct, removable_pct)
        x1, y1, x2, y2, x3, y3 = @map.tile_w * 17, @map.tile_h * 2, @map.tile_w * 16, @map.tile_h * 3, @map.tile_w * 18, @map.tile_h * 3 ; draw_surround_shape(x1, y1, x2, y2, x3, y3, irremovable_pct, removable_pct)

        if slave_speed >= 5
            # items positions other than default(under soft stones --- removable obstacles). Instead, in empty space
            x, y = 0, 0 ; item_positions = []
            (@map.screen_w / @map.tile_w - 1).times { item_positions << [x, y] ; x += @map.tile_w }
            (@map.screen_h / @map.tile_h - 1).times { item_positions << [x, y] ; y += @map.tile_h }
            (@map.screen_w / @map.tile_w - 1).times { item_positions << [x, y] ; x -= @map.tile_w }
            @map.generate_items(item_positions, 1)
        end

        # possible player positions
        n = -1 ; player_positions = []
        5.times do |j|
            j <= 2 ? n += 1 : n -= 1
            3.times { |i| player_positions << [@map.tile_w * ((j * 4) + 1), @map.tile_h * (i * 5 + (n + 3))] }
        end

        @map.players.each { |player| player.x, player.y = player_positions.sample }

        # pirate slaves
        @map.generate_empty_positions
        empty_positions = @map.empty_positions.select { |pos| !player_positions.include?(pos) && pos[0] != 0}

        num_slaves.times do
            rand_x, rand_y = empty_positions.sample
            rand_direction = ["l", "r", "u", "d"].sample 
            @map.opponent_players << PirateSlave.new(rand_x, rand_y, slave_speed, rand_direction, slave_speed * 2)
        end

    end

    # generate next move for all pirates in level 5 map --- pirates has exact same behavior as level 4
    def generate_level_5_moves
        PirateBossMapLevel4.new(@map).generate_level_4_moves
    end
end
