DEFAULT_EXTRA_BOOM_ITEM_IMG_PATH  = "./images/items/extra_boom.png"
DEFAULT_SPEED_ITEM_IMG_PATH       = "./images/items/speed.png"
DEFAULT_BOOM_LENGTH_ITEM_IMG_PATH = "./images/items/boom_length.png"
DEFAULT_ITEMS_RADAR_IMG_PATH      = "./images/items/items_radar.png"
DEFAULT_BOOMS_RADAR_IMG_PATH      = "./images/items/booms_radar.png"
DEFAULT_DART_IMG_PATH             = "./images/items/dart.png"
DEFAULT_LIFE_ITEM_IMG_PATH        = "./images/items/life.png"
DEFAULT_BOOM_SHIELD_ITEM_IMG_PATH = "./images/items/boom_shield.png"
DEFAULT_SPRING_ITEM_IMG_PATH      = "./images/items/spring.png"

class MapItem
    attr_reader :x, :y, :name
    attr_accessor :life_count, :touch_boom

    def initialize(x, y, name, num_life)
        @life_count   = num_life
        @touch_boom   = false
        @x, @y, @name = x, y, name
        @image        = get_image
    end

    # returns width of this item on the map
    def width
        @image.width
    end

    # returns height of this item on the map
    def height
        @image.height
    end

    # draws this item
    def draw
        @image.draw(@x, @y, 0)
    end

    # returns true if this item touches [x, y] position ; false otherwise
    def touch?(x, y)
        @x == x && @y == y
    end
private
    # returns an array of map items images
    def get_image
        case @name
        when "extra_boom"  ; Gosu::Image.new(DEFAULT_EXTRA_BOOM_ITEM_IMG_PATH , :tileable => true)
        when "speed"       ; Gosu::Image.new(DEFAULT_SPEED_ITEM_IMG_PATH      , :tileable => true)
        when "boom_length" ; Gosu::Image.new(DEFAULT_BOOM_LENGTH_ITEM_IMG_PATH, :tileable => true)
        when "items_radar" ; Gosu::Image.new(DEFAULT_ITEMS_RADAR_IMG_PATH     , :tileable => true)
        when "booms_radar" ; Gosu::Image.new(DEFAULT_BOOMS_RADAR_IMG_PATH     , :tileable => true)
        when "dart"        ; Gosu::Image.new(DEFAULT_DART_IMG_PATH            , :tileable => true)
        when "life"        ; Gosu::Image.new(DEFAULT_LIFE_ITEM_IMG_PATH       , :tileable => true)
        when "boom_shield" ; Gosu::Image.new(DEFAULT_BOOM_SHIELD_ITEM_IMG_PATH, :tileable => true)
        when "spring"      ; Gosu::Image.new(DEFAULT_SPRING_ITEM_IMG_PATH     , :tileable => true)
        end
    end
end
