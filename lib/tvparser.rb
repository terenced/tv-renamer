module TVParser
  def self.parse(filename)
    # House.S04E13.HDTV.XviD-XOR.avi
    # my.name.is.earl.s03e07-e08.hdtv.xvid-xor.[VTV].avi
    # My_Name_Is_Earl.3x17.No_Heads_And_A_Duffel_Bag.HDTV_XviD-FoV.[VTV].avi
    # My Name Is Earl - 3x04.avi
    # MythBusters - S04E01 - Newspaper Crossbow.avi
    # my.name.is.earl.305.hdtv-lol.[VTV].avi

    # TODO look up the regex used in XBMC to get data from TV episodes
    re =
      /^(.*?)(?:\s?[-\.]\s?)?\s*\[?s?(?:
      (?:
        (\d{1,2})
        \s?\.?\s?[ex-]\s?
        (?:(\d{2})(?:\s?[,-]\s?[ex]?(\d{2}))?)
      )
      |
      (?:
        \.(\d{1})(\d{2})(?!\d)
      )
      |
      (?:
        \s*-\s*(\d{1})(\d{2})\s*-\s*(?!\d)
      )
      )\]?\s?.*$/ix

    if match = filename.to_s.match(re)
      series  = match[1].gsub(/[\._]/, ' ').strip.gsub(/\b\w/){$&.upcase}
      season  = (match[2] || match[5] || match[7]).to_i
      episode = (match[3] || match[6] || match[8]).to_i
      episode = (episode)..(match[4].to_i) unless match[4].nil?

      [series, season, episode]
    else
      nil
    end
  end
end