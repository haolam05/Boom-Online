DEFAULT_TIME_TO_EXPLODE             = 3_000     # 3 seconds
DEFAULT_TIME_TO_FINISH_EXPLODING    = 1_000     # 1 second
DEFAULT_NORMAL_IMG_PATH             = "./images/booms/normal.png"
DEFAULT_EXPLODE_H_IMG_PATH          = "./images/booms/explode_h.png"
DEFAULT_EXPLODE_V_IMG_PATH          = "./images/booms/explode_v.png"
DEFAULT_BOOM_LENGTH                 = 1

class Boom
    attr_reader :x, :y
    attr_accessor :length, :explode_now

    def initialize(x, y)
        @x, @y              = x, y
        @images             = [
            Gosu::Image.new(DEFAULT_NORMAL_IMG_PATH, :tileable => true)   , # normal boom before explode
            Gosu::Image.new(DEFAULT_EXPLODE_H_IMG_PATH, :tileable => true), # image of boom exploding in horizontal direction
            Gosu::Image.new(DEFAULT_EXPLODE_V_IMG_PATH, :tileable => true)  # image of boom exploding in vertical   direction
        ]
        @curr_imgages       = [@images[0]]
        @state              = 0                     # 0: normal state ; 1: exploding state
        @time_since_planted = Gosu.milliseconds     # track time to explode the boom
        @length             = DEFAULT_BOOM_LENGTH
        @explode_now        = false
    end

    def time_to_explode?
        result       = @explode_now || (Gosu.milliseconds - @time_since_planted >= DEFAULT_TIME_TO_EXPLODE)
        @explode_now = false if @explode_now
        result
    end
    
    def finish_explode?
        Gosu.milliseconds - @time_since_exploded >= DEFAULT_TIME_TO_FINISH_EXPLODING
    end

    def explode
        @curr_imgages           = [@images[1], @images[2]]
        @time_since_exploded    = Gosu.milliseconds
    end

    def images
        self.explode if self.time_to_explode? && @time_since_exploded.nil?      # make sure not yet exploded
        (@time_since_exploded.nil? || !finish_explode?) ? @curr_imgages : nil
    end

    def width
        @images.first.width
    end

    def height
        @images.first.height
    end

    def touch?(x, w, y, h)
        (@x.between?(x, x + w) || (@x + self.width).between?(x, x+ w)) && (@y.between?(y, y + h) || (@y + self.height).between?(y, y + h))
    end
end