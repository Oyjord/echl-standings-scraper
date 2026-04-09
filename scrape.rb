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
  puts "🌐 Fetching HTML from #{URL}"
  URI.open(URL, "User-Agent" => "Mozilla/5.0").read
rescue => e
  puts "❌ Failed to fetch HTML: #{e}"
  ""
end

def parse_standings(html)
  doc = Nokogiri::HTML(html)
  rows = doc.css('table tbody tr')
  puts "🔍 Found #{rows.size} table rows"

  teams = []

  rows.each_with_index do |row, index|
    cols = row.css('td').map { |td| td.text.strip }
    puts "🔎 Row #{index + 1}: #{cols.inspect}"

    next unless cols.size >= 10

    # Extract raw team cell text (may include prefix)
    raw_team = cols[1]

    # Normalize: remove extra whitespace
    raw_team = raw_team.gsub(/\s+/, " ").strip

    # Extract prefix (x, y, z)
    prefix = raw_team[/^[xyz]/i] || ""

    # Extract clean team name (remove prefix and dash)
    team_name = raw_team.gsub(/^[xyz]\s*-\s*/i, "").strip

    # Only keep South Division teams
    next unless SOUTH_DIVISION_TEAMS.include?(team_name)

    # Build final team string (prefix + name)
    final_team = prefix.empty? ? team_name : "#{prefix} #{team_name}"

    puts "✅ Matched South Division team: #{final_team}"

    teams << {
      team: final_team,
      gp: cols[2].to_i,
      w:  cols[3].to_i,
      l:  cols[4].to_i,
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
  puts "📁 Wrote #{teams.size} teams to standings.json"
end

html = fetch_html
teams = parse_standings(html)
write_json(teams)
