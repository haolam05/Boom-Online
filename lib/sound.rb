class Sound
    # backgronud song
    def background
        Gosu::Song.new("./audio/background_music.mp3")
    end

    # mouse click sample
    def mouse_click
        Gosu::Sample.new("./audio/mouse_click.mp3")
    end

    # game start sample
    def game_start
        Gosu::Sample.new("./audio/game_start.mp3")
    end

    # game over sample
    def game_over
        Gosu::Sample.new("./audio/game_over.mp3")
    end

    # plant boom sample
    def plant_boom
        Gosu::Sample.new("./audio/plant_boom.wav")
    end

    # boom explode sample
    def boom_explode
        Gosu::Sample.new("./audio/boom_explode.mp3")
    end
end
