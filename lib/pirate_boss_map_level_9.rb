require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_4'

class PirateBossMapLevel9 < PirateBossMap
    # draws level 9 map
    def generate_level_9_map
        # obstacles
        x, y = @map.tile_w, 0
        2.times { (@map.screen_h / @map.tile_h - 1).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; y += @map.tile_h } ; x, y = x + (2 * @map.tile_w), @map.tile_h } ; y = 0
        2.times { (@map.screen_h / @map.tile_h - 1).times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; y += @map.tile_h } ; x, y = x + (2 * @map.tile_w), @map.tile_h } ; x -= @map.tile_w
        12.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; x += @map.tile_w }

        x, y = @map.screen_w - @map.tile_w, @map.screen_h - (3 * @map.tile_h)
        @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; x -= @map.tile_w
        3.times { @map.add_obstacle(Obstacle.new(x, y, @map.removable?(100, 0))) ; y += @map.tile_h }

        # possible player positions
        player_positions = [[@map.screen_w - @map.tile_w, @map.screen_h - @map.tile_h], [@map.screen_w - @map.tile_w, @map.screen_h - (2 * @map.tile_h)]]
        @map.players.each_with_index { |player, i| @map.players[i].x, @map.players[i].y = player_positions[i] }

        # pirate slaves
        x, y = 0, 0
        13.times { @map.opponent_players << PirateSlave.new(x, y, 20, "d") ; y += @map.tile_h } 
    end

    # generate next move for all pirates in level 9 map
    def generate_level_9_moves(random_occupied_pct = 5)
        if @map.summon_boss                                                                                                                                                 # boss is already summon
            @map.opponent_players.each do |opponent|
                opponent.plant_booms(@map, random_occupied_pct) if opponent.is_a?(PirateBoss) && !opponent.dying? && opponent.plantable?
                PirateBossMapLevel4.new(@map).generate_level_4_move(opponent)
            end
        elsif @map.opponent_players[-1] && @map.opponent_players[-1].x >= @map.screen_w - @map.tile_w && @map.opponent_players[-1].y <= 0                                   # boss is now summon
                @map.opponent_players.each { |opponent| opponent.speed = 5 ; opponent.chasing_speed = 10 ; opponent.change_direction(["l", "r", "u", "d"].sample, @map.window) }
                @map.obstacles   = []
                @map.opponent_players <<
                    PirateBoss.new(
                        700                                                                                ,  # x
                        400                                                                                ,  # y
                        @map.players                                                                       ,  # players
                        { "random" => 50, "target" => 10, "surround" => 0, "screen" => 0, "destroy"  => 0 },  # attack_types
                        2                                                                                  ,  # speed
                        ["l", "r", "u", "d"].sample                                                        ,  # initial direction
                        2                                                                                  ,  # chasing speed
                        5                                                                                  ,  # life_count
                        3                                                                                  ,  # boom_length
                        10_000                                                                                # time_gap bw attacks
                    )

                @map.generate_empty_positions
                @map.summon_boss = true
        else                                                                                                                                                                # boss is not yet summon
            @map.opponent_players.each do |opponent|

                if    opponent.y + opponent.height >= @map.screen_h && opponent.curr_direction == "d" ; opponent.change_direction("r", @map.window) # bottom of screen
                elsif opponent.y <= 0                               && opponent.curr_direction == "u" ; opponent.change_direction("r", @map.window) # top    of screen
                elsif opponent.obstacle?(@map.obstacles, opponent.curr_direction)
                    if opponent.curr_direction == "r"
                        opponent.change_direction((!opponent.obstacle?(@map.obstacles, "u") && opponent.y > 0) ? "u" : "d", @map.window)
                    end
                end

                opponent.move(@map, @map.window) 
            end
        end
    end
end
