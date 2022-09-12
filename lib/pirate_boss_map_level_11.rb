require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_9'

class PirateBossMapLevel11 < PirateBossMap
    # draws level 11 map
    def generate_level_11_map
        # obstacles
        draw_square_walls(@map.tile_w * 3, @map.tile_h * 3, 3)

        # boss pirate
        @map.opponent_players <<
            PirateBoss.new(
                300                                                                                 ,  # x
                300                                                                                 ,  # y
                @map.players                                                                        ,  # players
                { "random" => 5, "target" => 30, "surround" => 0, "screen" => 0, "destroy"  => 0 },  # attack_types
                3                                                                                   ,  # speed
                ["l", "r", "u", "d"].sample                                                         ,  # initial direction
                6                                                                                   ,  # chasing speed
                25                                                                                  ,  # life_count
                3                                                                                   ,  # boom_length
                10_000                                                                                 # time_gap bw attacks
            )

        @map.summon_boss = true
        @map.generate_empty_positions
        
        # player positions
        player_positions = @map.empty_positions.select { |(x, y)| x == 0 || y == 0 }
        @map.players.each { |player| player.x, player.y = player_positions.sample }
    end

    # generate next move for all pirates in level 11 map --- pirates has exact same behavior as level 9, but with higher random_occupied percentage during "random attack"
    def generate_level_11_moves
        PirateBossMapLevel9.new(@map).generate_level_9_moves(7)
    end
end
