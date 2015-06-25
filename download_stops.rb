begin
  require "uri"
  require "bundler"
  Bundler.require(:default)
rescue
  require "uri"
  require "nokogiri"
  require "oj"
  require "open-uri"
  require "selenium-webdriver"
end

download_bus_stops_xml = open("http://hakobus.atware.jp/api/busstop")
download_bus_stops = Nokogiri::XML(download_bus_stops_xml).xpath("//bs")

def search_hakodate_bus_id(stop_name)
  driver = Selenium::WebDriver.for :chrome
  driver.navigate.to("http://hakobus.jp/s_timetable01.php")
  form_table_driver = driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="contents"]/form[@name="form1"]/div/table').find_element(:xpath, '//tr[2]/td[1]/div/input[@name="stopname"]')
#  input_stop = form_table_driver.find_element(:xpath, '//tr[2]/td[1]/div/input[@name="stopname"]')
  form_table_driver.send_keys(stop_name)
  s_timetable02 = form_table_driver.find_element(:xpath, '//tr[2]/td[2]/div/input[@name="Submit"]')
  s_timetable02.click
  driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="contents"]/table[2]').find_elment(:xpath, '/tr[4]/p/input[@name="Commit"]').click
  hakodate_bus_page_path = URI.parse(driver.current_url).path
  select_bus_stop.quit
  hakodate_bus_page_path.assoc("in").last.to_i
end

bus_stops = []
download_bus_stops.each do |download_bus_stop|
  bus_stop = {}
  bus_stop["atware_id"] = download_bus_stop.attribute("gid").value.to_i
  bus_stop["name"] = download_bus_stop.attribute("gnm").value
  bus_stop["latitude"] = download_bus_stop.attribute("lat").value.to_f
  bus_stop["longitude"] = download_bus_stop.attribute("lon").value.to_f
  bus_stop["track"] = {}
  bus_stop["track"]["id"] = download_bus_stop.attribute("bid").value.to_i
  bus_stop["track"]["name"] = download_bus_stop.attribute("bnm").value
=begin
  driver = Selenium::WebDriver.for :chrome
  driver.navigate.to("http://hakobus.jp")
  driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="g-menu"]/map[@name="Map"]/area[@href="s_timetable01.php"]').click
  element = driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="contents"]/form[@name="form1"]/div[1]/table/tr[2]/td[1]/div/input[@name="stopname"]')
  element.send_keys(bus_stop["name"])
  driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="contents"]/form[@name="form1"]/div[@align="center"]/table/tr[2]/td[2]/div/input[@name="Submit"]').click
  driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="contents"]/table[2]/tr[4]/td/p/input[@name="Commit"]').click
  bus_stop["hakodate_bus_id"] = URI.decode_www_form(URI.parse(driver.current_url).path).assoc("in").last.to_i
  driver.quit
=end
  bus_stop["hakodate_bus_id"] = search_hakodate_bus_id(bus_stop["name"])
  bus_stops << bus_stop
end

File.open("bus_stops.json", "w") do |file|
  file.print(Oj.dump(bus_stops, mode: :compat))
end
