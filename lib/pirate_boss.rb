require_relative 'pirate'
require_relative 'character'

DEFAULT_PIRATE_BOSS_IMG_PATH         = "./images/boss/pirate_boss.png"
DEFAULT_BIG_BUBBLE_IMG_PATH          = "./images/boss/big_bubble.png"
DEFAULT_BOOM_IMG_PATH                = "./images/booms/0.png"
DEFAULT_BOSS_SPEED_WHEN_DYING        = 0
DEFAULT_BOSS_LIFE_COUNT              = 5
DEFAULT_BOSS_BOOM_LENGTH             = 3
DEFAULT_TIME_GAP_WHEN_PLANTING_BOOMS = 10_000  # every 10 seconds

# difficulty controls (No boom's quantity limit)
#   1) speed         -> default speed
#   2) chasing speed -> speed when chasing players
#   3) life_count    -> number of lives boss has
#   4) boom_length   -> boom length of boss
#   5) time_gap      -> time's gap between each attack
#   6) attack_type   -> type of attack and pct of getting that attack
#       i)   random   : pct ---> pct of booms out of empty positions
#       ii)  target   : no control factor
#       iii) surround : no control factor
#       iv)  screen   : no control factor
#       v)   destroy  : no control factor

class PirateBoss < Pirate
    attr_reader :boom_image, :boom_length, :attack_types
    attr_accessor :life_count, :got_boom, :booms, :normal_image, :boom_image

    def initialize(
            x                                                   ,
            y                                                   ,
            players                                             ,
            attack_types                                        ,
            speed         = DEFAULT_PIRATE_SPEED                , 
            direction     = DEFAULT_PIRATE_DIRECTION            , 
            chasing_speed = DEFAULT_PIRATE_SPEED                , 
            life_count    = DEFAULT_BOSS_LIFE_COUNT - 1         , 
            boom_length   = DEFAULT_BOSS_BOOM_LENGTH            , 
            time_gap      = DEFAULT_TIME_GAP_WHEN_PLANTING_BOOMS
        )
        super(x, y, speed, direction, chasing_speed)

        @normal_image        = Gosu::Image.new(DEFAULT_PIRATE_BOSS_IMG_PATH, :tileable => true)
        @bubble_image        = Gosu::Image.new(DEFAULT_BIG_BUBBLE_IMG_PATH , :tileable => true)
        @boom_image          = Gosu::Image.new(DEFAULT_BOOM_IMG_PATH       , :tileable => true)
        @players             = players
        @got_boom            = false
        @booms               = []
        @life_count          = life_count
        @boom_length         = boom_length
        @time_gap            = time_gap
        @attack_types        = attack_types
    end

    # plants boom(s) based on attack type
    def plant_booms(map, occupied_pct = 5)
        @time_since_planted = Gosu.milliseconds

        case attack_type
        when "random"    ; random_attack(map, occupied_pct)
        when "target"    ; target_attack(map)
        when "surround"  ; surround_attack(map)
        when "screen"    ; screen_attack(map)
        when "destroy"   ; destroy_attack(map)
        when "no_attack" ;
        end
    end

    # draw pirate boss and its life count based on its current position and state
    def draw(players, map)
        enemies = players.select { |player| !player.disable? && !player.dying? }

        if @got_boom && @life_count == 0
            @speed = DEFAULT_BOSS_SPEED_WHEN_DYING ; @chasing_speed = DEFAULT_BOSS_SPEED_WHEN_DYING

            if    !dying?              ; self.dying
            elsif self.dead?           ; map.remove_opponent(self) ; return  # dead -> do nothing, no drawing
            elsif is_kill_by?(enemies) ; self.dead                           # not yet dead, make it dead
            end
            @bubble_image.draw(@x, @y, 0)
        end

        @normal_image.draw(@x, @y, 0)
        draw_life_count
    end

    # returns true if pirate boss is dying; false otherwise
    def dying?
        !@time_since_got_boom.nil?
    end

    # removes a boom from pirate boss boom list
    def remove_boom(boom)
        @booms.delete(boom)
    end

    # returns true if the pirate boss is ABLE to plant a boom
    def plantable?
        if @time_since_planted.nil?
            !@got_boom
        else
            if (Gosu.milliseconds - @time_since_planted >= @time_gap)
                @time_since_planted = nil
                !@got_boom
            else
                false
            end
        end
    end

    # returns true if boss is dead; false otherwise
    def dead?
        dying? ? Gosu.milliseconds - @time_since_got_boom >= DEFAULT_DYING_STATE_1_TIME : false
    end
private
    # draw the number of lives remaining above pirate boss head
    def draw_life_count
        x, y = @x, @y - DEFAULT_TILE_HEIGHT
        "#{@life_count}".each_char { |char| Character.new.symbols[char].draw(x, y, 0) ; x += DEFAULT_TILE_WIDTH }
    end

    # set the dying state for this pirate boss
    def dying
        @time_since_got_boom = Gosu.milliseconds
    end

    # set the dead state for this pirate boss
    def dead
        @time_since_got_boom = -DEFAULT_DYING_STATE_1_TIME
    end

    # returns true if boss pirate is killed by enemy(being touched while in dying state)
    def is_kill_by?(enemies)
        enemies.any? { |enemy| enemy.x.between?(@x, @x + width) && enemy.y.between?(@y, @y + height) }
    end

    # returns true if NONE obstacles overlap with [x, y] position
    def none_obstacles_overlap?(x, y, *obstacle_arrays)
        obstacle_arrays.all? { |obstacles| obstacles.none? { |obstacle| self.obstacle_overlap?(x, y, obstacle) } }
    end

    # returns true if obstacle overlaps the given [x, y] position
    def obstacle_overlap?(x, y, obstacle)
        x == obstacle.x && y == obstacle.y
    end
    
    # plant a boom if possible
    def plant_boom(players, (x, y), walls)
        all_booms = players.map { |player| player.booms }.flatten + @booms
        if self.none_obstacles_overlap?(x, y, all_booms, walls)
            @booms << Boom.new(x, y, self)
        end
    end

    # returns the attack type based on attack types percentage
    def attack_type
        rand_num = rand(100)  # 0-99
        tot_pct  = @attack_types.values.sum
        curr_pct = @attack_types.values.first

        @attack_types.each_with_index do |(attack_type, attack_pct), i|
            break if rand_num > tot_pct
            return attack_type if rand_num < curr_pct
            curr_pct += @attack_types.values[i + 1] if i != @attack_types.length - 1
        end

        "no_attack"
    end

    # plants random booms onto the screen based on given percentage(percentage of booms that will occupy the empty positions)
    def random_attack(map, pct)
        map.empty_positions.each { |(x, y)| plant_boom(map.players, map.window.get_closet_tile_coor(x, y), map.obstacles) if rand(100) < pct }
    end

    # plants a few booms at each player's position
    def target_attack(map)
        map.players.each do |player|
            next if player.disable?
            x, y = map.window.get_closet_tile_coor(player.x, player.y)
            2.times { plant_boom(map.players, [x, y], map.obstacles) ; x += player.width if map.empty_positions.include?([x, y]) } ; x, y = x - player.width, y + player.height
            2.times { plant_boom(map.players, [x, y], map.obstacles) ; x -= player.width if map.empty_positions.include?([x, y]) }
        end
    end

    # surround all players with a "square shape" of booms
    def surround_attack(map)
        map.players.each do |player|
            next if player.disable?
            x, y = player.x - (2 * player.width), player.y - (2 * player.height)
            5.times { x, y = map.window.get_closet_tile_coor(x, y) ; plant_boom(map.players, [x, y], map.obstacles) if map.empty_positions.include?([x, y]) ; x += player.width  } ; x, y = x - player.width, y + player.height
            4.times { x, y = map.window.get_closet_tile_coor(x, y) ; plant_boom(map.players, [x, y], map.obstacles) if map.empty_positions.include?([x, y]) ; y += player.height } ; x, y = x - player.width, y - player.height
            4.times { x, y = map.window.get_closet_tile_coor(x, y) ; plant_boom(map.players, [x, y], map.obstacles) if map.empty_positions.include?([x, y]) ; x -= player.width  } ; x, y = x + player.width, y - player.height
            4.times { x, y = map.window.get_closet_tile_coor(x, y) ; plant_boom(map.players, [x, y], map.obstacles) if map.empty_positions.include?([x, y]) ; y -= player.height }
        end
    end

    # plants a biggest possible "square shape" of booms based on current window width and height
    def screen_attack(map)
        x, y = 0, 0
        (map.screen_w / map.tile_w).times     { plant_boom(map.players, [x, y], map.obstacles) if map.empty_positions.include?([x, y]) ; x += map.tile_w } ; x, y = x - map.tile_w, y + map.tile_h
        (map.screen_h / map.tile_h - 1).times { plant_boom(map.players, [x, y], map.obstacles) if map.empty_positions.include?([x, y]) ; y += map.tile_h } ; x, y = x - map.tile_w, y - map.tile_h
        (map.screen_w / map.tile_w - 1).times { plant_boom(map.players, [x, y], map.obstacles) if map.empty_positions.include?([x, y]) ; x -= map.tile_w } ; x, y = x + map.tile_w, y - map.tile_h
        (map.screen_h / map.tile_h - 1).times { plant_boom(map.players, [x, y], map.obstacles) if map.empty_positions.include?([x, y]) ; y -= map.tile_h }
    end

    # plants a boom at every single empty position on the map
    def destroy_attack(map)
        map.empty_positions.each { |pos| plant_boom(map.players, pos, map.obstacles) }
    end
end
