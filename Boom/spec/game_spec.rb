require 'game'

describe GameWindow do
    subject(:g) { GameWindow.new }

    describe '#initialize' do
        it 'sets correct window dimension and caption' do
            expect(g.width).to   eq 640
            expect(g.height).to  eq 480
            expect(g.caption).to eq "Gosu Tutorial Game"
        end
    end

    describe '#update' do
    end

    describe '#draw' do
    end
end