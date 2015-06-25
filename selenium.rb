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

driver = Selenium::WebDriver.for :chrome
driver.navigate.to("http://hakobus.jp/s_timetable01.php")
driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="contents"]/form[@name="form1"]/div/table').find_element(:xpath, '//tr[2]/td[1]/div/input[@name="stopname"]').send_keys("五稜郭")
driver.find_element(:xpath, '//tr[2]/td[2]/div/input[@name="Submit"]').click
driver.find_element(:xpath, '/html/body/div[@id="container"]/div[@id="contents"]/form/table').find_element(:xpath, '//tr[4]/td/p/input[@name="Commit"]').click
p driver.current_url
hakodate_bus_page_query = URI.parse(driver.current_url).query
driver.quit
p URI.decode_www_form(hakodate_bus_page_query).assoc("in").last.to_i
