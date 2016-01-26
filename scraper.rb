#!/usr/bin/env ruby
require 'scraperwiki'
require 'mechanize'

base_url = "https://eservices.byron.nsw.gov.au/eservice/daEnquiryInit.do?doc_type=10&fromDate=01/01/2006&nodeNum=1156"

agent = Mechanize.new
agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
search_page = agent.get(base_url)
date_scraped = Date.today.to_s
comment_url = ""
puts "Date: #{date_scraped}"
puts "Date-1: #{(Date.today-1).strftime("%d/%m/%Y")}"
puts "Date+1: #{(Date.today+1).strftime("%d/%m/%Y")}"

def extract_address_and_description(str)
# delimit the address and description with " at "
  str.split(" at ")
end


# search for date fields and look over a few days
search_page.forms.each do |form|
  puts "form: #{form}"
    form.elements.each do |el| # fields dateFrom and dateTo use dd/mm/yyyy
      puts "   e: #{el.name}"
    end
end

search_page.forms[1].elements[1].value = "#{(Date.today-7).strftime("%d/%m/%Y")}"
search_page.forms[1].elements[2].value = "#{(Date.today+7).strftime("%d/%m/%Y")}"

results = search_page.forms[1].submit

results.links.each do |link|
  if link.href["/eservice/daEnquiryDetails.do"] then
    puts "L: #{link.href}"
    application_page = agent.get(link.href);
    puts "APPLICATION: #{application_page.body[12000..12300]}"
  end
end

#	record = {
#		'council_reference' => link.text[0, 11], # multiple notices can have the same ref...
#		'address' => "#{description_address[1]}, QLD",
#		'description' => description_address[0],
#		'info_url' => link.href,
#		'comment_url' => comment_url,
#		'date_scraped' => date_scraped
#	}
#	if (ScraperWiki.select("* from data where `council_reference` LIKE '#{record['council_reference']}'").empty? rescue true)
#	  ScraperWiki.save_sqlite(['council_reference'], record)
#      puts "Storing: #{record['council_reference']}"
#	else
#	  puts "Skipping already saved record " + record['council_reference']
#	end
#  end  



