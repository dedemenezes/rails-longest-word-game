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
    start_time = Time.parse(params[:start])
    grid_word = params[:grid_word].gsub(" ", "")
    attempt = params[:user_word]
    if word_exist?(attempt)
      @attempt_hash = {}
      @attempt_hash = hash_counter(attempt)
      
      @grid_hash = {}
      @grid_hash = hash_counter(grid_word)

      @answer_check = []
      @attempt_hash.map do |k, v| 
        @answer_check << (@grid_hash[k.to_sym] >= v)
      end
      
      @attempt_check = check_result?(@answer_check, attempt)
    else
      @attempt_check = "Sorry but <strong>#{attempt.upcase}</strong> is not an english word"
    end
    @points = checking_score(attempt, start_time)
    @result = { content: @attempt_check, score: @points }

    return @result
  end

  def word_exist?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word = JSON.parse(URI.open(url).read)
    word['found']
  end

  def hash_counter(str)
    hash = {}
    str.each_char { |c| hash[c.to_sym] = str.count(c) }

    hash
  end

  def check_result?(answer_array, attempt)
    if answer_array.include? false
      result = "Sorry but <strong>#{attempt.upcase}</strong> can't be build out of #{grid_array.join(", ").upcase}"
    else
      result = "<strong>CONGRATULATIONS!</strong> #{attempt.upcase} is a valid word and all letters are inside the grid"
    end
    result
  end

  def checking_score(attempt, start_time)
    word_points = attempt.size * 2
    elapsed_time = Time.now - start_time
    score = (word_points / elapsed_time.round(2)) * 100
  end
end
