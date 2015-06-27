begin
  require "uri"
  require "bundler"
  Bundler.require(:default)
rescue
  require "uri"
  require "nokogiri"
  require "oj"
  require "open-uri"
end

bus_statuses_url = "http://hakobus.atware.jp/api/approachInfo?from=14007&to=14013&max=20"
download_bus_statuses = Nokogiri::XML(open bus_statuses_url).xpath("//aprch")
download_bus_statuses.each do |bus_status|
  puts "行き先: #{bus_status.attribute("db").value}"
  puts "系統: #{bus_status.attribute("lin").value}"
  puts "時刻表予定到着: #{bus_status.attribute("at").value}"
  if bus_status.attribute("cnd").value == "まもなく到着します"
    puts "到着: #{Time.now.strftime("%R")}"
  elsif bus_status.attribute("cnd").value == "到着済み"
    puts "到着しています。"
  elsif bus_status.attribute("cnd").value == "*****"
    puts "まだ出発してません。"
  elsif bus_status.attribute("cnd").value == "定刻発車の予定"
    puts "時刻表予定到着: #{bus_status.attribute("at").value}"
  elsif bus_status.attribute("cnd").value == ""
    puts "わからん"
  else
    puts "到着: #{bus_status.attribute("cnd").value.slice(/\d{1,3}/)}"
  end
  puts ""
end
