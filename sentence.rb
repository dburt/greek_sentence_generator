#!/usr/bin/ruby
# -*- encoding: UTF-8 -*-
#
# Koine Greek simple sentence generator
#
# Corresponding to vocab and grammar from Duff's Elements of NT Greek 3rd ed.
# chapters 3-5
#
# Author: Dave Burt
# Created: 7 Jan 2012
#
$KCODE = 'UTF-8'

$debug = false

class Array; def random; self[rand size] end end

# read a case-number-gender table into a structured hash
def cng_table(a)
  {
    :nom => { :sg => { :m => a[0],  :f => a[1],  :n => a[2]  },
              :pl => { :m => a[12], :f => a[13], :n => a[14] } },
    :acc => { :sg => { :m => a[3],  :f => a[4],  :n => a[5]  },
              :pl => { :m => a[15], :f => a[16], :n => a[17] } },
    :gen => { :sg => { :m => a[6],  :f => a[7],  :n => a[8]  },
              :pl => { :m => a[18], :f => a[19], :n => a[20] } },
    :dat => { :sg => { :m => a[9],  :f => a[10], :n => a[11] },
              :pl => { :m => a[21], :f => a[22], :n => a[23] } }
  }
end

# read a person-number table into a structured hash
def pn_table(a)
  {
    1 => { :sg => a[0], :pl => a[3] },
    2 => { :sg => a[1], :pl => a[4] },
    3 => { :sg => a[2], :pl => a[5] }
  }
end

# read a table of prepositions and their cases into a hash
def prep_table(s)
  h = {}
  s.each_line do |line|
    prep, cases = line.split
    h[prep] = [*cases].map(&:to_sym)
  end
  h
end

# return true with a given named probability
def p(sym)
  rand < (PROBABILITIES[sym] || 0.5)
end

def debug(*args)
  ("[" + args.join(".") + "]" if $debug).to_s
end

PROBABILITIES = {
  :subj_name => 0.8,  # probability a third party subject is explicit
  :dir_obj => 0.7,    # probability of a direct object
  :indir_obj => 0.6,  # probability of an indirect object
  :prep => 0.5,       # probability of a prepositional phrase
  :posessed => 0.4,   # probability any noun phrase will have a genitive added
  :autos => 0.2,      # probability a noun phrase will just be 'autos'
  :article => 0.7,    # probability a noun will have an article
}

CASES = [:nom, :acc, :gen, :dat]
NUMBERS = [:sg, :pl]
GENDERS = [:m, :f, :n]
PERSONS = [1, 2, 3]
PUNCTUATIONS = %w[ . ; · ]

ARTICLES = cng_table %w(
  ὁ    ἡ    το
  τον  την  το
  του  της  του
  τῳ   τῃ   τῳ
  οἱ   αἱ   τα
  τους τας  τα
  των  των  των
  τοις ταις τοις
)

NOUN_ENDINGS = cng_table %w(
  ος  η   ον
  ον  ην  ον
  ου  ης  ου
  ῳ   ῃ   ῳ
  οι  αι  α
  ους ας  α
  ων  ων  ων
  οις αις οις
)

AUTOSES = cng_table %w(
  αὐτος  αὐτη   αὐτο
  αὐτον  αὐτην  αὐτο
  αὐτου  αὐτης  αὐτου
  αὐτῳ   αὐτῃ   αὐτῳ
  αὐτοι  αὐται  αὐτα
  αὐτους αὐτας  αὐτα
  αὐτων  αὐτων  αὐτων
  αὐτοις αὐταις αὐτοις
)

VERB_ENDINGS = pn_table %w(
  ω
  εις
  ει
  ομεν
  ετε
  ουσιν
)

# includes chapter 3 and chapter 4 vocab, separated with a blank line
VERB_STEMS = %w(
  ἀγ
  ἀκου
  βαλλ
  βλεπ
  διδασκ
  ἐχ
  λαμβαν
  λεγ
  λυ
  ζητε
  καλε
  λαλε
  ποιε
  τηρε
  φιλε
  πιστευ

  ἀναβλεπ
  ἀπολυ
  ἐκβαλλ
  ἐπικαλε
  κατοικε
  παρακαλε
  παραλαμβαν
  περιπατε
  προσκυνε
  συναγ
  ὑπαγ
)

NOUN_STEMS = {
  :m => %w(
    ἀγγελ
    ἀδελφ
    ἀρτ
    δουλ
    θε
    κοσμ
    κυρι
    λογ
    νομ
    οἰκ
    οὐραν
    ὀχλ
    υἱ
    Χριστ
    ἀνθρωπ
    λα
    Παυλ
    Πετρ

    καιρ
  ),
  :f => %w(
    ἀγαπ
    ἀδελφ
    ἀρχ
    γ
    ζω
    φων
    ψυχ
    ἀμαρτι
    βασιλει
    ἐκκλησι
    ἡμερ
    καρδι
    Μαρι
    οἰκι
    ὡρ
    δοξ
    θαλασσ

    εἰρην
    κεφαλ
    συναγωγ
    Γαλιλαι
  ),
  :n => %w(
    βιβλι
    δαιμονι
    ἐργ
    εὐαγγελι
    ἱερ
    πλοι
    προσωπ
    σαββατ
    σημει
    τεκν
  ),
}

PREPOSITIONS = prep_table <<-END
  ἀπο     gen
  δια     acc gen
  εἰς     acc
  ἐκ      gen
  ἐν      dat
  ἐνωπιον gen
  ἐξω     gen
  ἐπι     acc gen dat
  ἑως     gen
  κατα    acc gen
  μετα    acc gen
  παρα    acc gen dat
  περι    acc gen
  προ     gen
  προς    acc
  συν     dat
  ὑπερ    acc gen
  ὑπο     acc gen
END

ADJECTIVE_STEMS = %w(
  ἀγαθ
  ἁγι
  ἑτερ
  ἰδι
  Ἰουδαι
  καλ
  μακαρι
  μον
  νεκρ
  ὁσ
  πονηρ
  τυφλ
  ἀγαπητ
  δικαι
  ἑκαστ
  κακ
  καιν
  πιστ
)

def decline_adjective(stem, kase, number, gender)
  decline_noun(stem, kase, number, gender, :adj)
end

def decline_noun(stem, kase, number, gender, adj=nil)
  ending = NOUN_ENDINGS[kase][number][gender]
  ending = ending.sub(/η/, 'α').sub(/ῃ/, 'ᾳ') if  # like ἡμερα and δοξα
    stem =~ /(α|ε|η|ι|ο|υ|ω|ρ)$/ && number == :sg && stem != 'ζω' ||
    stem =~ /(ξ|σ|ψ)$/ && number == :sg && [:nom, :acc].include?(kase) && !adj
  stem + ending + debug(kase,number,gender)
end

def inflect_verb(stem, person, number)
  ending = VERB_ENDINGS[person][number]
  case stem
  when /ε$/; contract_ew_verb(stem, ending)
  else; stem + ending
  end + debug(person,number)
end

def contract_ew_verb(stem, ending)
  case ending
  when /^(η|ω|αι|ει|οι|υι|αυ|ευ|ηυ|ου)/; stem.sub(/ε$/, '') + ending
  when /^ε/; stem.sub(/ε$/, '') + 'ει' + ending.sub(/^ε/, '')
  when /^ο/; stem.sub(/ε$/, '') + 'ου' + ending.sub(/^ο/, '')
  else; stem + ending
  end
end

def random_noun_stem_with_gender
  gender = GENDERS.random
  [NOUN_STEMS[gender].random, gender]
end

def noun_phrase(kase, number = NUMBERS.random)
  if p(:autos)
    AUTOSES[kase][number][gender = GENDERS.random] + debug(kase,number,gender)
  else
    noun_stem, gender = random_noun_stem_with_gender
    article = ARTICLES[kase][number][gender] if p(:article)
    noun = decline_noun(noun_stem, kase, number, gender)
    genitive_phrase = noun_phrase(:gen) if p(:posessed)
    [article, noun, genitive_phrase].compact.join(" ")
    #TODO: mix in some adjectives here
    #TODO: mix up the order: Art N [Art] Gen | Art Gen N | Art Adj N | Art N Art Adj | Art Adj Gen N | Art N Art Adj Art Gen | ...
  end
end

def verb_and_subject
  person = PERSONS.random
  number = NUMBERS.random
  subject = noun_phrase(:nom, number) if person == 3 && p(:subj_name)
  verb = inflect_verb(VERB_STEMS.random, person, number)
  [verb, subject]
end

def prep_phrase
  prep, cases = PREPOSITIONS.to_a.random
  prep + " " + noun_phrase(cases.random)
  #TODO: elision of prepositions followed by vowels
end

def random_sentence
  parts = verb_and_subject
  parts << noun_phrase(:acc) if p(:dir_obj) && parts[0] !~ /^πιστευ|^προσκυν/
  parts << noun_phrase(:dat) if p(:indir_obj)
  parts << noun_phrase(:gen) if p(:dir_obj) && parts[0] =~ /^ἀκου/
  parts << prep_phrase if p(:prep)
  parts.compact.shuffle.join(" ") + PUNCTUATIONS.random
end

if $0 == __FILE__

  n = [ARGV.first.to_i, ENV['QUERY_STRING'].to_s[/\d+/].to_i, 1].max

  puts "Content-Type: text/plain; charset=utf-8"
  puts
  $debug = true
  sentences = n.times.map { random_sentence }

  puts sentences.map {|sentence| sentence.gsub(/\[.*?\]/, '') }
  puts

  if STDIN.tty? && STDOUT.tty?
    puts "Press enter to see parsing."
    STDIN.gets
  elsif ENV['QUERY_STRING']  # CGI
    puts "Scroll below source code to see the parsing."
    puts "To generate N sentences at a time, add ?N to the URL."
    puts "e.g. http://dave.burt.id.au/greek/sentence.rb?10 for 10 sentences."
    puts
    puts "-" * 72
    puts File.read(__FILE__)
    puts "-" * 72
    puts
  else
    puts "-" * 72
    puts
  end

  puts sentences
  puts
  puts "(N.B. There may be other valid ways to parse this Greek.)"
end
