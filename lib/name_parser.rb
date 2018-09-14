require 'ostruct'
require 'logger'

module NameParser
  

  def parse(name)
    p = NameParser::Person.parse(name)
    new(p.marshal_dump)
  end

  class Person < OpenStruct # Struct.new(:full_name, :first_name, :last_name, :middle_name, :greeting, :suffix, :designation, :nickname)
    @@logger ||= defined?(Rails) ? @logger : Logger.new(STDOUT)

    @@greetings = { 'dr' => 'Dr.', 'mr' => 'Mr.', 'mrs' => 'Mrs.', 'ms' => 'Ms.' }
    @@designations = { 'cpa' => 'CPA', 'phd' => 'PhD', 'ms' => 'MS', 'pe' => 'P.E.', 'md' => 'MD', 'jd' => 'JD' }
    @@suffices = { 'jr' => 'Jr.', 'iii' => 'III', 'iv' => 'IV' }

    def to_s
      last_name.nil? ? full_name : "#{greeting} #{first_name} #{middle_name} #{last_name} #{suffix} #{designation}".squeeze(' ').strip
    end

    # return Person
    # return OpenStruct/Hash
    def self.parse(name)
      name = name.squeeze(' ').strip
      nick_match = name.match(/\(.+\)/)
      unless nick_match.nil?
        nickname = nick_match[0].tr('()\'\"', '').squeeze
        tmp = name.gsub(nick_match[0], ' ').squeeze(' ').strip
        p = parse(tmp)
        p.nickname = nickname
        return p
      end

      tokens = name.split(/[,\s]+/)
      phrases = name.split(',')

      designation = @@designations[tokens.last.downcase.tr('.', '')]
      unless designation.nil?
        # tokens.pop
        trimmed = name.gsub(/[,\s]+#{tokens.last}/, '')
        p = parse(trimmed)
        p.designation = designation
        return p
      end

      # if tokens.last.downcase.tr('.','') == 'd'  && tokens[tokens.length-2].downcase.tr('.','') =='ph'
      #   designation = 'PhD'
      #   tokens.pop
      #   tokens.pop
      # end

      suffix = @@suffices[tokens.last.downcase.tr('.', '')]
      unless suffix.nil?
        trimmed = name.gsub(/[,\s]+#{tokens.last}/, '')
        # return
        p = parse(trimmed)
        p.suffix = suffix
        return p
      end

      parse2(name)
    end

    def self.parse2(name)
      tmp = name
      tokens = name.split(/[,\s]+/)
      phrases = name.split(',')

      greeting = @@greetings[tokens[0].downcase.tr('.', '')]
      tokens.delete_at(0) unless greeting.nil?

      if greeting.nil?
        first = tokens[0].downcase
        @@greetings.each do |_k, v|
          next unless first[0, v.length] == v.downcase
          greeting = v
          tokens[0] = tokens[0][v.length..-1]
          break
        end
      end

      case tokens.length
      when 1
        name = tokens[0]
        catted = name.split('.')
        p = case catted.length
            when 1
              Person.new(last_name: name)
            else
              Person.new(last_name: catted[-1], first_name: name.gsub(catted[-1], ''))
            end
      when 2
        p = if name.include?(',') # && designation.nil?
              Person.new(first_name: tokens[1], last_name: tokens[0])
            else
              Person.new(first_name: tokens[0], last_name: tokens[1])
            end

      when 3
        if tokens.last.length == 1 || tokens.last[-1] == '.' || (name.include?(',') && greeting.nil?) # && designation.nil?)
          p = Person.new(first_name: tokens[1], middle_name: tokens[2], last_name: tokens[0])
        else
          p = Person.new(first_name: tokens[0], middle_name: tokens[1], last_name: tokens[2])
        end
      when 4
        case phrases.length
        when 1 # Julian Vergel de Dios
          p = Person.new(first_name: tokens[0])
          tokens.delete_at(0)
          p.last_name = tokens.join(' ')
        when 2 # Vergel de Dios, Julian
          first_middle_tokens = phrases[1].split(' ')
          case first_middle_tokens.length
          when 1
            p = Person.new(first_name: phrases[1], last_name: phrases[0])
          when 2
            p = Person.new(first_name: first_middle_tokens[0], middle_name: first_middle_tokens[1], last_name: phrases[0])
          when 3
            middle_tokens = []
            first_middle_tokens[1..2].each { |t| middle_tokens << t if t.split('.').join.length == 1 }
            first_tokens = first_middle_tokens - middle_tokens unless middle_tokens.to_s.strip.empty?

            if first_tokens.to_s.strip.empty?
              p = Person.new(first_name: first_middle_tokens[0], middle_name: first_middle_tokens[1..2].join(' '), last_name: phrases[0])
            else
              p = Person.new(first_name: first_tokens.join(' '), middle_name: middle_tokens.join(' '), last_name: phrases[0])
            end
          else
            raise "Could not parse #{name}"
          end
        else
          # designation = phrases[1..-1].join(", ").squeeze(' ').strip
          p = Person.parse(phrases[0])
          # raise "Could not parse #{name}" # John Spence, CCNA, CCA
        end
        @@logger.warn "NameParser: Parsed 4 token name #{name} as #{p}"

      when 5
        case phrases.length
        when 1 # 'Julian S. Vergel de Dios'
          p = Person.new(first_name: tokens[0], middle_name: tokens[1])
          tokens.delete_at(0)
          tokens.delete_at(1)
          p.last_name = tokens.join(' ')

        when 2
          subtokens = phrases[1].split(' ')
          case subtokens.length
          when 1 # Vergel de Dios, Julian
            p = Person.new(first_name: subtokens[0], last_name: phrases[0])
          when 2 # Vergel de Dios, Julian S.
            p = Person.new(first_name: subtokens[0], middle_name: subtokens[1], last_name: phrases[0])
          else
            raise "Could not parse #{name}"
          end
        else
          raise "Could not parse #{name}"
        end
        @@logger.warn "NameParser: Parsed 5 token name #{name} as #{p}"
      else
        raise "Could not parse #{name}"
      end

      p.greeting = greeting unless greeting.to_s.strip.empty?
      # p.designation = designation unless designation.blank?
      # p.suffix = suffix unless suffix.blank?
      # p.middle_name += '.' if  !p.middle_name.blank? && p.middle_name.length == 1
      p
    end

    def diff?(other_person)
      greeting != other_person.greeting ||
        first_name != other_person.first_name ||
        middle_name != other_person.middle_name ||
        last_name != other_person.last_name ||
        suffix != other_person.suffix ||
        designation != other_person.designation
    end
  end
end
