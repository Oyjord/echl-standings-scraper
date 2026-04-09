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
  URI.open(URL, "User-Agent" => "Mozilla/5.0").read
end

def parse_standings(html)
  doc = Nokogiri::HTML(html)
  rows = doc.css("table tbody tr")

  teams = []

  rows.each do |row|
    cols = row.css("td")
    next unless cols.size >= 10

    # -------------------------
    # 1. Extract prefix from column 0
    # -------------------------
    prefix_span = cols[0].css("span").find { |s| s.text.strip =~ /^[xyz]+$/i }
    prefix = prefix_span ? prefix_span.text.strip.downcase : ""

    # -------------------------
    # 2. Extract team name from column 1
    # -------------------------
    team_cell = cols[1]
    raw_team = team_cell.text.gsub(/\s+/, " ").strip

    # Normalize: remove abbreviations like "FLA"
    base_name = SOUTH_DIVISION_TEAMS.find { |t| raw_team.include?(t) }
    next unless base_name

    # -------------------------
    # 3. Build final team string
    # -------------------------
    final_team = prefix.empty? ? base_name : "#{prefix} #{base_name}"

    # -------------------------
    # 4. Extract stats
    # -------------------------
    teams << {
      team: final_team,
      gp:   cols[2].text.to_i,
      w:    cols[3].text.to_i,
      l:    cols[4].text.to_i,
      otl:  cols[5].text.to_i,
      sol:  cols[6].text.to_i,
      pts:  cols[7].text.to_i,
      gf:   cols[8].text.to_i,
      ga:   cols[9].text.to_i
    }
  end

  teams
end

def write_json(teams)
  File.write("standings.json", JSON.pretty_generate({ division: "South", teams: teams }))
end

html = fetch_html
teams = parse_standings(html)
write_json(teams)
