require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_1'

class PirateBossMapLevel2 < PirateBossMap
    # draws level 2 map
    def generate_level_2_map
        # possible initial player positions
        x, y = @map.screen_w / 2 - @map.tile_w, @map.screen_h / 2 - @map.tile_h ; player_positions = []
        player_positions << [x              , y] ; player_positions << [x              , y + @map.tile_h]
        player_positions << [x + @map.tile_w, y] ; player_positions << [x + @map.tile_w, y + @map.tile_w]
        @map.players.each { |player| player.x, player.y = player_positions.sample }

        # obstacles
        y = 0
        (@map.screen_h / @map.tile_h).times do
            2.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) if !player_positions.include?([x, y]) ; x += @map.tile_w }
            x, y = @map.screen_w / 2 - @map.tile_w, y + @map.tile_h
        end
        
        x, y = 0, @map.screen_h / 2 - @map.tile_h
        (@map.screen_w / @map.tile_w).times do
            2.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(0, 100))) if !player_positions.include?([x, y]) ; y += @map.tile_h }
            x, y = x + @map.tile_w, @map.screen_h / 2 - @map.tile_h
        end

        @map.add_obstacle(Obstacle.new(@map.tile_w                      , 0                                , @map.removable?(0  , 100)))
        @map.add_obstacle(Obstacle.new(@map.tile_w                      , @map.tile_h                      , @map.removable?(100, 0  )))
        @map.add_obstacle(Obstacle.new(0                                , @map.tile_h                      , @map.removable?(100, 0  )))
        @map.add_obstacle(Obstacle.new(@map.screen_w - (2 * @map.tile_w), 0                                , @map.removable?(0  , 100)))
        @map.add_obstacle(Obstacle.new(@map.screen_w - (2 * @map.tile_w), @map.tile_h                      , @map.removable?(100, 0  )))
        @map.add_obstacle(Obstacle.new(@map.screen_w - (1 * @map.tile_w), @map.tile_h                      , @map.removable?(100, 0  )))
        @map.add_obstacle(Obstacle.new(@map.screen_w - (2 * @map.tile_w), @map.screen_h - (1 * @map.tile_h), @map.removable?(0  , 100)))
        @map.add_obstacle(Obstacle.new(@map.screen_w - (2 * @map.tile_w), @map.screen_h - (2 * @map.tile_h), @map.removable?(100, 0  )))
        @map.add_obstacle(Obstacle.new(@map.screen_w - (1 * @map.tile_w), @map.screen_h - (2 * @map.tile_h), @map.removable?(100, 0  )))
        @map.add_obstacle(Obstacle.new(@map.tile_w                      , @map.screen_h - (1 * @map.tile_h), @map.removable?(0  , 100)))
        @map.add_obstacle(Obstacle.new(@map.tile_w                      , @map.screen_h - (2 * @map.tile_h), @map.removable?(100, 0  )))
        @map.add_obstacle(Obstacle.new(0                                , @map.screen_h - (2 * @map.tile_h), @map.removable?(100, 0  )))

        # slave pirates
        [[0, 0], [@map.screen_w - @map.tile_w, 0], [0, @map.screen_h - @map.tile_h], [@map.screen_w - @map.tile_w, @map.screen_h - @map.tile_h]].each do |(x, y)|
            @map.opponent_players << PirateSlave.new(x, y, 5)
        end

        x, y = @map.tile_w * 3, 0
        2.times do
            6.times do |i|
                @map.opponent_players << PirateSlave.new(x, y, 1, "u")
                x += (3 * @map.tile_w) if i == 2
                x, y = x + (2 * @map.tile_w), y
            end

            x, y = @map.tile_w * 3, @map.screen_h - @map.tile_h
        end
    end

    # generate next move for all pirates in level 2 map
    def generate_level_2_moves
        @map.opponent_players.each { |opponent| generate_level_2_move(opponent, 5) }
    end

    # generate next move for 1 pirate in level 2 map
    def generate_level_2_move(opponent, scanning_radius)
        opponent.chasing = false

        if opponent.speed == 1
            PirateBossMapLevel1.new(@map).generate_level_1_move(opponent, 1.5)
        else
            close_to_player, direction = @map.close_to_players(opponent, scanning_radius)
            if close_to_player
                opponent.change_direction(direction, @map.window)
                opponent.chasing = true
                opponent.move(@map, @map.window)
            else
                PirateBossMapLevel1.new(@map).generate_level_1_move(opponent, 1.5)
            end
        end
    end
end