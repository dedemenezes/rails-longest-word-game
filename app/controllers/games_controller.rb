require 'open-uri'
require 'json'

class GamesController < ApplicationController
  
  def new
    @letters = []
    10.times { @letters.push(('a'..'z').to_a.sample)}
  end

  def score
    @grid_array = params[:letters].split
    @answer = params[:user_word]
    url = "https://wagon-dictionary.herokuapp.com/#{@answer}"
    user_serialized = URI.open(url).read
    @word = JSON.parse(user_serialized)
    if @word['found']
      @user_array = []
      @answer.each_char { |letter| @user_array << letter }

      @user_hash = {}
      @user_array.each do |letter|
        @user_hash[letter.to_sym] = @user_array.count(letter)
      end

      @grid_hash = {}
      @grid_array.each do |letter|
        @grid_hash[letter.to_sym] = @grid_array.count(letter)
      end
      
      @grid_hash.each { |k, v| puts @user_hash[k.to_sym] == v }
      raise


      
      if @user_array.empty?
        @answer_check = "CONGRATULATIONS! <strong>#{@answer.upcase}</strong> is a valid word and all letters are inside the grid"
      else
        @answer_check = "Sorry but <strong>#{@answer.upcase}</strong> can't be build out of #{@grid.join(", ").upcase}"
      end
    else
      @answer_check = "Sorry but <strong>#{@answer.upcase}</strong> is not an english word"
    end
    @answer_check
  end
end
