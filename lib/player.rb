require_relative 'boom'
require_relative 'player_item'
require_relative 'character'

DEFAULT_DYING_BUBBLE_IMG    = "./images/characters/bubble.png"
DEFAULT_DYING_STATE_1_TIME  = 3_000   # 3 seconds        ---> savable
DEFAULT_SPEED_WHEN_GET_BOOM = 1
DEFAULT_MOVE_OFFSET_FACTOR  = 6 

class Player
    attr_accessor   :l, :r, :u, :d, :b, :l_key, :r_key, :u_key, :d_key, :b_key, :life_key, :boom_shield_key, :spring_key, :items_radar_key, :booms_radar_key, :dart_key,
                    :x, :y, :speed, :got_boom, :team_id, :normal_image, :boom_image, :curr_boom_quantity, :boom_length, :items, :items_quantity, :name, :booms
    
    def initialize
        @bubble_image                   = Gosu::Image.new(DEFAULT_DYING_BUBBLE_IMG, :tileable => true)
        @l, @r, @u, @d, @b, @got_boom   = false, false, false, false, false, false
        @booms, @items, @items_quantity = [], {}, {}
        @curr_direction                 = nil
    end

    # plants a boom at the position of the player
    def plant_boom(players, (x, y), walls)
        all_booms = players.map { |player| player.booms }.flatten
        if self.none_obstacles_overlap?(x, y, all_booms, walls)
            @booms << Boom.new(x, y, self)
        end
    end

    # return true if all obstacles are NOT overlapping with this player position
    def none_obstacles_overlap?(x, y, *obstacle_arrays)
        obstacle_arrays.all? { |obstacles| obstacles.none? { |obstacle| self.obstacle_overlap?(x, y, obstacle) } }
    end

    # return true if the given obstacle(ex:boom) is overlapped with the player's position
    def obstacle_overlap?(x, y, obstacle)
        x == obstacle.x && y == obstacle.y
    end
    
    # reurns a list of booms that planted by the player
    def booms
        @booms
    end

    # removes a boom from the player boom's list after the boom is exploded
    def remove_boom(boom)
        @booms.delete(boom)
    end

    # total numbers of booms that a player can plant at once. If used up, needs to wait until a boom is exploded before can plant again
    def num_booms_allowed
        @curr_boom_quantity
    end 

    # player is in dying state -> set timer
    def dying
        @time_since_got_boom = Gosu.milliseconds
    end

    def dead
        @time_since_got_boom = -DEFAULT_DYING_STATE_1_TIME
    end

    # returns true if player is dead; false otherwise
    def dead?
        Gosu.milliseconds - @time_since_got_boom >= DEFAULT_DYING_STATE_1_TIME
    end

    # the player is eliminated from the game ---> disable all functions
    def disable?
        self.dying? && self.dead?
    end

    # return true if player is dying(inside bubble); false otherwise
    def dying?
        !@time_since_got_boom.nil?
    end

    # returns the correct combination of images of the player to display onto the screen depending on the current state of the player
    def images(players)
        allies, enemies = [], []
        players.each { |player| (player.team_id == self.team_id ? allies << player : enemies << player) if !player.disable? && !player.dying? && player != self }

        if @got_boom
            if !dying?
                self.dying
            elsif self.dead?
                return nil
            elsif self.is_kill_by?(enemies)
                self.dead
            elsif self.is_save_by?(allies) || self.use_life
                self.decrement_items(@life_key) if self.use_life
                self.reset_to_normal_state
                return [@normal_image]
            end

            [@normal_image, @bubble_image]
        else
            [@normal_image]
        end
    end

    # returns true if there is an obstacle to the "drection"(left/right/up/down) of the player
    def obstacle?(obstacles, direction, x = @x, y = @y)
        case direction
        when "l" ; obstacles.any? { |obstacle| x == (obstacle.x + obstacle.width)  &&  (y.between?(obstacle.y, obstacle.y + obstacle.height - o_y) || (y + self.height - o_y).between?(obstacle.y, obstacle.y + obstacle.height)) }
        when "r" ; obstacles.any? { |obstacle| (x + self.width)  == obstacle.x     &&  (y.between?(obstacle.y, obstacle.y + obstacle.height - o_y) || (y + self.height - o_y).between?(obstacle.y, obstacle.y + obstacle.height)) }
        when "u" ; obstacles.any? { |obstacle| (y == obstacle.y + obstacle.height) &&  (x.between?(obstacle.x, obstacle.x + obstacle.width  - o_x) || (x + self.width  - o_x).between?(obstacle.x, obstacle.x + obstacle.width))  }
        when "d" ; obstacles.any? { |obstacle| (y + self.height) == obstacle.y     &&  (x.between?(obstacle.x, obstacle.x + obstacle.width  - o_x) || (x + self.width  - o_x).between?(obstacle.x, obstacle.x + obstacle.width))  }
        end
    end
    
    # returns true if the player is in the position of any given object(ex: boom - that can lead to "dying" state)
    def overlap_with?(x, w, y, h)
        x_overlap?(x, w) && y_overlap?(y, h)
    end

    # draw player's profile and his/her items
    def draw_profile(x_offset, y_offset)
        # draw player profile
        draw_gray_background(x_offset, y_offset, self.width, self.height) if self.disable?
        @normal_image.draw(x_offset, y_offset, 0)

        # update x_offset to draw player's items
        x_offset += self.width

        @items.each do |item_key, item|
            self.draw_gray_background(x_offset, y_offset, item.width, item.height) if self.items_quantity[item_key] <= 0
            item.draw(x_offset, y_offset, 0)
            
            item_quantity = @items_quantity[item_key]   # draws the item quantity
            Character.new.symbols["small_#{item_quantity < 10 ? item_quantity : "x"}"].draw(x_offset + 40, y_offset + 40) if item_quantity > 0

            x_offset += item.width
        end

        x_offset
    end

    # draw player's moving effect based on player's moving directinoa and color
    def draw_moving_effect(direction)
        effect_length = 5 * @speed
        distance      = (1..10).to_a.map { |n| n * 5 }

        case direction
        when "l" ; distance.each { |dist| Gosu.draw_line(@x + width, @y + dist  , color_map, @x + width + effect_length, @y + dist                  , Gosu::Color::WHITE) }
        when "r" ; distance.each { |dist| Gosu.draw_line(@x        , @y + dist  , color_map, @x - effect_length        , @y + dist                  , Gosu::Color::WHITE) }
        when "u" ; distance.each { |dist| Gosu.draw_line(@x + dist , @y + height, color_map, @x + dist                 , @y + height + effect_length, Gosu::Color::WHITE) }
        when "d" ; distance.each { |dist| Gosu.draw_line(@x + dist , @y         , color_map, @x + dist                 , @y - effect_length         , Gosu::Color::WHITE) }
        end
    end

    # decrement item's quantity by 1
    def decrement_items(key)
        @items_quantity[key] -= 1
    end

    # return the speed based on player's current state
    def calculate_speed(obstacles, direction, window)
        return DEFAULT_SPEED_WHEN_GET_BOOM if @got_boom

        x, y = @x, @y
        dist = 0
        while !self.obstacle?(obstacles, direction, x, y) && dist <= @speed && (
                (direction == "l" && window.within_hor_frame?(x))          ||
                (direction == "r" && window.within_hor_frame?(x + width))  ||
                (direction == "u" && window.within_ver_frame?(y))          ||
                (direction == "d" && window.within_ver_frame?(y + height))
            )
            
            case direction
            when "l" ; x -= 1 ; dist = @x -  x
            when "r" ; x += 1 ; dist =  x - @x
            when "u" ; y -= 1 ; dist = @y -  y
            when "d" ; y += 1 ; dist =  y - @y
            end
        end

        dist
    end

    # make a move based on current direction and obstacles
    def move(direction, obstacles, window)
        if @curr_direction.nil?
            @curr_direction = direction 
        elsif @curr_direction != direction
            @x, @y = window.get_closet_tile_coor(@x, @y)
            @curr_direction = direction
        end

        speed = (obstacle?(obstacles, direction) ? jump_distance(obstacles, direction, window.screen_w, window.screen_h) : calculate_speed(obstacles, direction, window))
        case direction
        when "l" ; @x -= speed
        when "r" ; @x += speed
        when "u" ; @y -= speed
        when "d" ; @y += speed
        end
    end

    # returns true if player is allowed to plant a boom; false otherwise
    def plantable?
        !@got_boom && (@booms.length < self.num_booms_allowed)
    end

    # calcualte the jump distance over n irremovable obstacles ; do not jump if there is no empty position at the destination
    def jump_distance(obstacles, direction, screen_w, screen_h)
        return 0 if !@items[@spring_key].is_activate || @items_quantity[@spring_key] <= 0
        
        curr_x, curr_y = @x, @y
        obstacle = 0                # random value to enter the while loop
        distance = nil

        while !obstacle.nil?
            case direction
            when "l"
                obstacle  = obstacles.find { |obstacle| curr_x == (obstacle.x + obstacle.width)  &&  (curr_y.between?(obstacle.y, obstacle.y + obstacle.height - o_y) || (curr_y + self.height - o_y).between?(obstacle.y, obstacle.y + obstacle.height)) }
                curr_x    = obstacle.x if !obstacle.nil?
            when "r"
                obstacle  = obstacles.find { |obstacle| (curr_x + self.width)  == obstacle.x     &&  (curr_y.between?(obstacle.y, obstacle.y + obstacle.height - o_y) || (curr_y + self.height - o_y).between?(obstacle.y, obstacle.y + obstacle.height)) }
                curr_x    = obstacle.x if !obstacle.nil?
            when "u"
                obstacle  = obstacles.find { |obstacle| (curr_y == obstacle.y + obstacle.height) &&  (curr_x.between?(obstacle.x, obstacle.x + obstacle.width  - o_x) || (curr_x + self.width  - o_x).between?(obstacle.x, obstacle.x + obstacle.width))  }
                curr_y    = obstacle.y if !obstacle.nil?
            when "d"
                obstacle  = obstacles.find { |obstacle| (curr_y + self.height) == obstacle.y     && (curr_x.between?(obstacle.x, obstacle.x + obstacle.width  - o_x) || (curr_x + self.width  - o_x).between?(obstacle.x, obstacle.x + obstacle.width)) }
                curr_y    = obstacle.y if !obstacle.nil?
            end
        end

        case direction
        when "l"
            return 0 if curr_x < self.width
            distance = @x - curr_x + self.width
        when "r"
            return 0 if curr_x + self.width > screen_w - 1
            distance = curr_x - @x + self.width
        when "u"
            return 0 if curr_y < self.height
            distance = @y - curr_y + self.height
        when "d"
            return 0 if curr_y + self.height > screen_h - 1
            distance = curr_y - @y + self.height
        end

        @items[@spring_key].is_activate = false
        self.decrement_items(@spring_key)
        distance
    end

    # player's normal image width
    def width
        @normal_image.width
    end

    # player's normal image height
    def height
        @normal_image.height
    end

    # at high speed, it's hard for human player to move thru 2 walls ---> needs a little offset
    # allowed offset x
    def o_x
        self.width  / DEFAULT_MOVE_OFFSET_FACTOR
    end

    # allow offset y
    def o_y
        self.height / DEFAULT_MOVE_OFFSET_FACTOR
    end

    # reset variables to normal state
    def reset_to_normal_state
        @time_since_got_boom = nil
        @got_boom            = false
    end
private
    # draw a gray rectangle based on given dimensions and coordinates
    def draw_gray_background(x, y, w, h)
        Gosu.draw_rect(x, y, w, h, Gosu::Color::GRAY)
    end
  
    # returns true if object(ex: boom) overlaps with half of the player's body; false otherwise
    def x_overlap?(x, w)
        ((@x + o_x).between?(x, x + w)               && (@x + o_x + (self.width / 2)).between?(x, x + w)) ||
        ((@x + (self.width / 2)).between?(x, x + w)) && (@x + self.width).between?(x, x + w)
    end

    # returns true if object(ex: boom) overlaps with the last point of player's height(leg)
    def y_overlap?(y, h)
        (@y + self.height - o_y).between?(y, y + h)
    end

    # get out of water boom using life key
    def use_life
        @items[@life_key].is_activate && @items_quantity[@life_key] > 0
    end

    # returns true if the current player is saved by his/her allies
    def is_save_by?(players)
        players.any? { |player| self.x_overlap?(player.x, player.width) && self.y_overlap?(player.y, player.height) }
    end

    # returns the color map in PlayerItem class
    def color_map
        colormap = @items[@items.keys.first].color_map
        colormap[name].nil? ? colormap[colormap.keys.sample] : colormap[name]
    end

    alias_method :is_kill_by?, :is_save_by?
end
