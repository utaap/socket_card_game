module Cangkul
  class Card
    def self.build(params = {})
      default = { suit: :hearts, rank: 1 }
      new(*default.merge(params).values)
    end

    private_class_method :new
    attr_reader :rank, :suit

    def initialize(suit, rank)
      @suit = suit
      @rank = { ace: 14, jack: 11, queen: 12, king: 13 }.fetch(rank) { rank }
    end

    def ==(other)
      suit == other.suit && rank == other.rank
    end

    def to_s
      r = { 14 => 'A', 11 => 'J', 12 => 'Q', 13 => 'K'}.fetch(rank) { rank.to_s }
      s = { hearts: "♥", spades: "♠", diamonds: "♦", clubs: "♣", }.fetch(suit)
      "#{r.upcase}#{s}"
    end

    def self.from_string(value)
      short_suit = value[-1]
      suit = { "♥" => :hearts, "♦" => :diamonds, "♠" => :spades, "♣" => :clubs }.fetch(short_suit)
      rank = { 'A' => :ace, 'K' => :king, 'Q' => :queen, 'J' => :jack }.fetch(value[0]) { value[0..-2].to_i }
      Card.build(suit: suit, rank: rank)
    end
  end
end
