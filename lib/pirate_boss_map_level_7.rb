require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_4'

class PirateBossMapLevel7 < PirateBossMap
    # draws level 7 map
    def generate_level_7_map(slave_speed = 5, chase_speed = 5, num_slaves = 25)
        # obstacles
        x, y = @map.tile_w * 3, @map.screen_h - @map.tile_h
        (@map.screen_h / 2 / @map.tile_h).times { 3.times { 2.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) ; x += @map.tile_w } ; x += (4 * @map.tile_w) } ; x, y = @map.tile_w * 3, y - @map.tile_h } ; x = 0
        2.times { (@map.screen_w / @map.tile_w).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; x += @map.tile_w } ; x, y = 0, y - (3 * @map.tile_h) } ; x, y = 0, y + (4 * @map.tile_h)
        2.times { 4.times { 2.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; y += @map.tile_h } ; x, y = x + (6 * @map.tile_w), y - (2 * @map.tile_h) } ; x = @map.tile_w }

        # possible player positions
        player_positions = [[0, 0], [@map.screen_w - @map.tile_w, 0]]
        @map.players.each { |player| player.x, player.y = player_positions.sample }

        # pirate slaves
        @map.generate_empty_positions
        empty_positions = @map.empty_positions.select { |pos| !player_positions.include?(pos) && pos[1] >= @map.screen_h / 2 }

        num_slaves.times do
            rand_x, rand_y = empty_positions.sample
            rand_direction = ["l", "r", "u", "d"].sample 
            @map.opponent_players << PirateSlave.new(rand_x, rand_y, slave_speed, rand_direction, chase_speed)
        end
    end

    # generate next move for all pirates in level 7 map --- pirates has exact same behavior as level 4
    def generate_level_7_moves
        PirateBossMapLevel4.new(@map).generate_level_4_moves
    end
end
