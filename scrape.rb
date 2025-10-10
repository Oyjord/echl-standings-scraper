# scrape.rb
require 'nokogiri'
require 'open-uri'
require 'json'

URL = 'https://swamprabbits.com/team/standings'
SOUTH_DIVISION_TEAMS = [
  "Greenville Swamp Rabbits",
  "Jacksonville Icemen",
  "Orlando Solar Bears",
  "Savannah Ghost Pirates",
  "South Carolina Stingrays",
  "Florida Everblades",
  "Atlanta Gladiators"
]

def fetch_html
  URI.open(URL).read
end

def parse_standings(html)
  doc = Nokogiri::HTML(html)
  rows = doc.css('table tbody tr')
  teams = []

  rows.each do |row|
    cols = row.css('td').map(&:text).map(&:strip)
    next unless cols.size >= 10

    team_name = cols[1]
    next unless SOUTH_DIVISION_TEAMS.include?(team_name)

    teams << {
      team: team_name,
      gp: cols[2].to_i,
      w: cols[3].to_i,
      l: cols[4].to_i,
      otl: cols[5].to_i,
      sol: cols[6].to_i,
      pts: cols[7].to_i,
      gf: cols[8].to_i,
      ga: cols[9].to_i
    }
  end

  teams
end

def write_json(teams)
  File.write('standings.json', JSON.pretty_generate({ division: "South", teams: teams }))
end

html = fetch_html
teams = parse_standings(html)
write_json(teams)
puts "✅ Scraped #{teams.size} South Division teams"
