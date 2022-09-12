DEFAULT_PIRATE_IMG_PATH  = "./images/boss/pirate_slave.png"
DEFAULT_PIRATE_SPEED     = 1
DEFAULT_PIRATE_DIRECTION = "l"

class Pirate
    attr_reader :normal_image, :bubble_image, :x, :y
    attr_accessor :curr_direction, :speed, :chasing_speed, :chasing

    def initialize(x, y, speed = DEFAULT_PIRATE_SPEED, direction = DEFAULT_PIRATE_DIRECTION, chasing_speed = DEFAULT_PIRATE_SPEED)
        @x, @y          = x, y
        @normal_image   = Gosu::Image.new(DEFAULT_PIRATE_IMG_PATH, :tileable => true)
        @speed          = speed
        @chasing_speed  = chasing_speed < speed ? speed : chasing_speed
        @chasing        = false
        @curr_direction = direction
    end

    # returns width of pirate
    def width
        @normal_image.width
    end

    # returns height of pirate
    def height
        @normal_image.height
    end

    # draws the pirate
    def draw
        @normal_image.draw(@x, @y, 0)
    end

    # returns true if the given [x, y] positin touch current pirate
    def touch?(x, y)
        x.between?(@x, @x + width) && y.between?(@y, @y + height)
    end

    # make a move based on given direction
    def move(obstacles, direction = @curr_direction, window)
        speed = calculate_speed(obstacles, direction, window)
        case direction
        when "l" ; @x -= speed
        when "r" ; @x += speed
        when "u" ; @y -= speed
        when "d" ; @y += speed
        end
    end

    # returns true it there is an obstacle in given direction; false otherwise
    def obstacle?(obstacles, direction, x = @x, y = @y)
        case direction
        when "l" ; obstacles.any? { |obstacle| x == (obstacle.x + obstacle.width)  &&  (y.between?(obstacle.y, obstacle.y + obstacle.height - o_y) || (y + self.height - o_y).between?(obstacle.y, obstacle.y + obstacle.height)) }
        when "r" ; obstacles.any? { |obstacle| (x + self.width)  == obstacle.x     &&  (y.between?(obstacle.y, obstacle.y + obstacle.height - o_y) || (y + self.height - o_y).between?(obstacle.y, obstacle.y + obstacle.height)) }
        when "u" ; obstacles.any? { |obstacle| (y == obstacle.y + obstacle.height) &&  (x.between?(obstacle.x, obstacle.x + obstacle.width  - o_x) || (x + self.width  - o_x).between?(obstacle.x, obstacle.x + obstacle.width))  }
        when "d" ; obstacles.any? { |obstacle| (y + self.height) == obstacle.y     &&  (x.between?(obstacle.x, obstacle.x + obstacle.width  - o_x) || (x + self.width  - o_x).between?(obstacle.x, obstacle.x + obstacle.width))  }
        end
    end

    # return the opposite direction based on current direction
    def opposite_direction
        case @curr_direction
        when "l" ; "r"
        when "r" ; "l"
        when "u" ; "d"
        when "d" ; "u"
        end
    end
    
    # returns offset x
    def o_x
        width / DEFAULT_MOVE_OFFSET_FACTOR
    end

    # returns offset y
    def o_y
        height / DEFAULT_MOVE_OFFSET_FACTOR
    end

protected
    # calculate the distance the pirate can traveled based on its speed and obstacles on the map
    def calculate_speed(obstacles, direction, window)
        speed = @chasing ? @chasing_speed : @speed
        dist  = 0
        x, y  = @x, @y
        
        while !obstacle?(obstacles, direction, x, y) && dist < speed && (
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
end
