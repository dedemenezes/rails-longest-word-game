require 'open-uri'
require 'json'
require 'time'

class GamesController < ApplicationController

  def new
    @start_time = ""
    @letters = []
    10.times { @letters.push(('a'..'z').to_a.sample)}
  end

  def score
    @start_time = Time.parse(params[:start])
    @end_time = Time.now
    @elapsed_time = @end_time - @start_time

    grid_word = params[:grid_word].gsub(" ", "")
    attempt = params[:user_word]
    @result = { content: "", score: ""}

    if word_exist?(attempt)
      attempt_hash = hash_counter(attempt)
      grid_hash = hash_counter(grid_word)

      if fail_attempt_grid(attempt_hash, grid_hash).include? false
        @result[:content] = "Sorry but <strong>#{attempt.upcase}</strong> can't be build out of #{grid_array.join(", ").upcase}"
        @result[:score] = 0
      else
        @result[:content] = "<strong>CONGRATULATIONS!</strong> #{attempt.upcase} is a valid word and all letters are inside the grid"
        @result[:score] = checking_score(attempt, @elapsed_time)
      end
    else
      @result[:content] = "Sorry but <strong>#{attempt.upcase}</strong> is not an english word"
      @result[:score] = 0;
    end
    @result
  end

  def word_exist?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word = JSON.parse(URI.open(url).read)
    word['found']
  end

  def hash_counter(string)
    letters = {}
    string.each_char { |letter| letters[letter.to_sym] = string.count(letter) }
    letters
  end

  def in_the_grid?(attempt, grid_word)
    attempt_hash = hash_counter(attempt)
    grid_hash = hash_counter(grid_word)
    fail_attempt_grid(attempt_hash, grid_hash).include? false
  end

  def fail_attempt_grid(attempt_hash, grid_hash)
    attempt_hash.map { |letter, amount| (grid_hash[letter.to_sym] >= amount) }
  end

  def checking_score(attempt, elapsed_time)
    word_points = attempt.size * 2
    time_points = elapsed_time.round(2) * 4
    (word_points / time_points ) * 100
  end
end
