require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_4'
require_relative 'pirate_boss_map_level_5'

class PirateBossMapLevel6 < PirateBossMap
    # draws level 6 map --- is identical with map 5, but pirate skills are improved with new parameters
    def generate_level_6_map
        PirateBossMapLevel5.new(@map).generate_level_5_map(100, 0, 5, 25)
    end

    # generate next move for all pirates in level 6 map --- pirates has exact same behavior as level 4
    def generate_level_6_moves
        PirateBossMapLevel4.new(@map).generate_level_4_moves
    end
end
