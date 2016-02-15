module Cangkul
  class Player
    attr_accessor :cards
    def initialize
      @cards = []
    end

    def get_cards(cards)
      @cards += cards
      @cards = @cards.group_by(&:suit)
      @cards = @cards.values.map { |arr| arr.sort_by(&:rank) }.flatten
    end

    def take_card(card_index)
      @cards.delete_at(card_index)
    end

    def have_card?(card_index)
      @cards[card_index]
    end

    def empty_hand?
      @cards.empty?
    end
  end
end
