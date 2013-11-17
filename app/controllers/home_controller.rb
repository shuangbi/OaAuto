# encoding : utf-8
require 'net/http'
require 'nokogiri'
require 'rchardet19'
require 'axlsx'

class HomeController < ApplicationController
  def index
	
  end

  def start
  	#uri = URI('http://www.hkexnews.hk/listedco/listconews/mainindex/SEHK_LISTEDCO_DATETIME_TODAY_C.HTM')
	response = fetch('http://www.hkexnews.hk/listedco/listconews/mainindex/SEHK_LISTEDCO_DATETIME_TODAY_C.HTM')
	keywords = ["更改", "变更", "披露交易", "关连交易", "主要交易", "收购", "营业地址", "注册地址", "重大收购"]
	@hash = Hash.new
	noko = Nokogiri::HTML(toUtf8(response.body))
	f = File.new("log.txt", "w")
	
	Axlsx::Package.new do |p|
	  p.workbook.add_worksheet(:name => "HKEx") do |sheet|
		sheet.add_row ["Event Type", "Board Name", "PDF Source Link"]
		
		# Get all the links from response
		noko.css('tr.row0, tr.row1').each do |tablerow|
		  company_name =  tablerow.css('td')[2].text
		  notice = tablerow.css('div#hdLine').text
	      news = tablerow.css('a.news').text
	      href = tablerow.css('a.news')[0]['href']

		  keywords.each do |word|
			if notice.include? word
				sheet.add_row ["#{company_name}", "#{notice}", "#{news}"]
				@hash["#{company_name}"] = notice + ';' + news + ';' + 'http://www.hkexnews.hk' + href
				f.write("#{company_name} ++++ #{notice} ++++ #{news}++++ #{href}\n")     #=> 10
				break
			end
		  end
		end
	  end
	  p.serialize('simple.xlsx')
	  f.close
	end

	response do |format| 
		format.js
	end
  end

  def download
  end

private

	def toUtf8(_string)
	    cd = CharDet.detect(_string)      #用于检测编码格式  在gem rchardet9里
	    if cd.confidence > 0.6
	      _string.force_encoding(cd.encoding)
	    end
	    _string.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
	    return _string
	end

	def fetch(uri_str, limit = 10)
	  # You should choose better exception.
	  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

	  url = URI.parse(URI.encode(uri_str.strip))
	  puts url

	  #get path
	  headers = {}
	  
	  # set http_proxy
	  proxy_addr = Array.new
	  proxy_addr[0] = '10.13.113.144'
	  proxy_addr[1] = '10.40.14.56'

	  proxy_port = Array.new
	  proxy_port[0] = 8080
	  proxy_port[1] = 80

	  req = Net::HTTP::Get.new(url.path,headers)

	  #start TCP/IP
	  proxy_index = 1
	  # response = Net::HTTP.new(url.host, url.port, proxy_addr[proxy_index], proxy_port[proxy_index]).start { |http|
	  response = Net::HTTP.new(url.host, url.port, nil, nil).start { |http|
	    # always proxy via your.proxy.addr:8080
		http.request(req)
	  }

	  case response
	  when Net::HTTPSuccess
	    then #print final redirect to a file
	    # puts "this is location" + uri_str
	    # puts "this is the host #{url.host}"
	    # puts "this is the path #{url.path}"

	    return response
	    # if you get a 302 response
	  when Net::HTTPRedirection
	    then
	    puts "this is redirect" + response['location']
	    return fetch(response['location'], limit-1)
	  else
	    response.error!
	  end
	end
end

# res = Net::HTTP.get_response(uri)
# puts res.body if res.is_a?(Net::HTTPSuccess)

# require 'iconv' unless String.method_defined?(:encode)
# if String.method_defined?(:encode)
  # file_contents.encode!('UTF-8', 'UTF-8', :invalid => :replace)
# else
  # ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
  # file_contents = ic.iconv(file_contents)
# end

