require_relative 'player'

DEFAULT_BOOMS_RADAR_EFFECT_IMG_PATH = "./images/items/booms_radar_effect.png"
DEFAULT_DART_FLYING_LEFT_IMG_PATH   = "./images/items/dart_left.png"
DEFAULT_DART_FLYING_RIGHT_IMG_PATH  = "./images/items/dart_right.png"
DEFAULT_DART_FLYING_UP_IMG_PATH     = "./images/items/dart_up.png"
DEFAULT_DART_FLYING_DOWN_IMG_PATH   = "./images/items/dart_down.png"

class PlayerItem
    attr_reader :name, :image, :quantity, :default_use_time, :color_map
    attr_accessor :quantity, :is_activate, :time_since_activate

    def initialize(name, img_path, time = nil)
        @is_activate        = false
        @default_use_time   = time
        @name               = name
        @image              = Gosu::Image.new(img_path, :tileable => true)
        @arc_pct            = (0..10).to_a.map { |i| i / 10.0 }
        @curr_arc_pct       = 0
        @color_map          =   {
                                    "green"  => Gosu::Color::GREEN  ,
                                    "red"    => Gosu::Color::RED    ,
                                    "yellow" => Gosu::Color::YELLOW ,
                                    "pink"   => Gosu::Color::FUCHSIA,
                                    "blue"   => Gosu::Color::AQUA   ,
                                    "white"  => Gosu::Color::WHITE
                                }
    end

    # returns width of item
    def width
        @image.width
    end

    # returns height of item
    def height
        @image.height
    end

    # draws item at [x, y, z] position
    def draw(x, y, z)
        @image.draw(x, y, z)
    end

    # draws item effect if it has one
    def draw_effect(player, players, map, direction)
        if !default_use_time.nil?   # only for items that have effect(ex: boom_shield)
            case @name
            when "life"
            when "boom_shield" ; self.draw_boom_shield_effect(player)
            when "spring"
            when "items_radar"
            when "booms_radar" ; self.draw_booms_radar_effect(players, map)
            when "dart"        ; self.draw_dart_effect(player, players, direction)
            end
        end
    end

    # keeps track of when item is being activated
    def set_timer
        @time_since_activate = Gosu.milliseconds
    end

    # returns true if item is still IN USE; false otherwise
    def in_use?(player, item_key)
        if !@default_use_time.nil?      # only for items that have effect
            if @is_activate && player.items_quantity[item_key] > 0
                if @time_since_activate.nil?
                    self.set_timer 
                    player.decrement_items(item_key) if @name != "dart"
                end
            elsif time_is_up
                @time_since_activate = nil
                @curr_dart_position, @dart_direction = nil, nil
            end

            !@time_since_activate.nil?  # the shield is in use IF AND ONLY IF the @time_since_activate is NOT NIL
        else
            false
        end
    end

private
    # returns true if use time of item is up; false otherwise
    def time_is_up
        !@time_since_activate.nil? && Gosu.milliseconds - @time_since_activate > @default_use_time
    end

    # draw dart effect(by updating its position) when it is flying through the screen
    def draw_dart_effect(player, players, direction)
        if !@curr_dart_position.nil? && !@dart_direction.nil?
            x, y = @curr_dart_position

            case @dart_direction
            when "l" ; x -= width  ; dart_img = Gosu::Image.new(DEFAULT_DART_FLYING_LEFT_IMG_PATH , :tileable => true)
            when "r" ; x += width  ; dart_img = Gosu::Image.new(DEFAULT_DART_FLYING_RIGHT_IMG_PATH, :tileable => true)
            when "u" ; y -= height ; dart_img = Gosu::Image.new(DEFAULT_DART_FLYING_UP_IMG_PATH   , :tileable => true)
            when "d" ; y += height ; dart_img = Gosu::Image.new(DEFAULT_DART_FLYING_DOWN_IMG_PATH , :tileable => true)
            end

            # check all booms on the map(including boss booms), and explode them immediately if dart touches the boom
            players.each do |player| 
                player.booms.each do |boom|
                    if (x + player.o_x).between?(boom.x, boom.x + boom.width) && (y + player.o_y).between?(boom.y, boom.y + boom.height) # touch boom
                        boom.explode_now    = true 
                        @curr_dart_position = nil
                        @dart_direction     = nil
                        break
                    end
                end
            end

            @curr_dart_position = [x, y]
            dart_img.draw(x, y, 0)
        else
            if !direction.nil?
                @curr_dart_position = [player.x, player.y]
                @dart_direction     = direction
                player.decrement_items(player.dart_key)
            end
        end
    end

    # draws a moving circular effect based on player's color, if color not available, choose random colors
    def draw_boom_shield_effect(player)
        if player.is_a?(Player)
            pct   = @arc_pct[@curr_arc_pct]
            color = (@color_map.has_key?(player.name) ? @color_map[player.name] : @color_map[@color_map.keys.sample])
            Gosu.draw_arc(player.x + (player.width / 2), player.y + ((player.height / 2) - 5), 30, pct, 128, 8, {from: color, to: Gosu::Color::WHITE}, 0, :default)
        end
            @curr_arc_pct = (@curr_arc_pct + 1) % @arc_pct.length
    end

    # draws the exploding path of all booms when it is planted(prior to exploding)
    def draw_booms_radar_effect(players, map)
        radar_img = Gosu::Image.new(DEFAULT_BOOMS_RADAR_EFFECT_IMG_PATH, :tileable => true)

        players.each do |player|
            player.booms.each do |boom|
                next if boom.explode_now
                n = player.boom_length * 2 + 1
                draw_boom_radar_effect(boom, radar_img, n, boom.width, 0          , map)
                draw_boom_radar_effect(boom, radar_img, n, 0         , boom.height, map)
            end
        end
    end

    # draws the exploding path of 1 boom when it is planted(prior to exploding)
    def draw_boom_radar_effect(boom, radar_img, n, w, h, map)
        draw_boom_radar_effect_part(boom, radar_img, n, w, h, map, "first half")
        draw_boom_radar_effect_part(boom, radar_img, n, w, h, map, "middle")
        draw_boom_radar_effect_part(boom, radar_img, n, w, h, map, "second half")
    end

    # draws a part of the exploding path of the boom
    def draw_boom_radar_effect_part(boom, radar_img, n, w, h, map, which_part)
        x, y       = boom.x, boom.y
        break_next = false

        (n / 2).times do
            case which_part
            when "middle"
            when "first half"  ; x -= w ; y -= h
            when "second half" ; x += w ; y += h
            end

            break if map.irremovable_obstacles.any? { |obstacle| obstacle.touch?(x, y) } # stop if touch wall(irremovable obstacle)
            break if break_next
            radar_img.draw(x, y, 0)

            case map.removable_obstacle_explosion_type
            when "1+"
            when "1"  ; map.removable_obstacles.each { |obstacle| break_next = true if obstacle.is_a?(Obstacle) && obstacle.touch?(x, y) }
            end
        end
    end
end
