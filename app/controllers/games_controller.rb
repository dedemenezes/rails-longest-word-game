require 'open-uri'
require 'json'

class GamesController < ApplicationController
  
  def new
    @letters = []
    10.times { @letters.push(('a'..'z').to_a.sample)}
  end

  def score
    @grid_array = params[:letters].split
    @attempt = params[:user_word]
    url = "https://wagon-dictionary.herokuapp.com/#{@attempt}"
    @word = JSON.parse(URI.open(url).read)
    if @word['found']
      @attempt_array = @attempt.chars.map { |letter| letter }

      @user_hash = {}
      @attempt_array.each do |letter|
        @user_hash[letter.to_sym] = @attempt_array.count(letter)
      end

      @grid_hash = {}
      @grid_array.each do |letter|
        @grid_hash[letter.to_sym] = @grid_array.count(letter)
      end
      answer_check = []
      answer_check = @user_hash.map do |k, v| 
        answer_check << (@grid_hash[k.to_sym] >= v)
      end
      
      if answer_check.include? false
        @attempt_check = "Sorry but <strong>#{@attempt.upcase}</strong> can't be build out of #{@grid_array.join(", ").upcase}"
      else
        @attempt_check = "CONGRATULATIONS! <strong>#{@attempt.upcase}</strong> is a valid word and all letters are inside the grid"
      end
    else
      @attempt_check = "Sorry but <strong>#{@attempt.upcase}</strong> is not an english word"
    end
    @attempt_check
  end
end
