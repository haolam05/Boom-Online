require_relative 'pirate_boss_map'

class PirateBossMapLevel1 < PirateBossMap
    # draws level 1 map
    def generate_level_1_map
        # obstacles
        x, y = 0, @map.tile_h
        (@map.screen_h / @map.tile_h / 2).times do
            (@map.screen_w / @map.tile_w).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(80, 20))) ; x += @map.tile_w }
            x, y = 0, y + (2 * @map.tile_h)
        end

        # slave pirates
        x, y = 0, 2 * @map.tile_h
        (@map.screen_h / @map.tile_h / 2 - 1).times do
            player_x1 = rand(0..(@map.screen_w / @map.tile_w - 1)) * @map.tile_w
            player_x2 = rand(0..(@map.screen_w / @map.tile_w - 1)) * @map.tile_w

            while player_x2 == player_x1
                player_x2 = rand(0..(@map.screen_w / @map.tile_w - 1)) * @map.tile_w
            end

            @map.opponent_players << PirateSlave.new(player_x1, y)
            @map.opponent_players << PirateSlave.new(player_x2, y)

            x, y = 0, y + (2 * @map.tile_h)
        end

        # possible initial player positions
        (0...(@map.screen_w / @map.tile_w)).to_a.map { |n| n * @map.tile_w }.each { |x| @map.empty_positions << [x, 0] }
        @map.generate_random_player_positions
    end

    # generate next move for all pirates in level 1 map
    def generate_level_1_moves
        @map.opponent_players.each { |opponent| generate_level_1_move(opponent, 1.5) }
    end

    # generate next move for 1 pirate in level 1 map
    def generate_level_1_move(opponent, scanning_radius)
        opponent.chasing = false

        if    opponent.x + opponent.width  >= @map.screen_w && opponent.curr_direction == "r" ; opponent.change_direction("l", @map.window) # right  of screen
        elsif opponent.x <= 0                               && opponent.curr_direction == "l" ; opponent.change_direction("r", @map.window) # left   of screen
        elsif opponent.y + opponent.height >= @map.screen_h && opponent.curr_direction == "d" ; opponent.change_direction("u", @map.window) # bottom of screen
        elsif opponent.y <= 0                               && opponent.curr_direction == "u" ; opponent.change_direction("d", @map.window) # top    of screen
        elsif opponent.obstacle?(@map.obstacles, opponent.curr_direction) ; opponent.change_direction(opponent.opposite_direction, @map.window) # obstacles(walls, booms...)
        else
            close_to_player, direction = @map.close_to_players(opponent, scanning_radius)
            if close_to_player
                opponent.change_direction(direction, @map.window)
                opponent.chasing        = true
            end
        end
            
        opponent.move(@map, @map.window)
    end
end
