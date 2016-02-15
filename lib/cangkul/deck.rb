module Cangkul
  class Deck
    RANKS = (2..10).to_a + [:jack, :queen, :king, :ace]
    SUITS = [:hearts, :spades, :clubs, :diamonds]

    attr_reader :cards

    def initialize
      @cards = SUITS.product(RANKS).map do |suit, rank|
        Card.build(suit: suit, rank: rank)
      end.shuffle
    end

    def deal(n)
      @cards.shift(n)
    end

    def add_card(cards)
      @cards += cards
      @cards = cards.shuffle
    end

    def empty?
      @cards.size == 0
    end

    def total
      @cards.size
    end
  end
end
