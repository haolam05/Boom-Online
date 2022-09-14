require_relative 'player'
require_relative 'map'
require_relative 'character'
require_relative 'player_item'

DEFAULT_SCREEN_WIDTH      = 1000
DEFAULT_SCREEN_HEIGHT     = 1000
DEFAULT_GAME_DURATION     = 180_000 # 180 seconds -> 3 minutes
DEFAULT_SCREEN_CAPTION    = "Boom Online"
DEFAULT_MESSAGE_SHOW_TIME = 3_000  # 3 seconds
DEFAULT_TILE_WIDTH        = 50
DEFAULT_TILE_HEIGHT       = 50

class SetUp
    attr_reader :players, :map, :symbols, :battle_option
    attr_accessor :setup_state

    def initialize(window)
        set_up_symbols
        @window      = window
        @font        = Gosu::Font.new(DEFAULT_TILE_HEIGHT * 2)
        @setup_state = "battle_options" 
        @start_game  = false
        @players     = [Player.new, Player.new]
        @screen_w    = window.width
        @screen_h    = window.height - self.total_height_of_all_players
    end

    # returns the total height of all players combined
    def total_height_of_all_players
        @players.length * DEFAULT_TILE_HEIGHT
    end

    # returns true if game has started; false otherwise
    def game_start?
        @start_game
    end

    # creates a map based on previous options
    def set_up_map
        @map = Map.new(@players, DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT, @screen_w, @screen_h, @window, @battle_option)
    end

    # creates mapping of the characters from Character class
    def set_up_symbols
        @symbols = Character.new
    end

    # set up keys associated to the players as well as their initial speed/boom_length/boom_quantity and other items quantity
    def set_up_players
        ### set moving keys: left right up down
        @players[0].l_key = Gosu::KbLeft ; @players[0].r_key =  Gosu::KbRight ; @players[0].u_key = Gosu::KbUp ; @players[0].d_key = Gosu::KbDown
        @players[1].l_key = Gosu::KbA    ; @players[1].r_key =  Gosu::KbD     ; @players[1].u_key = Gosu::KbW  ; @players[1].d_key = Gosu::KbS

        ### set boom key
        @players[0].b_key = Gosu::KB_RIGHT_SHIFT
        @players[1].b_key = Gosu::KB_LEFT_SHIFT

        ### set boom length
        @players[0].boom_length = 1
        @players[1].boom_length = 1

        ### set default boom's quantity
        @players[0].curr_boom_quantity = 1
        @players[1].curr_boom_quantity = 1

        ### set speed
        @players[0].speed = 1
        @players[1].speed = 1

        ### set item keys
        @players[0].life_key        = Gosu::KbN              ; @players[0].items[Gosu::KbN]              = PlayerItem.new("life", "./images/items/life.png")                       ; @players[0].items_quantity[Gosu::KbN]              = 1
        @players[1].life_key        = Gosu::KB_1             ; @players[1].items[Gosu::KB_1]             = PlayerItem.new("life", "./images/items/life.png")                       ; @players[1].items_quantity[Gosu::KB_1]             = 1
        @players[0].boom_shield_key = Gosu::KbM              ; @players[0].items[Gosu::KbM]              = PlayerItem.new("boom_shield", "./images/items/boom_shield.png", 5_000)  ; @players[0].items_quantity[Gosu::KbM]              = 2
        @players[1].boom_shield_key = Gosu::KB_2             ; @players[1].items[Gosu::KB_2]             = PlayerItem.new("boom_shield", "./images/items/boom_shield.png", 5_000)  ; @players[1].items_quantity[Gosu::KB_2]             = 2
        @players[0].spring_key      = Gosu::KB_COMMA         ; @players[0].items[Gosu::KB_COMMA]         = PlayerItem.new("spring", "./images/items/spring.png")                   ; @players[0].items_quantity[Gosu::KB_COMMA]         = 3
        @players[1].spring_key      = Gosu::KB_3             ; @players[1].items[Gosu::KB_3]             = PlayerItem.new("spring", "./images/items/spring.png")                   ; @players[1].items_quantity[Gosu::KB_3]             = 3
        @players[0].items_radar_key = Gosu::KB_PERIOD        ; @players[0].items[Gosu::KB_PERIOD]        = PlayerItem.new("items_radar", "./images/items/items_radar.png", 20_000) ; @players[0].items_quantity[Gosu::KB_PERIOD]        = 4
        @players[1].items_radar_key = Gosu::KB_4             ; @players[1].items[Gosu::KB_4]             = PlayerItem.new("items_radar", "./images/items/items_radar.png", 20_000) ; @players[1].items_quantity[Gosu::KB_4]             = 4
        @players[0].booms_radar_key = Gosu::KB_SLASH         ; @players[0].items[Gosu::KB_SLASH]         = PlayerItem.new("booms_radar", "./images/items/booms_radar.png", 20_000) ; @players[0].items_quantity[Gosu::KB_SLASH]         = 5
        @players[1].booms_radar_key = Gosu::KB_5             ; @players[1].items[Gosu::KB_5]             = PlayerItem.new("booms_radar", "./images/items/booms_radar.png", 20_000) ; @players[1].items_quantity[Gosu::KB_5]             = 5
        @players[0].dart_key        = Gosu::KB_RIGHT_CONTROL ; @players[0].items[Gosu::KB_RIGHT_CONTROL] = PlayerItem.new("dart", "./images/items/dart.png", 0_001)                ; @players[0].items_quantity[Gosu::KB_RIGHT_CONTROL] = 6
        @players[1].dart_key        = Gosu::KB_6             ; @players[1].items[Gosu::KB_6]             = PlayerItem.new("dart", "./images/items/dart.png", 0_001)                ; @players[1].items_quantity[Gosu::KB_6]             = 6
    end

    # pciks battle option based on user's choice("solo"/"team")
    def update_battle_options(mouse_x, mouse_y)
        x1, x2, y1, y2 = @solo_pos
        if mouse_x.between?(x1, x2) && mouse_y.between?(y1, y2)
            @setup_state   = "player1_options"
            @battle_option = "solo"
            @players[0].team_id = 0
            @players[1].team_id = 1
        else
            x1, x2, y1, y2 = @team_pos
            if mouse_x.between?(x1, x2) && mouse_y.between?(y1, y2)
                @setup_state   = "player1_options"
                @battle_option = "team"
                @players[0].team_id = 0
                @players[1].team_id = 0
            end
        end
    end

    # pick player photo for player #1 and #2 based on user's choice
    def update_player_options(n, mouse_x, mouse_y)
        @player_positions.each { |(x1, x2, y1, y2), player| (n == 1 ? (@player1 = player)    : (@player2 = player))    if mouse_x.between?(x1, x2) && mouse_y.between?(y1, y2) }
        @boom_positions.each   { |(x1, x2, y1, y2), boom  | (n == 1 ? (@player1_boom = boom) : (@player2_boom = boom)) if mouse_x.between?(x1, x2) && mouse_y.between?(y1, y2) }

        x1, x2, y1, y2 = @next_position.first
        next_page      = mouse_x.between?(x1, x2) && mouse_y.between?(y1, y2) 
        if (n == 1 && next_page && !@player1.nil? && !@player1_boom.nil?)
            @players[0].name         = @player1.last
            @players[0].normal_image = @player1.first
            @players[0].boom_image   = @player1_boom
            @setup_state = "player2_options"
        elsif(n == 2 && next_page && !@player2.nil? && !@player2_boom.nil?)
            @players[1].name         = @player2.last
            @players[1].normal_image = @player2.first
            @players[1].boom_image   = @player2_boom
            @setup_state = "summary"
        end
    end

    # starts the game when button is clicked in the summary page
    def update_summary(mouse_x, mouse_y, window = nil)
        x1, x2, y1, y2 = @start_position.first
        @start_game = mouse_x.between?(x1, x2) && mouse_y.between?(y1, y2)
        @setup_state = "start_game" if @start_game
        window.update_timer(true) if !window.nil?
    end

    # toggling between pause/resume the game when the pause/resume button is clicked
    def update_pause_button(mouse_x, mouse_y)
        x1, x2, y1, y2 = @pause_button_position
        if mouse_x.between?(x1, x2) && mouse_y.between?(y1, y2)
            case @setup_state
            when "start_game" ; @setup_state = "pause" 
            when "pause"      ; @setup_state = "start_game" 
            end
        end

        sleep(0.5)
    end

    # draws welcoming message and battle options
    def draw_battle_options
        # welcome message
        m        = "Choose your battle"
        x_offset = (@screen_w - @font.text_width(m)) / 2
        y_offset = @screen_h / 4
        @font.draw_markup(m, x_offset, y_offset, 0, scale_x=1, scale_y=1, color=0xff_ffffff, mode=:default)

        # option background
        #            x1,       x2,                             y1,                                       y2
        @solo_pos = [x_offset, x_offset + @font.text_width(m), y_offset + (1 * DEFAULT_TILE_HEIGHT * 2), y_offset + (1 * DEFAULT_TILE_HEIGHT * 2) + (DEFAULT_TILE_HEIGHT * 2)]
        @team_pos = [x_offset, x_offset + @font.text_width(m), y_offset + (2 * DEFAULT_TILE_HEIGHT * 2), y_offset + (2 * DEFAULT_TILE_HEIGHT * 2) + (DEFAULT_TILE_HEIGHT * 2)]
        x1, x2, y1, y2 = @solo_pos ; Gosu.draw_rect(x1, y1, x2 - x1, y2 - y1, Gosu::Color::YELLOW)
        x1, x2, y1, y2 = @team_pos ; Gosu.draw_rect(x1, y1, x2 - x1, y2 - y1, Gosu::Color::CYAN)

        # option text: "solo"
        y_offset += DEFAULT_TILE_HEIGHT * 2
        m         = "SOLO "
        x_offset  = (@screen_w - @font.text_width(m)) / 2
        message   = @symbols.add_bold(m)
        message   = @symbols.add_italic(message)
        @font.draw_markup(message, x_offset, y_offset, 0, scale_x=1, scale_y=1, color=0xff_000000, mode=:default)

        # option text: "team"
        y_offset += DEFAULT_TILE_HEIGHT * 2
        m         = "TEAM "
        x_offset  = (@screen_w - @font.text_width(m)) / 2
        message   = @symbols.add_bold(m)
        message   = @symbols.add_italic(message)
        @font.draw_markup(message, x_offset, y_offset, 0, scale_x=1, scale_y=1, color=0xff_000000, mode=:default)
    end

    # draw player #1 and #2 options
    def draw_player_options(n)
        # draw chosen player
        x, y = @screen_w - (2 * DEFAULT_TILE_WIDTH), @screen_h / 4
        if (n == 1 && !@player1.nil?) || (n == 2 && !@player2.nil?)
            n == 1 ? @player1.first.draw(x, y, 0) : @player2.first.draw(x, y, 0) 
        end

        # draw chosen boom
        y += (2 * DEFAULT_TILE_WIDTH)
        if (n == 1 && !@player1_boom.nil?) || (n == 2 && !@player2_boom.nil?)
            n == 1 ? @player1_boom.draw(x, y, 0) : @player2_boom.draw(x, y, 0) 
        end

        # welcome message
        m        = "Player ##{n}"
        x_offset = (@screen_w - @font.text_width(m)) / 2
        y_offset = @screen_h / 4 - (DEFAULT_TILE_HEIGHT * 2)
        @font.draw_markup(m, x_offset, y_offset, 0, scale_x=1, scale_y=1, color=0xff_ffffff, mode=:default)

        # character color options
        @player_positions = {}
        player_colors     = ["blue", "brown", "green", "orange", "pink", "purple", "red", "yellow"]
        x                 = (@screen_w -( DEFAULT_TILE_WIDTH * player_colors.length)) / 2
        y                 = @screen_h / 4
        
        player_colors.each_with_index do |player_color, i|
            Gosu.draw_rect(x, y, DEFAULT_TILE_WIDTH, DEFAULT_TILE_WIDTH, i.even? ? Gosu::Color::CYAN : Gosu::Color::YELLOW)
            player = Gosu::Image.new("./images/characters/#{player_color}.png", :tileable => true)
            player.draw(x, y, 0)
            @player_positions[[x, x + DEFAULT_TILE_WIDTH, y, y + DEFAULT_TILE_HEIGHT]] = [player, player_color]
            x += DEFAULT_TILE_WIDTH
        end

        # boom options
        @boom_positions   = {}
        background_color  = Gosu::Color::CYAN
        booms             = Dir.entries("./images/booms").select { |filename| filename.include?("png") && filename.length <= 6 } #longest = "64.png"
        x                 = ((@screen_w -( DEFAULT_TILE_WIDTH * booms.length)) / 2 <= 0 ? 0 : (@screen_w -( DEFAULT_TILE_WIDTH * booms.length)) / 2) + (4 * DEFAULT_TILE_WIDTH)
        y                += DEFAULT_TILE_HEIGHT
        num_booms_per_row = (@screen_w  / DEFAULT_TILE_WIDTH) - 8   # 12
        booms.each_with_index do |boom, i|
            if i % num_booms_per_row == 0
                x = ((@screen_w -( DEFAULT_TILE_WIDTH * booms.length)) / 2 <= 0 ? 0 : (@screen_w -( DEFAULT_TILE_WIDTH * booms.length)) / 2) + (4 * DEFAULT_TILE_WIDTH)
                y += DEFAULT_TILE_HEIGHT
                background_color = background_color == Gosu::Color::CYAN ? Gosu::Color::YELLOW : Gosu::Color::CYAN

            end
            
            background_color = background_color == Gosu::Color::CYAN ? Gosu::Color::YELLOW : Gosu::Color::CYAN
            Gosu.draw_rect(x, y, DEFAULT_TILE_WIDTH, DEFAULT_TILE_WIDTH, background_color)
            boom = Gosu::Image.new("./images/booms/#{boom}", :tileable => true)
            boom.draw(x, y, 0)
            @boom_positions[[x, x + DEFAULT_TILE_WIDTH, y, y + DEFAULT_TILE_HEIGHT]] = boom
            x += DEFAULT_TILE_WIDTH
        end 
        # fill up empty tiles that do not have booms in the last row
        num_empty_tiles = num_booms_per_row - (booms.length % num_booms_per_row)
        num_empty_tiles.times do
            background_color = background_color == Gosu::Color::CYAN ? Gosu::Color::YELLOW : Gosu::Color::CYAN
            Gosu.draw_rect(x, y, DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT, background_color)
            x += DEFAULT_TILE_HEIGHT
        end

        # display player keys
        keys        = Dir.entries("./images/keyboard").select { |filename| filename.include?("png") && filename.start_with?("player#{n}")}
        total_width = keys.map { |key| Gosu::Image.new("./images/keyboard/#{key}", :tileable => true).width }.sum
        x           = (@screen_w - total_width) / 2 - DEFAULT_TILE_WIDTH
        y          += (2 * DEFAULT_TILE_HEIGHT)

        keys.each do |key|
            img = Gosu::Image.new("./images/keyboard/#{key}", :tileable => true)
            img.draw(x, y, 0)
            x += img.width + DEFAULT_TILE_WIDTH
        end

        x  = (@screen_w - total_width) / 2 - DEFAULT_TILE_WIDTH
        y += DEFAULT_TILE_HEIGHT
        Gosu::Image.new("./images/booms/0.png", :tileable => true).draw(x, y, 0)

        x += Gosu::Image.new("./images/keyboard/player#{n}_boom_key.png", :tileable => true).width + DEFAULT_TILE_WIDTH
        keys = Dir.entries("./images/items/player_items").select { |filename| filename.include?("png") }
        keys.each do |key|
            Gosu::Image.new("./images/items/player_items/#{key}", :tileable => true).draw(x, y, 0)
            x += DEFAULT_TILE_WIDTH
        end

        # draw Next button
        m              = "Next "
        x              = (@screen_w - @font.text_width(m)) / 2
        y             += (2 * DEFAULT_TILE_HEIGHT)
        @next_position = [[x, x + @font.text_width(m), y, y + (2 * DEFAULT_TILE_HEIGHT)]]
        Gosu.draw_rect(x, y, @font.text_width(m), 2 * DEFAULT_TILE_HEIGHT, Gosu::Color::GRAY)
        @font.draw_markup(m, x, y, 0, scale_x=1, scale_y=1, color=0xff_ffffff, mode=:default)
    end

    # draws the summary page based on earlier options picked by user
    def draw_summary
        # Draw "VS" and "Start"
        Gosu::Image.new("./images/keyboard/VS.png", :tileable => true).draw(0, 0, 0)
        m = "START "
        x = @screen_w - @font.text_width(m)
        y = @screen_h
        Gosu.draw_rect(x, y, @font.text_width(m), 2 * DEFAULT_TILE_HEIGHT, Gosu::Color::GRAY)
        @font.draw_markup(m, x, y, 0, scale_x=1, scale_y=1, color=0xff_ffffff, mode=:default)
        @start_position = [[x, x + @font.text_width(m), y, y + ( 2 * DEFAULT_TILE_HEIGHT)]]

        # Draw team1
        x, y = DEFAULT_TILE_WIDTH, @screen_h / 4
        @player1.first.draw(x, y, 0)
        x += DEFAULT_TILE_WIDTH
        @player1_boom.draw(x, y, 0)
        
        # Draw team2
        if @battle_option == "team"
            x  = DEFAULT_TILE_WIDTH
            y += DEFAULT_TILE_HEIGHT
            @player2.first.draw(x, y, 0)
            x += DEFAULT_TILE_WIDTH
            @player2_boom.draw(x, y, 0)

            # Draw boss
            boss  = Gosu::Image.new("./images/boss/pirate_boss.png", :tileable => true)
            slave = Gosu::Image.new("./images/boss/pirate_slave.png", :tileable => true)
            x  = @screen_w - DEFAULT_TILE_WIDTH - boss.width - slave.width
            y  = (@screen_h / 4) * 3
            boss.draw(x, y, 0)
            
            # Draw slaves
            x += boss.width
            y += boss.height - slave.height
            slave.draw(x, y, 0)
            3.times { y -= slave.height ; slave.draw(x, y, 0) }
            5.times { x -= slave.width  ; slave.draw(x, y, 0) }
            3.times { y += slave.height ; slave.draw(x, y, 0) }
            5.times { x += slave.width  ; slave.draw(x, y, 0) }
        elsif @battle_option == "solo"
            x  = @screen_w - (3 * DEFAULT_TILE_WIDTH)
            y  = (@screen_h / 4) * 3
            @player2.first.draw(x, y, 0)
            x += DEFAULT_TILE_WIDTH
            @player2_boom.draw(x, y, 0)
        end
    end

    # draw the pause/resume button based on current state
    def draw_pause_button
        case @setup_state
        when "start_game" ; pause_button = Gosu::Image.new("./images/others/play_button.png" , :tileable => true)
        when "pause"      ; pause_button = Gosu::Image.new("./images/others/pause_button.png", :tileable => true)
        end

        x1, y1 = @screen_w - DEFAULT_TILE_WIDTH, @screen_h ; x2, y2 = x1 + pause_button.width, y1 + pause_button.height ; pause_button.draw(x1, y1, 0)
        @pause_button_position = [x1, x2, y1, y2]
    end
end
 