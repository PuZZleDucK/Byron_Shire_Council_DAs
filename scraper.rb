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

#search_page.forms.each do |form|
#  puts "form: #{form}"
#    form.elements.each do |el| # fields dateFrom and dateTo use dd/mm/yyyy
#      puts "   e: #{el.name}"
#    end
#end

# search for date fields and look over a few days
search_page.forms[1].elements[1].value = "#{(Date.today-7).strftime("%d/%m/%Y")}"
search_page.forms[1].elements[2].value = "#{(Date.today+7).strftime("%d/%m/%Y")}"
results = search_page.forms[1].submit

results.links.each do |link|
  if link.href["/eservice/daEnquiryDetails.do"] then
    puts "L: #{link.href}"
    application_page = agent.get(link.href);
    puts "APPLICATION: #{application_page.body[12000..12300]}"
    address = application_page.search("/html/body/div[1]/div[2]/div[2]/div/div[2]/div[2]/div/div/div[3]/p[1]/span[2]")[0]
    description = application_page.search("/html/body/div[1]/div[2]/div[2]/div/div[2]/div[2]/div/div/div[3]/p[2]/span[2]")[0]
    council_reference = application_page.search("/html/body/div[1]/div[2]/div[2]/div/div[2]/div[2]/div/div/div[3]/p[3]/span[2]")[0]
    date_received = application_page.search("/html/body/div[1]/div[2]/div[2]/div/div[2]/div[2]/div/div/div[3]/p[4]/span[2]")[0]

	record = {
		'council_reference' => council_reference.text, # multiple notices can have the same ref...
		'address' => address.text,
		'description' => description.text,
		'info_url' => link.href,
		'comment_url' => link.href,
		'date_scraped' => date_scraped
	}
    puts "\nRECORD: #{record}\n\n"
  end
end

#	if (ScraperWiki.select("* from data where `council_reference` LIKE '#{record['council_reference']}'").empty? rescue true)
#	  ScraperWiki.save_sqlite(['council_reference'], record)
#      puts "Storing: #{record['council_reference']}"
#	else
#	  puts "Skipping already saved record " + record['council_reference']
#	end
#  end  



