require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_3'

class PirateBossMapLevel4 < PirateBossMap
    # draws level 4 map
    def generate_level_4_map
        PirateBossMapLevel3.new(@map).generate_level_3_map
    end

    # generate next move for all pirates in level 4 map 
    def generate_level_4_moves
        @map.opponent_players.each { |opponent| generate_level_4_move(opponent) }
    end

    # generate next move for 1 pirate in level 4 map 
    def generate_level_4_move(opponent)
        opponent.chasing           = false
        close_to_player, direction = @map.close_to_players(opponent, 10)

        if close_to_player
            if opponent.obstacle?(@map.obstacles, direction)
                if direction == "l" || direction == "r" ; opponent.curr_direction = ["u", "d"].sample
                else                                    ; opponent.curr_direction = ["l", "r"].sample
                end    
            else
                opponent.curr_direction = direction
            end

            opponent.chasing = true
        else
            if    opponent.x + opponent.width  >= @map.screen_w && opponent.curr_direction == "r" ; opponent.curr_direction = "l" # right  of screen
            elsif opponent.x <= 0                               && opponent.curr_direction == "l" ; opponent.curr_direction = "r" # left   of screen
            elsif opponent.y + opponent.height >= @map.screen_h && opponent.curr_direction == "d" ; opponent.curr_direction = "u" # bottom of screen
            elsif opponent.y <= 0                               && opponent.curr_direction == "u" ; opponent.curr_direction = "d" # top    of screen
            elsif opponent.obstacle?(@map.obstacles, opponent.curr_direction)
                if opponent.curr_direction == "l" || opponent.curr_direction == "r" ; opponent.curr_direction = ["u", "d"].sample
                else                                                                ; opponent.curr_direction = ["l", "r"].sample
                end
            end
        end

        opponent.move(@map.obstacles, @map.window)
    end
end
