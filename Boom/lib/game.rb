require 'gosu'
require_relative 'player'
require_relative 'boom'

DEFAULT_SCREEN_WIDTH    = 640
DEFAULT_SCREEN_HEIGHT   = 480
DEFAULT_SCREEN_CAPTION  = "Boom Online"

class GameWindow < Gosu::Window
  def initialize
    super DEFAULT_SCREEN_WIDTH, DEFAULT_SCREEN_HEIGHT, fullscreen: false
    self.caption    = DEFAULT_SCREEN_CAPTION
    @background_img = Gosu::Image.new("./images/background.png", :tileable => true)
    @start_time     = 0
    @players        = [
      Player.new("./images/characters/green.png" , Gosu::KbLeft, Gosu::KbRight, Gosu::KbUp, Gosu::KbDown, Gosu::KB_RIGHT_SHIFT), 
      Player.new("./images/characters/orange.png", Gosu::KbA   , Gosu::KbD    , Gosu::KbW , Gosu::KbS   , Gosu::KB_LEFT_SHIFT) ,
    ]

    @players[0].speed = 10
  end

  # called once every {#update_interval} milliseconds
  def update
    update_player_and_boom_positions
  end

  # is called after #update
  def draw
    draw_background_img
    draw_players
    draw_booms
  end

  def button_down(button_id)
    case button_id
    when Gosu::KbEscape       ; close
    when Gosu::MS_WHEEL_DOWN  ; self.width  -= 100  ; self.height -= 100
    when Gosu::MS_WHEEL_UP    ; self.width  += 100  ; self.height += 100
    when Gosu::MS_MIDDLE      ; self.fullscreen = !self.fullscreen?
    end

    @players.each do |player|
      case button_id
      when player.l_key ; player.l = true
      when player.r_key ; player.r = true
      when player.u_key ; player.u = true
      when player.d_key ; player.d = true
      when player.b_key ; player.b = true
      end
    end
  end

  def button_up(button_id)
    @players.each do |player|
      case button_id
      when player.l_key ; player.l = false
      when player.r_key ; player.r = false
      when player.u_key ; player.u = false
      when player.d_key ; player.d = false
      when player.b_key ; player.b = false
      end
    end
  end

private
  def within_hor_frame?(position)
    position.between?(0, self.width)
  end

  def within_ver_frame?(position)
    position.between?(0, self.height)
  end

  def update_player_and_boom_positions
    @players.each do |player|
      next if player.disable?
      if    player.l && within_hor_frame?(player.x - 1)                                ; player.x -= (!player.got_boom ? player.speed : player.speed / player.slow_down_factor) if !player.obstacle_left?(@players)
      elsif player.r && within_hor_frame?(player.x + player.normal_image.width  + 1)   ; player.x += (!player.got_boom ? player.speed : player.speed / player.slow_down_factor) if !player.obstacle_right?(@players)
      elsif player.u && within_ver_frame?(player.y - 1)                                ; player.y -= (!player.got_boom ? player.speed : player.speed / player.slow_down_factor) if !player.obstacle_up?(@players)   
      elsif player.d && within_ver_frame?(player.y + player.normal_image.height + 1)   ; player.y += (!player.got_boom ? player.speed : player.speed / player.slow_down_factor) if !player.obstacle_down?(@players)
      elsif player.b                                                                   ; player.plant_boom if !player.got_boom && (player.booms.length < player.num_booms_allowed)
      end
    end
  end

  def draw_background_img
    @background_img.draw(0, 0, 0)
  end

  def draw_players
    @players.each do |player|
      player_images = player.images
      if !player_images.nil?
        player_images[1].draw(player.x, player.y, 0) if player_images.length == 2
        player_images[0].draw(player.x, player.y, 0)
      end
    end
  end

  def draw_booms
    @players.each do |player| 
      player.booms.each do |boom|
        boom_images = boom.images     # why not call boom.images every time? ---> 1)more convinient ; 2)every time boom.images is called, boom.explode might be called as well
        if !boom_images.nil?          # ===> ideally, called boom.images once for every boom and use it everywhere else
          if boom_images.length == 1
            draw_boom(                    # normal boom
              boom.x                                        , 
              boom.y                                        ,
              1                                             ,
              boom_images.first                             ,
              0                                             ,
              0                                             ,
              []                                            ,
              @players                                      ,
              false                                         ,
              boom
            )
          elsif boom_images.length == 2   # exploded boom
            draw_boom(  # horizontal
              boom.x - (boom.length * boom_images[0].width) ,
              boom.y                                        ,
              boom.length * 2 + 1                           ,
              boom_images[0]                                ,
              boom_images[0].width                          , 
              0                                             ,
              player.booms                                  ,
              @players                                      , 
              true                                          , 
              boom
            )
            draw_boom(  # verticcal
              boom.x                                        ,
              boom.y - (boom.length * boom_images[1].height),
              boom.length * 2 + 1                           ,
              boom_images[1]                                ,
              0                                             ,
              boom_images[1].height                         ,
              player.booms                                  , 
              @players                                      , 
              true                                          , 
              boom
            )
          end
        else                            # boom.images is nil ---> it means that boom has finished exploding ---> remove it from player's boom list
          player.remove_boom(boom)
        end
      end
    end
  end

  def draw_boom(x, y, n, img, w, h, booms, players, boom_is_exploded, boom)
    n.times do
      img.draw(x, y, 0)
      booms.each   { |boom  | boom.explode_now = true if boom.touch?(x, w, y, h) }
      players.each { |player| player.got_boom  = true if boom_is_exploded && !player.got_boom && player.overlap_with_boom?(x, boom.width, y, boom.height) }
      x += w
      y += h
    end
  end
end

window = GameWindow.new
window.show
