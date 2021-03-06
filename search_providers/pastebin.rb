#     Contributions by Nick Kleck
#         pastebin search provider created by Nick Kleck
#         requires a pastebin pro account with IP of Scumblr server whitelisted 
#
#     Copyright 2014 Netflix, Inc.  
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.

require 'uri'
require 'net/http'
require 'json'

class SearchProvider::Pastebin < SearchProvider::Provider
  def self.provider_name
    "Pastebin Search"
  end

  def self.options
      {
        :results=>{name: "Max search", description: "Specify the number of recent posts to Pastebin to search, limit: 500 | blank: 50", required: false}
      }
    end

  def initialize(query, options={})
      super
          @options[:results] = @options[:results].blank? ? 50 : @options[:results]
  end

  def run
    url = URI.escape('http://pastebin.com/api_scraping.php?limit=' + @options[:results].to_s)

    response = Net::HTTP.get_response(URI(url))
    results = []
    if response.code == "200" # this may need to be in quotes in the scumblr cause its a different get maybe?
      search_results = JSON.parse(response.body)
      search_results.each do |a| # this finds itmes in the array
        paste_page = HTTParty.get(a["scrape_url"])
        if paste_page.body[@query]
          results <<
          {
            :title => a['title'],
            :url => a['scrape_url'],
            :domain => "pastebin.com"
          }
        end
      end
    end
    return results
  end
end
