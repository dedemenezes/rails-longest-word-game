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
    grid_word = params[:grid_word].gsub(" ", "")
    attempt = params[:user_word]
    @result = { content: "", score: ""}

    if word_exist?(attempt)
      attempt_hash = hash_counter(attempt)
      grid_hash = hash_counter(grid_word)
      
      in_the_grid = check_attempt_grid(attempt_hash, grid_hash)
      elapsed_time = elapsed_time(@start_time, @end_time)
      
      results_array = check_result?(in_the_grid, attempt, elapsed_time)
      @result[:content] = results_array[0]
      @result[:score] = results_array[1]
    else
      @result[:content] = "Sorry but <strong>#{attempt.upcase}</strong> is not an english word"
      @result[:score] = 0; 
    end
   
    @result
  end

  def elapsed_time (start_time, end_time)
    end_time - start_time
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

  def check_attempt_grid(attempt_hash, grid_hash)
    in_the_grid = []
    attempt_hash.map do |k, v| 
      in_the_grid << (grid_hash[k.to_sym] >= v)
    end
    in_the_grid
  end

  def checking_score(attempt, elapsed_time)
    word_points = attempt.size * 2
    time_points = elapsed_time.round(2) * 4
    (word_points / time_points ) * 100
  end

  def check_result?(in_the_grid, attempt, elapsed_time)
    if in_the_grid.include? false
      content = "Sorry but <strong>#{attempt.upcase}</strong> can't be build out of #{grid_array.join(", ").upcase}"
      points = 0
    else
      content = "<strong>CONGRATULATIONS!</strong> #{attempt.upcase} is a valid word and all letters are inside the grid"
      points = checking_score(attempt, elapsed_time)
    end
    [content, points]
  end


end
