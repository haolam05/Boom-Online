require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_9'

class PirateBossMapLevel15 < PirateBossMap
    # draws level 15 map
    def generate_level_15_map
        # obstacles
        boss_w, boss_h = 200, 200
        x, y           = boss_w, boss_h
        ((@map.screen_w - boss_w) / @map.tile_w).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; x += @map.tile_w } ; x, y = x - @map.tile_w - boss_w, y + @map.tile_h + boss_h
        ((@map.screen_w - boss_w) / @map.tile_w).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; x -= @map.tile_w } ; x, y = x + @map.tile_w + boss_w, y + @map.tile_h + boss_h
        ((@map.screen_w - boss_w) / @map.tile_w).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; x += @map.tile_w }

        # items
        x, y = 0, @map.screen_h - @map.tile_h ; item_positions = []
        3.times { (@map.screen_w / @map.tile_w - 1).times { item_positions << [x, y] ; x += @map.tile_w } ; x = 0 ; y -= @map.tile_h }
        @map.generate_items(item_positions, 1)

        # boss pirate
        @map.opponent_players <<
            PirateBoss.new(
                0                                                                                    ,  # x
                0                                                                                    ,  # y
                @map.players                                                                         ,  # players
                { "random" => 10, "target" => 10, "surround" => 10, "screen" => 10, "destroy"  => 1 },  # attack_types
                4                                                                                    ,  # speed
                ["l", "r", "u", "d"].sample                                                          ,  # initial direction
                8                                                                                    ,  # chasing speed
                75                                                                                   ,  # life_count
                3                                                                                    ,  # boom_length
                10_000                                                                                  # time_gap bw attacks
            )

        @map.summon_boss = true
        @map.generate_empty_positions

        # player positions
        @map.players.each { |player| player.x, player.y = [500, 500] }
    end

    # generate next move for all pirates in level 11 map --- pirates has exact same behavior as level 9, but with higher random_occupied percentage during "random attack"
    def generate_level_15_moves
        PirateBossMapLevel9.new(@map).generate_level_9_moves(12)
    end
end
