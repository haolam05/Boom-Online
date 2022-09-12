require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_9'

class PirateBossMapLevel16 < PirateBossMap
    # draws level 16 map
    def generate_level_16_map
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
                100                                                                                  ,  # life_count
                3                                                                                    ,  # boom_length
                5_000                                                                                   # time_gap bw attacks
            )
            
        @map.opponent_players.first.normal_image = Gosu::Image.new("./images/boss/piggy_100.png"     , :tileable => true)
        @map.opponent_players.first.boom_image   = Gosu::Image.new("./images/boss/piggy_100_boom.png", :tileable => true)
        @map.summon_boss = true
        @map.generate_empty_positions

        # player positions
        @map.players.each { |player| player.x, player.y = [500, 500] }
    end

    # generate next move for all pirates in level 16 map --- pirates has exact same behavior as level 9, but with higher random_occupied percentage during "random attack"
    def generate_level_16_moves
        if @map.opponent_players.first
            if    @map.opponent_players.first.life_count >= 80
                @map.opponent_players.first.normal_image = Gosu::Image.new("./images/boss/piggy_100.png"     , :tileable => true)
                @map.opponent_players.first.boom_image   = Gosu::Image.new("./images/boss/piggy_100_boom.png", :tileable => true)
            elsif @map.opponent_players.first.life_count >= 60
                @map.opponent_players.first.normal_image = Gosu::Image.new("./images/boss/piggy_80.png"     , :tileable => true)
                @map.opponent_players.first.boom_image   = Gosu::Image.new("./images/boss/piggy_80_boom.png", :tileable => true)
            elsif @map.opponent_players.first.life_count >= 40
                @map.opponent_players.first.normal_image = Gosu::Image.new("./images/boss/piggy_60.png"     , :tileable => true)
                @map.opponent_players.first.boom_image   = Gosu::Image.new("./images/boss/piggy_60_boom.png", :tileable => true)
            elsif @map.opponent_players.first.life_count >= 20
                @map.opponent_players.first.normal_image = Gosu::Image.new("./images/boss/piggy_40.png"     , :tileable => true)
                @map.opponent_players.first.boom_image   = Gosu::Image.new("./images/boss/piggy_40_boom.png", :tileable => true)
            elsif @map.opponent_players.first.life_count >= 0
                @map.opponent_players.first.normal_image = Gosu::Image.new("./images/boss/piggy_20.png"     , :tileable => true)
                @map.opponent_players.first.boom_image   = Gosu::Image.new("./images/boss/piggy_20_boom.png", :tileable => true)
            end
        end

        PirateBossMapLevel9.new(@map).generate_level_9_moves(15)
    end
end
