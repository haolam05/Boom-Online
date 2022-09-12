require_relative 'pirate_boss_map'
require_relative 'pirate_boss_map_level_9'
require_relative 'pirate_boss_map_level_13'

class PirateBossMapLevel14 < PirateBossMap
    # draws level 14 map
    def generate_level_14_map
        PirateBossMapLevel13.new(@map).generate_level_13_map(0, 0, 25, 25, 1, 65)
    end

    # generate next move for all pirates in level 14 map --- pirates has exact same behavior as level 9, but with higher random_occupied percentage during "random attack"
    def generate_level_14_moves
        PirateBossMapLevel9.new(@map).generate_level_9_moves(10)
    end
end
