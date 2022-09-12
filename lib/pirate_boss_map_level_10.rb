require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_9'

class PirateBossMapLevel10 < PirateBossMap
    # draws level 10 map
    def generate_level_10_map
        # obstacles
        draw_square_walls(@map.tile_w, @map.tile_h, 1)

       # items
        x, y = 0, 0 ; item_positions = []
        (@map.screen_w / @map.tile_w - 1).times { item_positions << [x, y] ; x += @map.tile_w }
        (@map.screen_h / @map.tile_h - 1).times { item_positions << [x, y] ; y += @map.tile_h }
        (@map.screen_w / @map.tile_w - 1).times { item_positions << [x, y] ; x -= @map.tile_w }
        (@map.screen_h / @map.tile_h - 1).times { item_positions << [x, y] ; y -= @map.tile_h }
        @map.generate_items(item_positions, 1)

        # boss pirate
        @map.opponent_players <<
            PirateBoss.new(
                400                                                                                ,  # x
                400                                                                                ,  # y
                @map.players                                                                       ,  # players
                { "random" => 50, "target" => 5, "surround" => 0, "screen" => 0, "destroy"  => 0 } ,  # attack_types
                2                                                                                  ,  # speed
                ["l", "r", "u", "d"].sample                                                        ,  # initial direction
                4                                                                                  ,  # chasing speed
                15                                                                                 ,  # life_count
                3                                                                                  ,  # boom_length
                10_000                                                                                # time_gap bw attacks
            )

        @map.summon_boss = true
        @map.generate_empty_positions

        # player positions
        @map.players.each { |player| player.x, player.y = item_positions.sample }
    end

    # generate next move for all pirates in level 10 map --- pirates has exact same behavior as level 9
    def generate_level_10_moves
        PirateBossMapLevel9.new(@map).generate_level_9_moves
    end
end
