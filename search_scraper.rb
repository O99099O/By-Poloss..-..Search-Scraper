require 'httparty'
require 'nokogiri'
require 'uri'

STDOUT.sync = true

# ============= INPUT HANDLER =============
print "Masukkan kata kunci pencarian:\n> "
keyword = STDIN.read.strip
exit if keyword.empty?

encoded_keyword = URI.encode_www_form_component(keyword)

# ============= SEARCH ENGINES CONFIG =============
ENGINES = {
  "BING" => {
    url: "https://www.bing.com/search?q=#{encoded_keyword}",
    selector: 'li.b_algo h2 a',
    attr: 'href'
  },
  "DUCKDUCKGO" => {
    url: "https://duckduckgo.com/html/?q=#{encoded_keyword}",
    selector: 'a.result__a',
    attr: 'href'
  },
  "YANDEX" => {
    url: "https://yandex.com/search/?text=#{encoded_keyword}",
    selector: 'a.Link.Link_theme_outer.Path-Item',
    attr: 'href'
  }
}

# ============= HTTP HEADERS =============
HEADERS = {
  "User-Agent"      => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
  "Accept"          => "text/html",
  "Accept-Language" => "en-US,en;q=0.9"
}

# ============= CORE SCRAPER METHOD =============
def scrape(url, headers, selector, attr)
  response = HTTParty.get(url, headers: headers, timeout: 15)
  document = Nokogiri::HTML(response.body)

  results = []
  document.css(selector).each do |node|
    value = node[attr]
    results << value if value && !value.empty?
  end

  results.uniq
end

puts "\n========== HASIL PENCARIAN ==========\n"

# ============= ENGINE EXECUTION LOOP =============
ENGINES.each do |engine_name, config|
  puts "[#{engine_name}]"

  urls = scrape(
    config[:url],
    HEADERS,
    config[:selector],
    config[:attr]
  )

  urls.each { |link| puts link }
  puts
end

puts "========== SELESAI =========="
