require_relative 'player'
require_relative 'sound'

DEFAULT_TIME_TO_EXPLODE             = 3_000     # 3 seconds
DEFAULT_TIME_TO_FINISH_EXPLODING    = 1_000     # 1 second
DEFAULT_EXPLODE_H_IMG_PATH          = "./images/booms/explode_h.png"
DEFAULT_EXPLODE_V_IMG_PATH          = "./images/booms/explode_v.png"

class Boom
    attr_reader :x, :y
    attr_accessor :explode_now

    def initialize(x, y, player)
        @x, @y              = x, y
        @images             = [
            player.boom_image                                             , # normal boom before explode
            Gosu::Image.new(DEFAULT_EXPLODE_H_IMG_PATH, :tileable => true), # image of boom exploding in horizontal direction
            Gosu::Image.new(DEFAULT_EXPLODE_V_IMG_PATH, :tileable => true)  # image of boom exploding in vertical   direction
        ]
        @curr_imgages       = [@images[0]]
        @state              = 0                     # 0: normal state ; 1: exploding state
        @time_since_planted = Gosu.milliseconds     # track time to explode the boom
        @explode_now        = false
        Sound.new.plant_boom.play(volume = 1)
    end

    # returns true if it is time for the boom to explode(after planted for a while), false otherwise
    def time_to_explode?
        result       = @explode_now || (Gosu.milliseconds - @time_since_planted >= DEFAULT_TIME_TO_EXPLODE)
        @explode_now = false if @explode_now
        result
    end
    
    # returns true if boom finished exploding, false otherwise
    def finish_explode?
        Gosu.milliseconds - @time_since_exploded >= DEFAULT_TIME_TO_FINISH_EXPLODING
    end

    # action to "explode" the boom
    def explode
        @curr_imgages           = [@images[1], @images[2]]  # updating combination of boom images
        @time_since_exploded    = Gosu.milliseconds         # set timer
    end

    # returns the correct combinations of images to display the boom onto the screen. Returns nil if boom is already exploded (nothing to display)
    def images
        self.explode if self.time_to_explode? && @time_since_exploded.nil?      # make sure not yet exploded
        (@time_since_exploded.nil? || !finish_explode?) ? @curr_imgages : nil
    end

    # returns the width of the boom
    def width
        @images.first.width
    end

    # returns the height of the boom
    def height
        @images.first.height
    end

    # returns true if this boom is "touching" this object(other boom) from any direction
    def touch?(x, y)
        @x == x && @y == y
    end

    # draw a boom
    def draw(all_booms, player, players, map)
        boom_images = self.images
        if !boom_images.nil?
            if boom_images.length == 1
                self.draw_boom(  # normal boom
                    2                           ,
                    boom_images.first           ,
                    0                           ,
                    0                           ,
                    []                          ,
                    players                     ,
                    map
                )
            elsif boom_images.length == 2
                self.draw_boom(  # horizontal
                    player.boom_length * 2 + 1  ,
                    boom_images[0]              ,
                    boom_images[0].width        , 
                    0                           ,
                    all_booms                   ,
                    players                     , 
                    map
                )
                self.draw_boom(  # verticcal
                    player.boom_length * 2 + 1  ,
                    boom_images[1]              ,
                    0                           ,
                    boom_images[1].height       ,
                    all_booms                   , 
                    players                     , 
                    map
                )
            end
        else
            player.remove_boom(self)

            map.map_items.each do |item|        # only decrement life of item when boom is finished exploding, bc it takes several cycles to draw complete boom's length => thus touch item servera; times
                if item.touch_boom              # and we do not want to count false positive
                    item.life_count  -= 1
                    item.touch_boom = false
                end

                map.remove_item(item) if item.life_count == 1 && item.touch_boom
            end

            case map.removable_obstacle_explosion_type
            when "1+"
            when "1"
                # only want to remove the soft stone once the boom finished exploding, if we remove it in draw_part(),
                # it will be deleted several times(other soft stones) due to several draw_part() calls
                map.removable_obstacles.each { |obstacle| map.remove_obstacle(obstacle) if obstacle.is_a?(Obstacle) && obstacle.touch_boom }
            end

            # decrement boss life count after it got boomed
            map.opponent_players.each do |opponent|
                if opponent.is_a?(PirateBoss)
                    if opponent.life_count > 0 && opponent.got_boom
                        opponent.life_count -= 1
                        opponent.got_boom = false
                    end
                end
            end

            Sound.new.boom_explode.play(volume = 0.5)
        end
    end

    # draw a boom based on given state
    def draw_boom(n, img, w, h, booms, players, map)
        draw_part(n, img, w, h, booms, players, map, "first half")
        draw_part(n, img, w, h, booms, players, map, "middle")
        draw_part(n, img, w, h, booms, players, map, "second half")
    end

    # draw part of a boom and updates: 1) domino effect when boom explodes ; 2) map_items states(destroy/reveal) ; 3) players state(when exposed to an exploded boom) ; 4) removable obstacles state(disappear if got boomed)
    def draw_part(n, img, w, h, booms, players, map, which_part)
        x, y             = @x, @y
        boom_is_exploded = n != 2
        break_next       = false

        (n / 2).times do
            case which_part
            when "middle"
            when "first half"  ; x -= w ; y -= h
            when "second half" ; x += w ; y += h
            end

            break if map.irremovable_obstacles.any? { |obstacle| obstacle.touch?(x, y) } # stop if touch wall(irremovable obstacle)
            break if break_next

            img.draw(x, y, 0)
            booms.each         { |boom  | boom.explode_now = true if boom.touch?(x, y) } # sets flag if current boom is exploded and touch other booms
            map.map_items.each { |item  | item.touch_boom  = true if item.touch?(x, y) } # sets flag if current boom is exploded and touch revealed items

            players.each do |player|                                                     # sets flags if player got exposed to an exploded boom
                if boom_is_exploded
                    if    player.is_a?(Player)      ; player.got_boom = true      if !player.got_boom && player.overlap_with?(x, self.width, y, self.height) && !player.items[player.boom_shield_key].in_use?(player, player.boom_shield_key)
                    elsif player.is_a?(PirateBoss)  ; player.got_boom = true      if player.touch?(x + o_x, y + o_y)
                    elsif player.is_a?(PirateSlave) ; map.remove_opponent(player) if player.touch?(x + o_x, y + o_y)
                    end
                end
            end

            case map.removable_obstacle_explosion_type                                   # set flag to stop an exploding boom based on removable explosion type
            when "1+"
                map.removable_obstacles.each { |obstacle| map.remove_obstacle(obstacle) if obstacle.is_a?(Obstacle) && obstacle.touch?(x, y) }
            when "1"
                map.removable_obstacles.each do |obstacle|
                    if obstacle.is_a?(Obstacle) && obstacle.touch?(x, y)
                        obstacle.touch_boom = true
                        break_next          = true
                    end
                end
            end
        end
    end

    # allow offset x
    def o_x
        width  / DEFAULT_MOVE_OFFSET_FACTOR
    end

    # allow offset y
    def o_y
        height / DEFAULT_MOVE_OFFSET_FACTOR
    end
end
