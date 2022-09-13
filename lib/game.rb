require 'gosu'
require 'gosu_more_drawables'

require_relative 'sound'
require_relative 'setup'
require_relative 'player_item'

class GameWindow < Gosu::Window
  def initialize
    super DEFAULT_SCREEN_WIDTH, DEFAULT_SCREEN_HEIGHT, fullscreen: false
    self.caption = DEFAULT_SCREEN_CAPTION
    @game        = SetUp.new(self)
    @bg_song     = Sound.new.background
  end

  # called once every {#update_interval} milliseconds --- update the following things on screen based on current states
  def update
    case @game.setup_state
    when "battle_options"  ; (@game.update_battle_options(   self.mouse_x, self.mouse_y      ) ; Sound.new.mouse_click.play) if self.button_down?(Gosu::MS_LEFT)
    when "player1_options" ; (@game.update_player_options(1, self.mouse_x, self.mouse_y      ) ; Sound.new.mouse_click.play) if self.button_down?(Gosu::MS_LEFT)
    when "player2_options" ; (@game.update_player_options(2, self.mouse_x, self.mouse_y      ) ; Sound.new.mouse_click.play) if self.button_down?(Gosu::MS_LEFT)
    when "summary"         ; (@game.update_summary(          self.mouse_x, self.mouse_y, self) ; Sound.new.mouse_click.play) if self.button_down?(Gosu::MS_LEFT) ; initialize_game
    when "start_game"      ; (@game.update_pause_button(     self.mouse_x, self.mouse_y      ) ; Sound.new.mouse_click.play) if self.button_down?(Gosu::MS_LEFT) ; update_timer ; update_player_and_boom_positions ; update_map
    when "pause"           ; (@game.update_pause_button(     self.mouse_x, self.mouse_y      ) ; Sound.new.mouse_click.play) if self.button_down?(Gosu::MS_LEFT)
    when "gameover"        ; reset_game
    end
  end

  # is called after #update --- draws the corressponding pages based on current state
  def draw
    case @game.setup_state
    when "battle_options"  ; @game.draw_battle_options
    when "player1_options" ; @game.draw_player_options(1)
    when "player2_options" ; @game.draw_player_options(2)
    when "summary"         ; @game.draw_summary
    when "start_game"      ; draw_background_img ; draw_items_effect ; draw_map ; draw_players ; draw_players_moving_effect ; draw_booms ; draw_player_items_profile ; draw_timer ; @game.draw_pause_button ; @game.setup_state = "gameover" if gameover?
    when "pause"           ; draw_background_img ; draw_items_effect ; draw_map ; draw_players ; draw_players_moving_effect ; draw_booms ; draw_player_items_profile ; draw_timer ; @game.draw_pause_button ; @game.setup_state = "gameover" if gameover?
    when "gameover"        ;
    end
  end

  # is called when a button is pressed --- activate the item/moving keys of the players for updating later
  def button_down(button_id)
      case button_id
      when Gosu::KbEscape           ; close
      when Gosu::MS_WHEEL_DOWN      ; self.width  -= 100  ; self.height -= 100
      when Gosu::MS_WHEEL_UP        ; self.width  += 100  ; self.height += 100
      when Gosu::MS_MIDDLE          ; self.fullscreen = !self.fullscreen?
      end
      
    if @game.game_start?
      @players.each do |player|
        case button_id
        when player.l_key           ; player.l                                         = true
        when player.r_key           ; player.r                                         = true
        when player.u_key           ; player.u                                         = true
        when player.d_key           ; player.d                                         = true
        when player.b_key           ; player.b                                         = true
        when player.life_key        ; player.items[player.life_key].is_activate        = true
        when player.boom_shield_key ; player.items[player.boom_shield_key].is_activate = true
        when player.spring_key      ; player.items[player.spring_key].is_activate      = true
        when player.items_radar_key ; player.items[player.items_radar_key].is_activate = true
        when player.booms_radar_key ; player.items[player.booms_radar_key].is_activate = true
        when player.dart_key        ; player.items[player.dart_key].is_activate        = true
        end
      end
    end
  end

  # is called when a button is released --- de-activate the item/moving keys of the players for updating later
  def button_up(button_id)
    if @game.game_start?
      @players.each do |player|
        case button_id
        when player.l_key           ; player.l                                         = false
        when player.r_key           ; player.r                                         = false
        when player.u_key           ; player.u                                         = false
        when player.d_key           ; player.d                                         = false
        when player.b_key           ; player.b                                         = false
        when player.life_key        ; player.items[player.life_key].is_activate        = false
        when player.boom_shield_key ; player.items[player.boom_shield_key].is_activate = false
        when player.spring_key      ; player.items[player.spring_key].is_activate      = false
        when player.items_radar_key ; player.items[player.items_radar_key].is_activate = false
        when player.booms_radar_key ; player.items[player.booms_radar_key].is_activate = false
        when player.dart_key        ; player.items[player.dart_key].is_activate        = false
        end
      end
    end
  end

  # returns true if the given position is within the horizontal frame of the screen ; false otherwise
  def within_hor_frame?(position)
    position.between?(0, self.screen_w)
  end

  # returns true if the given position is within the vertical frame of the screen ; false otherwise
  def within_ver_frame?(position)
    position.between?(0, self.screen_h)
  end

  # returns the "usable" screen width
  def screen_w
    self.width
  end

  # returns the "usable" screen height (screen might ends early due to printing player profiles)
  def screen_h
    self.height - @game.total_height_of_all_players
  end

  # fits the [x, y] position to the closest tile(ex: for the boom to fit nicely inside the tile)
  def get_closet_tile_coor(x, y)
    x_coor = x + (x % DEFAULT_TILE_WIDTH  <= DEFAULT_TILE_WIDTH  / 2 ? 0 : DEFAULT_TILE_WIDTH )
    y_coor = y + (y % DEFAULT_TILE_HEIGHT <= DEFAULT_TILE_HEIGHT / 2 ? 0 : DEFAULT_TILE_HEIGHT)
    [(x_coor / DEFAULT_TILE_WIDTH) * DEFAULT_TILE_WIDTH, (y_coor / DEFAULT_TILE_HEIGHT) * DEFAULT_TILE_HEIGHT]
  end

  # update game timer, pause if in "pause" state(elapsed time does NOT count into "game time" because game didn't start until we finished setup, BUT elapsed time is counted when window is created)
  def update_timer(just_start = false)
    @add_on_time = 0 if @add_on_time.nil?

    if @game.setup_state == "pause"
      if  @time_since_pause.nil?  # game WAS played and now it is paused
        @total_time_pause = 0 if @total_time_pause.nil?
        @time_since_pause = Gosu.milliseconds
      end

      @bg_song.stop
    elsif @game.setup_state == "start_game"
      if !@time_since_pause.nil?  # there WAS a pause and now game resumes
        @total_time_pause += (Gosu.milliseconds - @time_since_pause)
        @time_since_pause  = nil
      end

      @bg_song.play(looping = true)
    end
    
    if just_start
      @time_elapsed = Gosu.milliseconds
      Sound.new.game_start.play if @game.setup_state == "start_game"
    end

    @time_since_game_start = Gosu.milliseconds - @time_elapsed - (@total_time_pause.nil? ? 0 : @total_time_pause) - @add_on_time # subtract elapsed time and pause time from the real game time
    if @reset_game
      @add_on_time += @time_since_game_start      
      @reset_game   = false 
    end
  end

  # update a map(based on current state)
  def update_map
    @map.update_map
  end

private
  # game is finished setup ---> get the necessary data(stored in instance variables) from the SetUp class
  def initialize_game
    @game.set_up_players ; @game.set_up_map ; @players, @symbols, @map = @game.players, @game.symbols, @game.map
  end

  # reset the game based on the result of the game and the state we are in
  def reset_game
    self.caption = DEFAULT_SCREEN_CAPTION
    
    case @game.battle_option
    when "solo" ; @game = SetUp.new(self)
    when "team"
      if @map.opponent_players.empty? && @map.level < @map.max_level  # team won  ---> continue on to the next level
        @map = Map.new(@players, DEFAULT_TILE_WIDTH, DEFAULT_TILE_HEIGHT, screen_w, screen_h, self, @game.battle_option, @map.level + 1) ; @game.setup_state = "start_game"
      else
        @game = SetUp.new(self)
      end
    end
    
    @reset_game = true
    @players.each              { |player  | (player.booms  = [] ; player.reset_to_normal_state) if player.is_a?(Player)       }   # remove all booms, including
    @map.opponent_players.each { |opponent| opponent.booms = []                                 if opponent.is_a?(PirateBoss) }   # that are planted but not yet exploded

    sleep(3)  # a little delay is added so that the result won't disaapear too fast
  end

  # update when player moves or plants a boom
  def update_player_and_boom_positions
    @players.each do |player|
      next if player.disable? || self.gameover?
      if    player.l ; player.move("l", @map.obstacles, self)
      elsif player.r ; player.move("r", @map.obstacles, self)
      elsif player.u ; player.move("u", @map.obstacles, self)
      elsif player.d ; player.move("d", @map.obstacles, self)
      elsif player.b ; player.plant_boom(@players, get_closet_tile_coor(player.x, player.y), @map.obstacles) if player.plantable?
      end
      
      @map.opponent_players.any? { |opponent| player.dead if opponent.touch?(player.x + player.o_x, player.y + player.o_y) && (opponent.is_a?(PirateSlave) || (opponent.is_a?(PirateBoss) && !opponent.dying?)) }
      update_player_items_count(player)
    end
  end

  # increment user's item quantity if player picks it up on the map
  def update_player_items_count(player)
    item = @map.map_items.find { |item| (item.x + player.o_x).between?(player.x, player.x + player.width) && (item.y + player.o_y).between?(player.y, player.y + player.height) }
    if !item.nil? && item.life_count == 1
      case item.name
      when "extra_boom"  ; player.curr_boom_quantity                     += 1
      when "speed"       ; player.speed                                  += 1
      when "boom_length" ; player.boom_length                            += 1
      when "items_radar" ; player.items_quantity[player.items_radar_key] += 1
      when "booms_radar" ; player.items_quantity[player.booms_radar_key] += 1
      when "dart"        ; player.items_quantity[player.dart_key]        += 1
      when "life"        ; player.items_quantity[player.life_key]        += 1
      when "boom_shield" ; player.items_quantity[player.boom_shield_key] += 1
      when "spring"      ; player.items_quantity[player.spring_key]      += 1
      end

      @map.remove_item(item)  # item disappear on map after being picked up by player
    end
  end

  # draw background image
  def draw_background_img
    @map.background_img.draw(0, 0, 0)
  end

  # draw effect of items if they are in use(ex: boom_shield creates spinning effect around the player)
  def draw_items_effect
    all_players = @players + @map.opponent_players.select { |opponent| opponent.is_a?(PirateBoss) }
    @players.each do |player|
      next if player.disable? || self.gameover?
      direction = player.l ? "l" : (player.r ? "r" : (player.u ? "u" : (player.d ? "d" : nil)))
      player.items.each { |item_key, item| item.draw_effect(player, all_players, @map, direction) if item.in_use?(player, item_key) }   # set timer here by calling #in_use?
    end
  end

  # draw a map(based on current state)
  def draw_map
    @map.draw_map
  end

  # draw players based on their current state(alive?, dying?, dead?)
  def draw_players
    @players.each do |player|
      next if player.disable? || self.gameover?
      player_images = player.images(@players)
      if !player_images.nil?                                                          # still alive
        player_images[1].draw(player.x, player.y, 0) if player_images.length == 2     # draws bubble if player is in "dying" state
        player_images[0].draw(player.x, player.y, 0)                                  # draws player
      end
    end
  end

  # draw moving effect of players based on their speed and moving direction
  def draw_players_moving_effect
    @players.each do |player|
      next if player.disable? || self.gameover?
      if    player.l ; player.draw_moving_effect("l")
      elsif player.r ; player.draw_moving_effect("r")
      elsif player.u ; player.draw_moving_effect("u")
      elsif player.d ; player.draw_moving_effect("d")
      end
    end
  end

  # draw all booms on the map(ex: of boss and of players)
  def draw_booms
    all_players  = @map.opponent_players.select { |player| player.is_a?(PirateSlave) } + @players
    all_booms    = @players.map { |player| player.booms }.flatten

    boss = @map.opponent_players.select { |opponent| opponent.is_a?(PirateBoss) }.first
    if !boss.nil?
      all_booms   += boss.booms
      all_players += [boss]
      boss.booms.each { |boom| boom.draw(all_booms, boss, all_players, @map) }  # all players and all booms need to passed in, in case of domino exploding(booms) or change in state(player/boss got boom)
    end                                                                         # also need the author of the boom to get the boom_length of the boom later(for calculating exploding area)

    @players.each { |player| player.booms.each { |boom| boom.draw(all_booms, player, all_players, @map) } }
  end

  # draw players(not Boss) and their items, adds gray background if a player dies or if an item is no longer available(quantity = 0)
  def draw_player_items_profile
    x_offset, y_offset = 0, self.height
    draw_frame_for_player_profiles

    @players.each do |player|
      x_offset  = 0  ; y_offset -= player.height  # reset x_offset and y_offset for every new player
      x_offset  = player.draw_profile(x_offset, y_offset)
      draw_game_result(player, x_offset, y_offset) if self.gameover?
    end
  end
  
  # draw the timer that counting down the game time
  def draw_timer
    draw_start_message

    tot_sym_w    = 0
    "#{self.time_remaining / 60}:#{self.time_remaining % 60}".split("").reverse_each do |symbol|
      tot_sym_w += @symbols.gets[symbol].width
      sym_h      = @symbols.gets[symbol].height
      @symbols.gets[symbol].draw(self.screen_w - tot_sym_w, self.height - sym_h)
    end

    draw_end_message
  end

  # draw the welcome page from the SetUp class
  def draw_welcome_page
    @game.draw_welcome_page
  end

  # draw the game result when game is over
  def draw_game_result(player, x, y)
    case @game.battle_option
    when "solo" ; draw_message(player.disable? ? @symbols.lost_message : @symbols.won_message, x, y)
    when "team" ; draw_message((@players.any? { |player| !player.disable? } && @map.opponent_players.empty?) ? @symbols.won_message : @symbols.lost_message, x, y)
    end
  end

  # draw global message(ex: start game/ gameover and so on)
  def draw_message(message, x = nil, y = nil)  # default -> draw in center of screen, message will be at least 2 chars(!!)
    x_offset = x || ((self.screen_w  - ((message.length - 2) * @symbols.gets[message[0]].width)) / 2)
    y_offset = y || ((self.screen_h) / 2)

    message.split("").each do |char|
      @symbols.gets[char].draw(x_offset, y_offset, 0)
      x_offset += @symbols.gets[char].width
    end
  end

  # draw the background frame for the players profiles at the bottom of the screen
  def draw_frame_for_player_profiles
    Gosu.draw_rect(0, self.screen_h, self.screen_w, @game.total_height_of_all_players, Gosu::Color::YELLOW)
  end
  
  # draw this message when game starts for DEFAULT_MESSAGE_SHOW_TIME seconds
  def draw_start_message
    draw_message(@symbols.start_message) if @time_since_game_start < DEFAULT_MESSAGE_SHOW_TIME
  end

  # draws this message when game ends
  def draw_end_message
    if self.gameover?
      draw_message(@symbols.end_message) 
      Sound.new.game_over.play
    end
  end

  # return the remaining time of the game in seconds
  def time_remaining  #in seconds
    time_remain = (DEFAULT_GAME_DURATION - @time_since_game_start) / 1000
    time_remain > 0 ? time_remain : 0
  end

  # returns true if game is over; false otherwise
  def gameover?
    case @game.battle_option
    when "solo" ; self.time_is_up? || self.one_team_left?
    when "team" ; self.time_is_up? || @map.opponent_players.empty? || @players.all? { |player| player.disable? }
    end
  end

  # returns true if game time is up; false otherwise
  def time_is_up?
    @time_since_game_start >= DEFAULT_GAME_DURATION
  end

  # returns true of there is only 1 team left in the game ; false otherwise
  def one_team_left?  # if more than 1 team are still playing -> not done yet
    alive_players = @players.select { |player| !player.disable? }
    alive_players.all? { |player| player.team_id == alive_players.first.team_id }
  end
end

window = GameWindow.new
window.show
