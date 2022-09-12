require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_4'
require_relative 'pirate_boss_map_level_7'

class PirateBossMapLevel8 < PirateBossMap
    # draws level 8 map --- is identical with map 7, but pirate skills are improved with new parameters
    def generate_level_8_map
        PirateBossMapLevel7.new(@map).generate_level_7_map(5, 10, 30)
    end

    # generate next move for all pirates in level 8 map --- pirates has exact same behavior as level 4
    def generate_level_8_moves
        PirateBossMapLevel4.new(@map).generate_level_4_moves
    end
end
