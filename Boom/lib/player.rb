require_relative 'boom'

DEFAULT_X_COOR             = 0
DEFAULT_Y_COOR             = 0
DEFAULT_SPEED              = 2
DEFAULT_BOOM_QUANTITY      = 20
DEFAULT_DYING_BUBBLE_IMG   = "./images/characters/bubble.png"
DEFAULT_DYING_STATE_1_TIME = 3_000   # 3 seconds        ---> savable
DEFAULT_DYING_STATE_2_TIME = 0_500   # 0.5 second       ---> NOT savable, time lasts before disaappear entirely
DEFAULT_SLOW_DOWN_FACTOR   = 10
class Player
    attr_accessor :x, :y, :speed, :l, :r, :u, :d, :b, :l_key, :r_key, :u_key, :d_key, :b_key, :got_boom
    attr_reader :normal_image

    def initialize(normal_img, l, r, u, d, b)
        @bubble_image                           = Gosu::Image.new(DEFAULT_DYING_BUBBLE_IMG, :tileable => true)
        @normal_image                           = Gosu::Image.new(normal_img, :tileable => true)
        @x, @y, @speed                          = DEFAULT_X_COOR, DEFAULT_Y_COOR, DEFAULT_SPEED
        @l, @r, @u, @d, @b                      = false, false, false, false, false
        @l_key, @r_key, @u_key, @d_key, @b_key  = l, r, u, d, b
        @booms, @allies, @enemies               = [], [], []
        @got_boom                               = false
    end

    def plant_boom
        # if      !self.obstacle_left?    ;   booms << Boom.new(self.x                          , self.y)
        # elsif   !self.obstacle_right?   ;   booms << Boom.new(self.x + self.normal_image.width, self.y)
        # elsif   !self.obstacle_up?      ;   booms << Boom.new(self.x                          , self.y - self.normal_image.height)
        # elsif   !self.obstacle_down?    ;   booms << Boom.new(self.x                          , self.y + self.normal_image.height)
        # end

        booms << Boom.new(self.x, self.y)
        sleep(0.15)                          # delay to avoid planting booms too fast ---> too many booms ended up at 1 place due to slow human reaction ---> bad bc not on purpose
    end

    def booms
        @booms
    end

    def remove_boom(boom)
        @booms.delete(boom)
    end

    def num_booms_allowed
        DEFAULT_BOOM_QUANTITY
    end 

    def dying
        @time_since_got_boom = Gosu.milliseconds
    end

    def dead?
        Gosu.milliseconds - @time_since_got_boom >= DEFAULT_DYING_STATE_1_TIME
    end

    def disable?
        !@time_since_got_boom.nil? && self.dead?
    end

    def images
        if @got_boom
            if @time_since_got_boom.nil?
                self.dying
            elsif self.dead?
                return nil
            end

            [@normal_image, @bubble_image]
        else
            [@normal_image]
        end
    end

    def overlap_with_boom?(x, boom_width, y, boom_height)
        x_overlap?(x, boom_width) && y_overlap?(y, boom_height)
    end

    def slow_down_factor
        DEFAULT_SLOW_DOWN_FACTOR
    end

    def obstacle_left?(players)
        players.map { |player| player.booms }.flatten.any? { |boom| @x == (boom.x + boom.width)                &&  @y.between?(boom.y, boom.y + boom.height) }
    end

    def obstacle_right?(players)
        players.map { |player| player.booms }.flatten.any? { |boom| (@x + self.normal_image.width)  == boom.x  &&  @y.between?(boom.y, boom.y + boom.height) }
    end

    def obstacle_up?(players)
        players.map { |player| player.booms }.flatten.any? { |boom| (@y == boom.y + boom.height)               &&  @x.between?(boom.x, boom.x + boom.width)  }
    end

    def obstacle_down?(players)
        players.map { |player| player.booms }.flatten.any? { |boom| (@y + self.normal_image.height) == boom.y  &&  @x.between?(boom.x, boom.x + boom.width)  }
    end

private
    def x_overlap?(x, boom_width)  #overlap with half of the player's body
        (@x.between?(x, x + boom_width)                                 &&  (@x + (@normal_image.width / 2)).between?(x, x + boom_width)) ||
        ((@x + (@normal_image.width / 2)).between?(x, x + boom_width))  &&  (@x + @normal_image.width).between?(x, x + boom_width)
    end

    def y_overlap?(y, boom_height)  #overlap with the last point of player's height(leg)
        (@y + @normal_image.height).between?(y, y + boom_height)
    end
end