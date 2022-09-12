require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_9'

class PirateBossMapLevel13 < PirateBossMap
    # draws level 13 map
    def generate_level_13_map(random = 5, target = 5, surround = 30, screen = 1, destroy = 0, hp = 50)
        # obstacles
        draw_square_walls(@map.tile_w * 6, @map.tile_h * 6, 6)
        @map.obstacles = @map.obstacles.select.with_index { |obstacle, i| ![1, 6, 8, 13, 18, 20].include?(i) }

        @map.opponent_players <<
            PirateBoss.new(
                350                                                                                                          ,  # x
                350                                                                                                          ,  # y
                @map.players                                                                                                 ,  # players
                { "random" => random, "target" => target, "surround" => surround, "screen" => screen, "destroy"  => destroy },  # attack_types
                3                                                                                                            ,  # speed
                ["l", "r", "u", "d"].sample                                                                                  ,  # initial direction
                6                                                                                                            ,  # chasing speed
                hp                                                                                                           ,  # life_count
                3                                                                                                            ,  # boom_length
                10_000                                                                                                          # time_gap bw attacks
            )

        @map.summon_boss = true
        @map.generate_empty_positions

        # player positions
        player_positions = @map.empty_positions.select { |(x, y)| x == 0 || y == 0 }
        @map.players.each { |player| player.x, player.y = player_positions.sample }
    end

    # generate next move for all pirates in level 13 map --- pirates has exact same behavior as level 9, but with higher random_occupied percentage during "random attack"
    def generate_level_13_moves
        PirateBossMapLevel9.new(@map).generate_level_9_moves(10)
    end
end
