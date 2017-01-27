#!/usr/bin/env ruby

class Verbasizer
  def modes
    {
      "v" => [ "Verbasizer", :verbasize ],
      "p" => [ "Portmanteau (prefixes)", :portmanteau ],
      "s" => [ "Portmanteau (suffixes)", :portmanteau2 ],
      "t" => [ "Portmanthree (prefix)", :portmanteau3_pre ],
      "y" => [ "Portmanthree (middle)", :portmanteau3_mid ],
      "u" => [ "Portmanthree (suffix)", :portmanteau3_end ],
      "m" => [ "Mesmorizer", :mesmorizer ],
      "l" => [ "Lemmesmorizer", :lemmesmorizer ],
      "r" => [ "Rhyme dictionary", :rhyme ],
      "x" => [ "Mixed", :mixed ],
      "a" => [ "Choose alphabets", nil ],
      "q" => [ "Quit", nil ],
    }
  end

  def alphabets
    {
      "en" => [ "english", nil ],
      "la" => [ "latin", "latin.dic" ],
      "fr" => [ "french", "fr.dic" ],
      "de" => [ "german", "de_neu.dic" ],
      "it" => [ "italian", "it.dic" ],
      "br" => [ "brazilian portuguese", "br.dic" ],
      "dk" => [ "danish", "dk.dic" ],
      "nl" => [ "dutch", "nl.dic" ],
      "ru" => [ "russian", "ru.dic" ],
      "gr" => [ "greek", "greek_open.dic" ]
    }
  end

  def portmanteau(word, dict = words)
    (2..4).map { |l|
      dict.select { |w| w.length > l + 2 and w[0..l-1] == word[-l,l] }.map { |port| word + port[l..-1] }
    }.select { |p| p }.flatten.sort_by(&:length)
  end

  def portmanteau2(word, dict = words)
    (2..4).map { |l|
      dict.select { |w| w.length > l + 2 and word[0..l-1] == w[-l,l] }.map { |port| port[0..-l-1] + word }
    }.select { |p| p }.flatten.sort_by(&:length)
  end

  def portmanteau3_pre(word); portmanteau(word).take(4).map { |w| portmanteau(w) }.flatten; end
  def portmanteau3_mid(word); portmanteau2(word).take(4).map { |w| portmanteau(w) }.flatten; end
  def portmanteau3_end(word); portmanteau2(word).take(4).map { |w| portmanteau2(w) }.flatten; end

  def rhyme(word)
    @rhymes[@dict[word]].sort.uniq rescue []
  end

  def mixed(word)
    rhyme(word).select { |w| !w.end_with?(word) and w.length > 2 }.shuffle.take(10).map { |w|
      portmanteau2(w).shuffle.take(2)
    }.flatten
  end

  def replacir(letter)
    vocals = ["A", "E", "I", "O", "U", "Y"]
    consonants = ("A".."Z").to_a - vocals
    return (vocals - [letter]).sample if vocals.include?(letter)
    return (consonants - [letter]).sample if vocals.include?(letter)
    letter
  end

  def mesmorizer(word)
    (0...word.length).map { |i| (0..10).map { |x| word[0...i] + replacir(word[i]) + word[i+1..-1] } }.flatten.uniq.shuffle
  end

  def lemmesmorizer(word, dict = words)
    werds = dict.shuffle.take(100).map { |w| mesmorizer(w) }.flatten
    portmanteau2(word, werds)
  end

  def columnize(arr, columns = 70, padding = 5)
    max = (arr.map(&:length).max || 0) + padding
    arr.map{ |e| e.ljust(max, ' ') }.each_slice(columns / max).map {|g| g.join(' ') }.join("\n")
  end

  def words
    @other_dictionaries + (alphabets.include?("en") ? @dict.map(&:first) : [])
  end

  def get(type)
    File.new("#{type}.txt").readlines.sample.strip
  end

  def chance
    rand(2) > 0
  end

  def verbasize(dummy = nil)
    20.times.map do
      case rand 20
        when 0  then [ :article, :adjective, :noun, :verb, :adverb, :preposition, :article, :adjective, :noun ]
        when 1  then [ :adverb, :article, :adjective, :noun, :verb, :preposition, :article, :adjective, :noun ]
        when 2  then [ :preposition, :adjective, :noun, :article, :adjective, :noun, :verb, :adverb ]
        when 3  then [ :pronoun, :verb, :adverb, :preposition, :article, :adjective, :noun ]
        when 4  then [ :adverb, :pronoun, :verb, :preposition, :article, :adjective, :noun ]
        when 5  then [ :preposition, :adjective, :noun, :pronoun, :verb, :adverb ]
        when 6  then [ :adverb, :verb, :article, :noun ]
        when 7  then [ :adjective, :noun, :adverb, :verb, :article, :noun ]
        when 8  then [ :adverb, :verb ]
        when 9  then [ :verb, :article, :noun ]
        when 10 then [ :article, :noun, :aux_verb, :adverb, :verb, :article, :noun ]
        when 11 then [ :article, :noun, :verb, :article, :adjective, :noun ]
        when 12 then [ :aux_verb, :pronoun, :verb, :article, :noun ]
        when 13 then [ :pronoun, :aux_verb, :verb, :article, :noun ]
        when 14 then [ :nominative, :aux_verb, :verb, :pronoun, :adverb ]
        when 15 then [ :nominative, :aux_verb, :verb ]
        when 16 then [ :nominative, :aux_verb, :adverb, :verb, :pronoun, :adverb ]
        when 17 then [ :nominative, :aux_verb, :adverb, :verb ]
        when 18 then [ :adverb, :article, :adjective, :noun, :aux_verb, :verb, :preposition, :article, :adjective, :noun ]
        when 19 then [ :preposition, :adjective, :noun, :article, :adjective, :noun, :aux_verb, :verb, :adverb ]
      end.map{|g|get g}.join " "
    end
  end

  def choose_alphabet
    puts "Type which alphabets you want (example: \"en fr\" for english and french):"
    alphabets.each { |a,b| puts "  #{a} - #{b[0]}" }
    print "Choose: "
    alphas = $stdin.gets.chomp rescue exit
    @alphas = alphabets.select { |a,b| alphas.include?(a) }.map { |a,b|  a }

    @alphas = [ "en" ] if @alphas == []

    puts "You chose: " + @alphas.map { |a| alphabets[a].first }.join(', ') + "."

    @other_dictionaries = @alphas.select { |l| l != "en" }.map { |a|
      filename = alphabets[a].last
      puts "Loading #{filename}"
      File.open(filename).read.encode('UTF-8', 'iso-8859-1', :invalid => :replace).upcase.split(/\r|\n/) rescue []
    }.flatten
  end

  def run!
    @alphabets = [ "en" ]
    @other_dictionaries = []

    # Got it from https://github.com/UncleGene/rhymes/
    @dict, @rhymes = Marshal.load(File.open(File.expand_path('rhymes.dat', File.dirname(__FILE__)), 'rb') { |f| f.read })
    
    # Other languages come from http://www.winedt.org/Dict/

    puts "Verbasizer v0.0.1. Type ? for help."

    mode = "v"
  
    loop do
      print ">> "
      line = $stdin.gets.chomp rescue exit

      if line == "?"
        puts "Commands:"
        modes.each { |m, n| puts "  :#{m} - #{n[0]}" }
      elsif line == ":q"
        exit
      elsif line == ":a"
        choose_alphabet
      elsif line[0] == ":" and line[1] and modes.has_key?(line[1])
        mode = line[1]
        puts modes[mode].first + " mode. Type a word, or just hit enter for a random one."
      elsif true
        method_name = modes[mode].last
        word = line.empty? ? words.sample : line.upcase
        result = method(method_name).call(word).shuffle.take(60).sort
        result = result.map { |w| (@dict.include?(w) and mode != "r") ? w.downcase + "🌐" : w.downcase }
        puts mode == "v" ? result : columnize(result)
      end
    end
  end
end

Verbasizer.new.run!
