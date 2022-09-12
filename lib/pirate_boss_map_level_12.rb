require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_9'

class PirateBossMapLevel12 < PirateBossMap
    # draws level 12 map
    def generate_level_12_map
        # obstacles
        draw_square_walls(@map.tile_w * 7, @map.tile_h * 7, 7)
        draw_square_walls(@map.tile_w * 5, @map.tile_h * 5, 5)

        # boss pirate
        @map.opponent_players <<
        PirateBoss.new(
            @map.screen_w - 200                                                                 ,  # x
            @map.screen_h - 200                                                                 ,  # y
            @map.players                                                                        ,  # players
            { "random" => 5, "target" => 5, "surround" => 0, "screen" => 30, "destroy"  => 0 }  ,  # attack_types
            3                                                                                   ,  # speed
            ["l", "r", "u", "d"].sample                                                         ,  # initial direction
            6                                                                                   ,  # chasing speed
            35                                                                                  ,  # life_count
            3                                                                                   ,  # boom_length
            10_000                                                                                 # time_gap bw attacks
        )

        @map.summon_boss = true
        @map.generate_empty_positions

        # player positions
        player_positions = @map.empty_positions.select { |(x, y)| x == 0 || y == 0 }
        @map.players.each { |player| player.x, player.y = player_positions.sample }
    end

    # generate next move for all pirates in level 12 map --- pirates has exact same behavior as level 9, but with higher random_occupied percentage during "random attack"
    def generate_level_12_moves
        PirateBossMapLevel9.new(@map).generate_level_9_moves(10)
    end
end
