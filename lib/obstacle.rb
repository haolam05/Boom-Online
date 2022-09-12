DEFAULT_IRREMOVABLE_IMG_PATH = "./images/obstacles/irremovable.png"
DEFAULT_REMOVABLE_IMG_PATH   = "./images/obstacles/removable.png"

class Obstacle
    attr_reader :x, :y, :removable
    attr_accessor :touch_boom

    def initialize(x, y, removable = nil)
        @touch_boom        = false
        @x, @y, @removable = x, y, removable
        @irremovable_img   = Gosu::Image.new(DEFAULT_IRREMOVABLE_IMG_PATH, :tileable => true)
        @removable_img     = Gosu::Image.new(DEFAULT_REMOVABLE_IMG_PATH  , :tileable => true)
    end

    # returns width of obstacle
    def width
        @removable ? @removable_img.width : @irremovable_img.width 
    end

    # returns height of obstacle
    def height
       @removable ? @removable_img.height : @irremovable_img.height 
    end

    # draws obstacle
    def draw
        (@removable ? @removable_img : @irremovable_img).draw(@x, @y, 0) if !@removable.nil?
    end

    # returns true if obstacle touchs [x, y] position ; false otherwise
    def touch?(x, y)
        @x == x && @y == y
    end
end
