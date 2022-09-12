require_relative 'player'                   ; require_relative 'obstacle'                 ; require_relative 'map_item'
require_relative 'pirate_boss_map_level_1'  ; require_relative 'pirate_boss_map_level_2'  ; require_relative 'pirate_boss_map_level_3'  ; require_relative 'pirate_boss_map_level_4'
require_relative 'pirate_boss_map_level_5'  ; require_relative 'pirate_boss_map_level_6'  ; require_relative 'pirate_boss_map_level_7'  ; require_relative 'pirate_boss_map_level_8'
require_relative 'pirate_boss_map_level_9'  ; require_relative 'pirate_boss_map_level_10' ; require_relative 'pirate_boss_map_level_11' ; require_relative 'pirate_boss_map_level_12'
require_relative 'pirate_boss_map_level_13' ; require_relative 'pirate_boss_map_level_14' ; require_relative 'pirate_boss_map_level_15' ; require_relative 'pirate_boss_map_level_16'

DEFAULT_OFFSET_X                          = 5   # screen width  / 6
DEFAULT_OFFSET_Y                          = 5   # screen height / 6
DEFAULT_IRREMOVEABLE_PCT                  = 10  # percentage of getting irremovable obstacles
DEFAULT_REMOVEABLE_PCT                    = 20  # percentage of getting removable   obstacles
DEFAULT_EXTRA_BOOM_ITEM_PCT               = 10  # out of default_removable_pct
DEFAULT_SPEED_ITEM_PCT                    = 10  # out of default_removable_pct
DEFAULT_BOOM_LENGTH_ITEM_PCT              = 10  # out of default_removable_pct
DEFAULT_ITEMS_RADAR_PCT                   = 10  # out of default_removable_pct
DEFAULT_BOOMS_RADAR_PCT                   = 10  # out of default_removable_pct
DEFAULT_DART_PCT                          = 10  # out of default_removable_pct
DEFAULT_LIFE_ITEM_PCT                     = 1   # out of default_removable_pct
DEFAULT_BOOM_SHIELD_ITEM_PCT              = 2   # out of default_removable_pct
DEFAULT_SPRING_ITEM_PCT                   = 2   # out of default_removable_pct
DEFAULT_BACKGROUND_IMG_PATH               = "./images/background/black.png"
DEFAULT_REMOVABLE_OBSTACLE_EXPLOSION_TYPE = "1" # "1"  : maximum 1 soft stone(in a series of adjacent stones) exploded at a time regardless of boom length
                                                # "1+" : depending on boom length, any number of adjacent soft stones can be exploded
DEFAULT_MAX_LEVEL                         = 16
class Map
    attr_reader :background_img, :map_items, :screen_w, :screen_h, :tile_w, :tile_h, :window, :level
    attr_accessor :obstacles, :opponent_players, :empty_positions, :players, :summon_boss

    def initialize(players, tile_w, tile_h, screen_w, screen_h, window, type = "solo", level = 1)
        @window              = window
        @screen_w, @screen_h = screen_w, screen_h
        @tile_w, @tile_h     = tile_w, tile_h
        @players             = players
        @background_img      = Gosu::Image.new(DEFAULT_BACKGROUND_IMG_PATH, :tileable => true)
        @level               = level
        @obstacles, @empty_positions, @opponent_players, @map_items = [], [], [], []
        generate_map(type)
    end

    # returns all obstacles on the map
    def obstacles
        irremovable_obstacles + removable_obstacles
    end
    
    # obstacles that can NOT be destroy even when exposing to an exploded boom
    def irremovable_obstacles
        [
            self.hard_stones
        ].flatten
    end

    # obstacles that can be destroy when exposing to an exploded boom
    def removable_obstacles
        [
            self.player_booms,
            self.pirate_boss_booms,
            self.soft_stones
        ].flatten
    end

    # update the map based on current level
    def update_map
        case @level
        when 1  ; PirateBossMapLevel1.new(self).generate_level_1_moves
        when 2  ; PirateBossMapLevel2.new(self).generate_level_2_moves
        when 3  ; PirateBossMapLevel3.new(self).generate_level_3_moves
        when 4  ; PirateBossMapLevel4.new(self).generate_level_4_moves
        when 5  ; PirateBossMapLevel5.new(self).generate_level_5_moves
        when 6  ; PirateBossMapLevel6.new(self).generate_level_6_moves
        when 7  ; PirateBossMapLevel7.new(self).generate_level_7_moves
        when 8  ; PirateBossMapLevel8.new(self).generate_level_8_moves
        when 9  ; PirateBossMapLevel9.new(self).generate_level_9_moves
        when 10 ; PirateBossMapLevel10.new(self).generate_level_10_moves
        when 11 ; PirateBossMapLevel11.new(self).generate_level_11_moves
        when 12 ; PirateBossMapLevel12.new(self).generate_level_12_moves 
        when 13 ; PirateBossMapLevel13.new(self).generate_level_13_moves
        when 14 ; PirateBossMapLevel14.new(self).generate_level_14_moves
        when 15 ; PirateBossMapLevel15.new(self).generate_level_15_moves
        when 16 ; PirateBossMapLevel16.new(self).generate_level_16_moves
        end
    end

    # draws current map
    def draw_map
        self.draw(
            @obstacles,             
            @map_items.select { |item| item.life_count == 1 },
            @opponent_players
        )

        # draws hidden items under removable obstacles when item_radar is used by any of the player
        items_radar_in_use = @players.any? { |player| player.items[player.items_radar_key].in_use?(player, player.items_radar_key) }
        if items_radar_in_use
            self.draw(
                @map_items.select { |item| item.life_count == 1 || close_to_players(item)[0] }
            )
        end
    end

    # remove 1 removable obstacle
    def remove_obstacle(obstacle)
        @obstacles.delete(obstacle)
    end

    # remove an item
    def remove_item(item)
        @map_items.delete(item)
    end

    # remove an opponent(pirate)
    def remove_opponent(opponent)
        @opponent_players.delete(opponent)
    end

    # reuturns the allowed explosion type of removable obstacles
    def removable_obstacle_explosion_type
        DEFAULT_REMOVABLE_OBSTACLE_EXPLOSION_TYPE
    end

    # based on obstacle type percentage, return true if obstacle is removable; false otherwise: 10% irremovable ---> "false"  ;  20% irremovable ---> "true"  ;  70% nothing ---> "nil" 
    def removable?(irremovable_pct = DEFAULT_IRREMOVEABLE_PCT, removable_pct = DEFAULT_REMOVEABLE_PCT)
        rand_num = rand(100)
        rand_num < irremovable_pct ? false : (rand_num < (irremovable_pct + removable_pct) ? true : nil)
    end

    # add an obstacle onto the map
    def add_obstacle(obstacle)
        @obstacles << obstacle
    end

    # returns true if the given item is close to the player, within radius factor
    def close_to_players(item, factor = 1)
        points_close_to_b(@players.select { |player| !player.disable? }, item, factor)
    end

    # generate items based on given item_positions and their life count(1 == visible, 2 == hidden)
    def generate_items(item_positions, life_count)
        generate_random_items(item_positions, life_count)
    end

    # returns all empty positions on map(positions that do not already have obstacles)
    def generate_empty_positions
        all_obstacle_positions = obstacles.map { |obstacle| [obstacle.x, obstacle.y] }

        x, y = 0, 0
        while x < @screen_w
            while y < @screen_h
                @empty_positions << [x, y] if !all_obstacle_positions.include?([x, y])
                y += @tile_h
            end

            x += @tile_w ; y = 0
        end
    end

    def max_level
        DEFAULT_MAX_LEVEL
    end

    # puts players randomly into empty positions
    def generate_random_player_positions
        @players.each do |player|
            x, y     = @empty_positions.sample
            player.x = x
            player.y = y
        end
    end
    
private
    # returns an array of all booms from all players(excluding boss)
    def player_booms
        @players.map { |player| player.booms }
    end

    # returns an array of all boss booms
    def pirate_boss_booms
        boss = @opponent_players.select { |opponent| opponent.is_a?(PirateBoss) }.first
        boss.nil? ? [] : boss.booms
    end

    # returns an array of all items on the map
    def items
        @map_items
    end

    # generate a map based on current level
    def generate_map(type)
        @window.caption = "Boom Online --- Level #{@level <= 9 ? 0 : ""}#{@level}"

        case type
        when "solo" ; generate_random_obstacles ; generate_random_player_positions
        when "team" # fight boss
            case @level
            when 1  ; PirateBossMapLevel1.new(self).generate_level_1_map
            when 2  ; PirateBossMapLevel2.new(self).generate_level_2_map  
            when 3  ; PirateBossMapLevel3.new(self).generate_level_3_map  
            when 4  ; PirateBossMapLevel4.new(self).generate_level_4_map  
            when 5  ; PirateBossMapLevel5.new(self).generate_level_5_map  
            when 6  ; PirateBossMapLevel6.new(self).generate_level_6_map  
            when 7  ; PirateBossMapLevel7.new(self).generate_level_7_map  
            when 8  ; PirateBossMapLevel8.new(self).generate_level_8_map  
            when 9  ; PirateBossMapLevel9.new(self).generate_level_9_map  
            when 10 ; PirateBossMapLevel10.new(self).generate_level_10_map
            when 11 ; PirateBossMapLevel11.new(self).generate_level_11_map
            when 12 ; PirateBossMapLevel12.new(self).generate_level_12_map
            when 13 ; PirateBossMapLevel13.new(self).generate_level_13_map
            when 14 ; PirateBossMapLevel14.new(self).generate_level_14_map
            when 15 ; PirateBossMapLevel15.new(self).generate_level_15_map
            when 16 ; PirateBossMapLevel16.new(self).generate_level_16_map
            end
        end

        generate_random_items
    end

    # returns an array of irremovable obstacles
    def hard_stones
        @obstacles.select { |obstacle| !obstacle.removable }
    end

    # returns an array of removable obstacles
    def soft_stones
        @obstacles.select { |obstacle| obstacle.removable }
    end

    # randomly generate obstacles based on their generated percentage
    def generate_random_obstacles
        x = 0
        while x + @tile_w <= @screen_w

            y = 0
            while y + @tile_h <= @screen_h
                is_removable = self.removable?
                if !is_removable.nil?
                    @obstacles << Obstacle.new(x, y, is_removable) 
                else
                    @empty_positions << [x, y]
                end

                y += @tile_h
            end

            x += @tile_w
        end
    end

    # puts items randomly onto the map
    def generate_random_items(locations = soft_stones, life_count = 2)
        locations.each do |obstacle|
            x, y = (life_count == 2 ? [obstacle.x, obstacle.y] : obstacle)
            rand_num = rand(100)
            tot_pct  = items.inject(0) { |accumulator, (item_pct, item_name)| accumulator + item_pct }
            curr_pct = items.first.first

            items.each_with_index do |(item_pct, item_name), i|
                break if rand_num > tot_pct

                if rand_num < curr_pct
                    @map_items << MapItem.new(x, y, item_name, life_count)
                    break
                else  # add pct of next item
                    curr_pct += items[i + 1][0] if i != items.length - 1
                end
            end
        end
    end

    # draw whole map
    def draw(*arrs)
        arrs.each { |arr| arr.each { |element| element.is_a?(PirateBoss) ? element.draw(@players, self) : element.draw } }
    end

    # returns an array of item names and their percentage of being generated
    def items
        [
            [DEFAULT_EXTRA_BOOM_ITEM_PCT , "extra_boom" ],
            [DEFAULT_SPEED_ITEM_PCT      , "speed"      ],
            [DEFAULT_BOOM_LENGTH_ITEM_PCT, "boom_length"],
            [DEFAULT_ITEMS_RADAR_PCT     , "items_radar"],
            [DEFAULT_BOOMS_RADAR_PCT     , "booms_radar"],
            [DEFAULT_DART_PCT            , "dart"       ],
            [DEFAULT_LIFE_ITEM_PCT       , "life"       ],
            [DEFAULT_BOOM_SHIELD_ITEM_PCT, "boom_shield"],
            [DEFAULT_SPRING_ITEM_PCT     , "spring"     ]
        ]
    end
    
    # returns true of the given points are closed to point b wihtin radius factor
    def points_close_to_b(points, b, factor)  #how close? factor = 1 means adjacent, 2 means 1 tile away, and so on
        points.each do |point|
            l = point.x.between?((b.x - (b.width * factor)), b.x                      )
            r = point.x.between?( b.x                      , b.x + (b.width * factor ))
            u = point.y.between?( b.y - (b.height * factor), b.y                      )
            d = point.y.between?( b.y                      , b.y + (b.height * factor))

            close_to_left   = l && (b.y.between?(point.y, point.y + o_y) || point.y.between?(b.y, b.y + o_y))
            close_to_right  = r && (b.y.between?(point.y, point.y + o_y) || point.y.between?(b.y, b.y + o_y))
            close_to_top    = u && (b.x.between?(point.x, point.x + o_x) || point.x.between?(b.x, b.x + o_x))
            close_to_bottom = d && (b.x.between?(point.x, point.x + o_x) || point.x.between?(b.x, b.x + o_x))

            if    close_to_left   ; return [true , "l"]
            elsif close_to_right  ; return [true , "r"]
            elsif close_to_top    ; return [true , "u"]
            elsif close_to_bottom ; return [true , "d"]
            end
        end

        [false, nil]
    end

    # returns allowed offset x
    def o_x
        DEFAULT_OFFSET_X
    end

    # returns allowed offset y
    def o_y
        DEFAULT_OFFSET_Y
    end
end
