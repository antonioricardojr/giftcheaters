require 'amazon/ecs'
require 'json'
require 'crack'
require 'nokogiri'
require 'json'


class SearchController < ApplicationController

	NUM_RESULTS = 6

	Amazon::Ecs.configure do |options|
		options[:associate_tag] = 'wwwgiftchea00-20'
		options[:AWS_access_key_id] = 'AKIAJRSPMFIZ3GWWT4FA'
		options[:AWS_secret_key] = 'V+PR00bo2AtLkpo+P4Bf5BfnR283x3IS4UZtBFIX'
	end

	def item_search

	# As a convenience, some of the search indices are combinations of other search indices, for example:

	# All—Searches through all search indices. 
	# Only five pages of items can be returned where each page contains up to five items
    # Blended—Combines the following search indices: DVD, Electronics, Toys, VideoGames, PCHardware, Tools, SportingGoods, 
    # Books, Software, Music, GourmetFood, Kitchen, and Apparel search indices
	# Music—Combines Classical, DigitalMusic, and MusicTracks search indices
	# Video—Combines DVD and VHS search indices

		@name = params[:item_name]
		@category = params[:category]

		#@categories = @category.split('&')

		@res = Amazon::Ecs.item_search(@name, 
		{:response_group => 'Medium',  
			:search_index => @category,
			:country => 'us'
			
			})

		
		@res_j = parse_xml_to_json(@res)
  		
  		
    end

		
	end

	def first_result(res)
		return res[0]
	end

	def define_category(f_category)
	a_category = "All"

	if f_category == "Movie"
		a_category = "Video"

	elsif f_category == "Musician/band"
		a_category = "Music"

	elsif f_category == "Author"
		a_category = "Books"

	elsif f_category == "Book"
		a_category = "Books"
	elsif f_category == "Actor/director"
		a_category = "Video"
	end
	return a_category
	end

	def firsts_results(results)
	res = []
	 if(results.total_results > NUM_RESULTS)
		num_results = 6
	 else
	 	num_results = results.total_results
	end

	i = 0
	
	results.items.each do |item|
		if(i < num_results)
			res.push(item)
			i = i + 1	
		end
	end
		return res
	end

	def parse_xml_to_json(res)
		@str = ""
		res.items.each do |item|

			@str += item.to_s

		end

		str_hash = Crack::XML.parse(@str)
		str_json = str_hash.to_json

		File.open("public/temp.json","w") do |f|
  		f.write(str_json)
  		f.close
  		end

		return str_json
	end

