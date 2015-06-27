begin
  require "uri"
  require "bundler"
  Bundler.require(:default)
rescue
  require "uri"
  require "nokogiri"
  require "open-uri"
  require "selenium-webdriver"
end

module Merriman
  class AtWare
    def initialize
      
    end
    
    def download_bus_stops
      Nokogiri::XML(open bus_stops_url).xpath("//bs")
    end
    
    private
    def bus_stops_url
      "http://hakobus.atware.jp/api/busstop"
    end
  end

  class HakodateBus
    def initialize
      @driver = Selenium::WebDriver.for :chrome
      @stop = {}
      @count = 0
    end

    def search_stop_id(stop_name)
      begin
	return @stop[:id] if stop_name == @stop[:name]
	return 351 if stop_name == "恵山"
	return 710 if stop_name == "東山"
	@stop.clear
	@driver.navigate.to(bus_stops_url)
	table_driver = @driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="contents"]/form[@name="form1"]/div/table')
	table_driver.find_element(:xpath, '//tr[2]/td[1]/div/input[@name="stopname"]').send_keys(stop_name)
	@driver.find_element(:xpath, '//tr[2]/td[2]/div/input[@name="Submit"]').click
	table_driver = @driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="contents"]/form/table')
	table_driver.find_element(:xpath, '//tr[4]/td/p/input[@name="Commit"]').click
	bus_stop_page_query = URI.parse(@driver.current_url).query
	@stop = {id: URI.decode_www_form(bus_stop_page_query).assoc("in").last.to_i, name: stop_name}
	@count += 1
	return @stop[:id]
      rescue Selenium::WebDriver::Error::NoSuchElementError
	return nil
      rescue Net::ReadTimeout
	@driver.quit
	change_browser
	@count = 0
	retry
      rescue
	@driver.quit
	change_browser
	@count = 0
	retry
      end
    end

    def change_browser
      if @count.even?
	driver_chrome
      else
	driver_firefox
      end
    end
    
    def quit
      @driver.quit
    end
    
    private
    def driver_chrome
      @driver = Selenium::WebDriver.for :chrome
    end

    def driver_firefox
      @driver = Selenium::WebDriver.for :firefox
    end
    
    def bus_stops_url
      "http://hakobus.jp/s_timetable01.php"
    end
  end
end
