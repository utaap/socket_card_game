require "json"

module Cangkul
  class Game
    attr_accessor :summoned, :players, :deck
    def initialize(n_player=2, n_card=5)
      @n_player       = n_player
      @n_card         = n_card
      @deck           = Deck.new
      @garbage        = []
      @summoned       = {}
      @players        = {}
      @reference      = nil
      @last_winner_id = nil
      @game_ended     = false
    end

    def update(&block)
      # All Player already summoned a card
      return if @game_ended

      messages = {}
      if @summoned.size == @n_player
        @summoned = @summoned.sort_by{ |key, value| value.rank }.reverse.to_h
        @last_winner_id = @summoned.keys.first
        @garbage += @summoned.values

        messages["all"] = "Card ranking :\n"
        @summoned.each do |id, card|
          messages["all"] += "#{id} : #{card.to_s}\n"
        end

        messages[@last_winner_id] = "You are the winner of this turn, next card you summoned will be the reference card."

        block.call("", messages) if block
        @summoned.clear
        # Send round winner player a message to summon and a reference card
      end

      # Deck is Empty
      if @deck.empty?
        @deck.add_cards(@garbage)
        @garbage.clear
      end

      # Player all present, start the game
      if @players.size == @n_player && !@reference
        @reference = @deck.deal(1).first

        messages["all"] = "Reference card has been summoned : #{@reference.to_s}"
        block.call("", messages) if block
      end

      # If only one player remain
      if @players.size == 1 &&  @reference
        messages[@players.keys[0]] = "You lose. :("
        messages["all"] = "Game Over!"
        @game_ended = true
        block.call("ENDED", messages)
      end
    end

    def summon(id, card_idx, &block)
      messages = {}
      if @game_ended
        messages[id] = "Game Already Ended!"
        block.call("ENDED", messages)
        return
      end

      if !@players[id]
        messages[id] = "You not registered in this game."
        block.call("ERROR", messages)
        return
      end

      card = @players[id].have_card?(card_idx)

      valid = !card.nil?
      if !valid
        messages[id] = "You cannot summon that card."
        block.call("ERROR", messages)
        return
      elsif @last_winner_id && (@last_winner_id == id)
        @reference = card
      end

      valid = !@reference.nil? && @summoned[id].nil? && (card.suit == @reference.suit)
      if valid
        @players[id].take_card(card_idx)
        messages[id] = "Your remaining cards : " + @players[id].cards.join(" ")
        messages["other"] = "#{id} summoned #{card.to_s}"

        @summoned[id] = card
        if card == @reference
          messages["other"] = "Last turn winner, " + messages["other"] + " as reference card"
          @last_winner_id = nil
        end

        if @players[id].empty_hand?
          messages[id] += "\nCongratulation, you are not the loser. :)"
          @players.delete(id)
        end

        block.call("ACCEPTED", messages)
      else
        messages[id] = "You cannot summon #{card.to_s}"
        block.call("ERROR", messages)
      end
    end

    def see_cards(id, &block)
      messages = {}
      if @game_ended
        messages[id] = "Game Already Ended!"
        block.call("ENDED", messages)
        return
      end

      if @players[id]
        messages[id] = "Your remaining cards : " + @players[id].cards.join(" ")
        block.call("ACCEPTED", messages)
      else
        messages[id] = "You not registered in this game."
        block.call("ERROR", messages)
      end
    end

    def take_a_card(id, &block)
      # Check solution in your hand
      messages = {}
      if @game_ended
        messages[id] = "Game Already Ended!"
        block.call("ENDED", messages)
        return
      end

      if @players[id]
        card = @deck.deal(1)
        @players[id].get_cards(card)

        messages[id] = "Your remaining cards : " + @players[id].cards.join(" ")
        messages["other"] = "#{id} take a card from deck"
        block.call("ACCEPTED", messages)
      else
        messages[id] = "You not registered in this game."
        block.call("ERROR", messages)
      end
    end

    def add_player(id, &block)
      # Case : Adding New Player with same ID
      messages = {}
      if @game_ended
        messages[id] = "Game Already Ended!"
        block.call("ENDED", messages)
        return
      end

      if @players[id]
        messages[id] = "#{id} is used by other player."
        block.call("ERROR", messages)
        return
      end

      # Case : No room for new player
      if @players.size < @n_player
        @players[id] = Player.new
        @players[id].get_cards(@deck.deal(@n_card))

        messages[id] = "Welcome to the game.\nYour Card : " + @players[id].cards.join(" ")+"\nType '-h' or '--help' to see command list."
        messages["other"] = "#{id} joined the game."

        block.call("ACCEPTED", messages)
        return
      else
        messages[id] = "Sorry, you cannot enter this game."
        block.call("ERROR", messages)
        return
      end
    end

  end
end
