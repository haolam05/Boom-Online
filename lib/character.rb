DEFAULT_0_IMG_PATH           = "./images/symbols/0.png"
DEFAULT_1_IMG_PATH           = "./images/symbols/1.png"
DEFAULT_2_IMG_PATH           = "./images/symbols/2.png"
DEFAULT_3_IMG_PATH           = "./images/symbols/3.png"
DEFAULT_4_IMG_PATH           = "./images/symbols/4.png"
DEFAULT_5_IMG_PATH           = "./images/symbols/5.png"
DEFAULT_6_IMG_PATH           = "./images/symbols/6.png"
DEFAULT_7_IMG_PATH           = "./images/symbols/7.png"
DEFAULT_8_IMG_PATH           = "./images/symbols/8.png"
DEFAULT_9_IMG_PATH           = "./images/symbols/9.png"
DEFAULT_A_IMG_PATH           = "./images/symbols/a.png"
DEFAULT_B_IMG_PATH           = "./images/symbols/b.png"
DEFAULT_C_IMG_PATH           = "./images/symbols/c.png"
DEFAULT_E_IMG_PATH           = "./images/symbols/e.png"
DEFAULT_G_IMG_PATH           = "./images/symbols/g.png"
DEFAULT_I_IMG_PATH           = "./images/symbols/i.png"
DEFAULT_L_IMG_PATH           = "./images/symbols/l.png"
DEFAULT_M_IMG_PATH           = "./images/symbols/m.png"
DEFAULT_N_IMG_PATH           = "./images/symbols/n.png"
DEFAULT_O_IMG_PATH           = "./images/symbols/o.png"
DEFAULT_R_IMG_PATH           = "./images/symbols/r.png"
DEFAULT_S_IMG_PATH           = "./images/symbols/s.png"
DEFAULT_T_IMG_PATH           = "./images/symbols/t.png"
DEFAULT_V_IMG_PATH           = "./images/symbols/v.png"
DEFAULT_W_IMG_PATH           = "./images/symbols/w.png"
DEFAULT_COLON_IMG_PATH       = "./images/symbols/colon.png"
DEFAULT_EXCLAMATION_IMG_PATH = "./images/symbols/!.png"

class Character
    attr_reader :symbols

    def initialize
        @symbols = {
            "0" => Gosu::Image.new(DEFAULT_0_IMG_PATH          , :tileable => true),
            "1" => Gosu::Image.new(DEFAULT_1_IMG_PATH          , :tileable => true),
            "2" => Gosu::Image.new(DEFAULT_2_IMG_PATH          , :tileable => true),
            "3" => Gosu::Image.new(DEFAULT_3_IMG_PATH          , :tileable => true),
            "4" => Gosu::Image.new(DEFAULT_4_IMG_PATH          , :tileable => true),
            "5" => Gosu::Image.new(DEFAULT_5_IMG_PATH          , :tileable => true),
            "6" => Gosu::Image.new(DEFAULT_6_IMG_PATH          , :tileable => true),
            "7" => Gosu::Image.new(DEFAULT_7_IMG_PATH          , :tileable => true),
            "8" => Gosu::Image.new(DEFAULT_8_IMG_PATH          , :tileable => true),
            "9" => Gosu::Image.new(DEFAULT_9_IMG_PATH          , :tileable => true),
            "a" => Gosu::Image.new(DEFAULT_A_IMG_PATH          , :tileable => true),
            "b" => Gosu::Image.new(DEFAULT_B_IMG_PATH          , :tileable => true),
            "c" => Gosu::Image.new(DEFAULT_C_IMG_PATH          , :tileable => true),
            "e" => Gosu::Image.new(DEFAULT_E_IMG_PATH          , :tileable => true),
            "g" => Gosu::Image.new(DEFAULT_G_IMG_PATH          , :tileable => true),
            "i" => Gosu::Image.new(DEFAULT_I_IMG_PATH          , :tileable => true),
            "l" => Gosu::Image.new(DEFAULT_L_IMG_PATH          , :tileable => true),
            "m" => Gosu::Image.new(DEFAULT_M_IMG_PATH          , :tileable => true),
            "n" => Gosu::Image.new(DEFAULT_N_IMG_PATH          , :tileable => true),
            "o" => Gosu::Image.new(DEFAULT_O_IMG_PATH          , :tileable => true),
            "r" => Gosu::Image.new(DEFAULT_R_IMG_PATH          , :tileable => true),
            "s" => Gosu::Image.new(DEFAULT_S_IMG_PATH          , :tileable => true),
            "t" => Gosu::Image.new(DEFAULT_T_IMG_PATH          , :tileable => true),
            "v" => Gosu::Image.new(DEFAULT_V_IMG_PATH          , :tileable => true),
            "w" => Gosu::Image.new(DEFAULT_W_IMG_PATH          , :tileable => true),
            ":" => Gosu::Image.new(DEFAULT_COLON_IMG_PATH      , :tileable => true),
            "!" => Gosu::Image.new(DEFAULT_EXCLAMATION_IMG_PATH, :tileable => true)
        }
    end

    # returns "start!!" word
    def start_message
        "start!!"   
    end

    # returns "gameover!!" word 
    def end_message   
        "gameover!!" 
    end

    # returns "lost!!" word
    def lost_message  
        "lost!!"     
    end

    # returns "won!!" word
    def won_message   
        "won!!"      
    end

    # returns given message with italic tag
    def add_italic(message)
        "<i>#{message}</i>"
    end

    # returns given message with bold tag
    def add_bold(message)
        "<b>#{message}</b>"
    end

    alias_method :gets, :symbols
end
