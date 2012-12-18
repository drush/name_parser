require 'ostruct'

class String
  def strip_str(str)
    gsub(/^#{str}|#{str}$/, '')
  end
end

module NameParser
  def parse(name)
    p = NameParser::Person.parse(name)
    return new(p.marshal_dump)
  end
  
  class Person < OpenStruct #Struct.new(:full_name, :first_name, :last_name, :middle_name, :greeting, :suffix, :designation, :nickname)
    @@greetings = {'dr' => 'Dr.', 'mr' => 'Mr.', 'mrs' => 'Mrs.', 'ms' => 'Ms.'}
    @@designations = {'cpa' => 'CPA', 'phd' => 'PhD', 'ms' => 'MS', 'pe' =>'P.E.', 'md' => 'MD', 'jd' => 'JD'}
    @@suffices = {'jr' => 'Jr.', 'iii' => 'III', 'iv' => 'IV'}

    def to_s
      last_name.nil? ? full_name : "#{greeting} #{first_name} #{middle_name} #{last_name} #{suffix} #{designation}".squeeze(' ').strip()
    end

    # return Person
    # return OpenStruct/Hash
    def self.parse(name)
      name = name.squeeze(' ').strip
      nick_match = name.match(/\(.+\)/)
      if !nick_match.nil?
        nickname = nick_match[0].tr('()\'\"', '').squeeze
        tmp = name.gsub(nick_match[0],' ').squeeze(' ').strip
        p = parse(tmp)
        p.nickname = nickname
        return p
      end

      tokens = name.split(/[,\s]+/)
      phrases = name.split(',')

      designation = @@designations[tokens.last.downcase.tr('.','')]
      if !designation.nil?
        #tokens.pop
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

      suffix = @@suffices[tokens.last.downcase.tr('.','')]
      if !suffix.nil?
       trimmed = name.gsub(/[,\s]+#{tokens.last}/, '')
       puts "EDIT: " + trimmed
       #return
       p = parse(trimmed)
       p.suffix = suffix
       return p 
      end

      return parse2(name)

    end

    def self.parse2(name)
      tmp = name
      tokens = name.split(/[,\s]+/)
      phrases = name.split(',')
      
      greeting = @@greetings[tokens[0].downcase.tr('.','')]
      tokens.delete_at(0) unless greeting.nil?

      if greeting.nil?
        first = tokens[0].downcase
        @@greetings.each {|k,v| 
          if first[0, v.length] == v.downcase
            greeting = v
            tokens[0] = tokens[0][v.length..-1] 
            break
          end
        }
      end
     

      case tokens.length
      when 1
        name = tokens[0]
        catted = name.split('.')
        case catted.length
        when 1
          p = Person.new(last_name: name)        
        else
          p = Person.new(last_name: catted[-1], first_name: name.gsub(catted[-1], '')) 
        end
      when 2
        if name.include?(',') #&& designation.nil?
          p = Person.new(:first_name => tokens[1], :last_name => tokens[0])
        else
          p = Person.new(:first_name => tokens[0], :last_name => tokens[1])
        end
       when 3
        if tokens.last.length == 1 || tokens.last.last == '.' || (name.include?(',') && greeting.nil?) #&& designation.nil?)
          p = Person.new(:first_name => tokens[1], :middle_name => tokens[2], :last_name => tokens[0])
        else
          p = Person.new(:first_name => tokens[0], :middle_name => tokens[1], :last_name => tokens[2])
        end
      when 4
        case phrases.length
        when 1 # Julian Vergel de Dios
          p = Person.new(:first_name => tokens[0])
          tokens.delete_at(0)
          p.last_name = tokens.join(' ')
        when 2 # Vergel de Dios, Julian
          first_middle_tokens = phrases[1].split(' ')
          case first_middle_tokens.length
          when 1
            p = Person.new(:first_name => phrases[1], :last_name => phrases[0])
          when 2
            p = Person.new(:first_name => first_middle_tokens[0], :middle_name => first_middle_tokens[1], :last_name => phrases[0])
          when 3
            middle_tokens = []
            first_middle_tokens[1..2].each {|t| middle_tokens << t if t.split('.').join.length == 1 }
            first_tokens = first_middle_tokens - middle_tokens unless middle_tokens.blank?
            
            unless first_tokens.blank?
              p = Person.new(:first_name => first_tokens.join(' '), :middle_name => middle_tokens.join(' '), :last_name => phrases[0])
            else
              p = Person.new(:first_name => first_middle_tokens[0], :middle_name => first_middle_tokens[1..2].join(' '), :last_name => phrases[0])
            end
          else
            raise "Could not parse #{name}"
          end
        else
          #designation = phrases[1..-1].join(", ").squeeze(' ').strip
          p = Person.parse(phrases[0])
          #raise "Could not parse #{name}" # John Spence, CCNA, CCA
        end
        Rails.logger.warn "Parsed 4 token name #{name} as #{p}"
      when 5
        case phrases.length
        when 1 # 'Julian S. Vergel de Dios'
          p = Person.new(:first_name => tokens[0], :middle_name => tokens[1])
          tokens.delete_at(0)
          tokens.delete_at(1)
          p.last_name = tokens.join(' ')

        when 2
          subtokens = phrases[1].split(' ')
          case subtokens.length
          when 1 # Vergel de Dios, Julian
            p = Person.new(:first_name => subtokens[0], :last_name => phrases[0])
          when 2 # Vergel de Dios, Julian S.
            p = Person.new(:first_name => subtokens[0], :middle_name => subtokens[1], :last_name => phrases[0])
          else
            raise "Could not parse #{name}"
          end
        else
          raise "Could not parse #{name}"
        end  
        Rails.logger.warn "Parsed 5 token name #{name} as #{p}"
      else
        raise "Could not parse #{name}"
      end

      p.greeting = greeting unless greeting.blank?
      #p.designation = designation unless designation.blank?
      #p.suffix = suffix unless suffix.blank?
      #p.middle_name += '.' if  !p.middle_name.blank? && p.middle_name.length == 1
      return p
    end

    def diff?(other_person)
      self.greeting != other_person.greeting ||
      self.first_name != other_person.first_name ||
      self.middle_name != other_person.middle_name ||
      self.last_name != other_person.last_name ||
      self.suffix != other_person.suffix ||
      self.designation != other_person.designation
    end

    def self.test
      failed = 0
      t = {}

      t['Smith']       = Person.new(last_name: 'Smith')
      t['Smith, John'] = t['John Smith'] = Person.new(first_name: 'John', last_name: 'Smith')
      t['J. Smith']    = Person.new(first_name: 'J.', last_name: 'Smith')
      t['Drew Smith']    = Person.new(first_name: 'Drew', last_name: 'Smith')

      p3 = Person.new(:first_name => 'John', :middle_name => 'Paul', :last_name => 'Smith')
      p3b = Person.new(:first_name => 'John', :middle_name => 'P.', :last_name => 'Smith')
      p3c = Person.new(:first_name => 'J', :middle_name => 'Paul', :last_name => 'Smith')
      p3d = Person.new(:first_name => 'J.P.', :last_name => 'Smith', :designation => 'PhD')
      p3e = Person.new(:first_name => 'John', :last_name => 'Smith', :suffix => 'Jr.')

      t['John Paul Smith']         = p3
      t['  John   Paul   Smith  '] = p3  #extra spaces
      t['Smith, John Paul']        = p3
      t['John P. Smith']     = p3b
      t['Smith, John P.']    = p3b
      t['Smith John P.']     = p3b
      t['J Paul Smith']      = p3c
      t['J.P. Smith, PH.D.'] = p3d
      t['John Smith, Jr.'] = p3e
      t['Smith, John, Jr.'] = p3e


      p4 = Person.new(:first_name => 'John', :middle_name => 'Paul', :last_name => 'Smith', :designation => 'PhD')
      p4b = Person.new(:first_name => 'John', :middle_name => 'P.', :last_name => 'Smith', :designation => 'PhD')
      p4c = Person.new(:first_name => 'John', :middle_name => 'P.', :last_name => 'Smith', :suffix => 'Jr.')
      p4d = Person.new(:first_name => 'John', :middle_name => 'Paul', :last_name => 'Smith', :suffix => 'Jr.', :designation => "PhD")
      p4e = Person.new(:first_name => 'John', :middle_name => 'P.', :last_name => 'Smith', :suffix => 'III')
      p4f = Person.new(:first_name => 'Julian', :last_name => 'Vergel de Dios')
      p4g = Person.new(:first_name => 'Luiz', :middle_name => 'Barroca', :last_name => 'Da Silva')
      p4h = Person.new(:first_name => 'Teresa', :middle_name => 'L. Z.', :last_name => 'Jones')
      p4i = Person.new(:first_name => 'Mohd Amir', :middle_name => 'F', :last_name => 'Abdullah')
      p4j = Person.new(:first_name => 'Elaine', :middle_name => 'J', :last_name => 'Benaksas Schwartz')
      p4k = Person.new(:first_name => 'Kathy', :middle_name => 'M', :last_name => 'Mann Koepke')
      p4l = Person.new(:first_name => 'Chien Hsing', :middle_name => 'K', :last_name => 'Chang')
      p4m = Person.new(:first_name => 'Thomas', :middle_name => 'C K', :last_name => 'Chan')
      p4n = Person.new(:first_name => 'Maria', :middle_name => 'A', :last_name => 'De Bernardi')

      t['John P. Smith, PH.D.'] = p4b
      t['John P. Smith PH.D.'] = p4b
      t['John P. Smith PhD'] = p4b
      t['John P. Smith Jr.'] = p4c
      t['John Paul Smith, Jr., PH.D.'] = p4d  # could have 4-5 tokens
      t['John P. Smith III'] = p4e
      t['Julian Vergel de Dios'] = p4f
      t['Da Silva, Luiz Barroca'] = p4g
      t['Jones, Teresa L. Z.'] = p4h
      t['Abdullah, Mohd Amir F'] = p4i
      t['Benaksas Schwartz, Elaine J'] = p4j
      t['Mann Koepke, Kathy M'] = p4k
      t['Chang, Chien Hsing K'] = p4l
      t['Chan, Thomas C K'] = p4m
      t['De Bernardi, Maria A'] = p4n
      #t['Peggy Sue Smith']
      #t['Peggy Sue Vergel de Dios']


      d1 = Person.new(:greeting => 'Dr.', :first_name => 'John', :middle_name => 'P.', :last_name => 'Smith', :suffix => 'Jr.')
      d1b = Person.new(:greeting => 'Dr.', :first_name => 'John', :last_name => 'Smith')
      d1c = Person.new(:greeting => 'Dr.', :first_name => 'John', :middle_name => 'P.', :last_name => 'Smith')
      d1d = Person.new()
      t['DR. John P. Smith, Jr.'] = d1
      t['Dr. John Smith'] = d1b

      p5a = Person.new(:first_name => 'Lillian', :middle_name => 'L.', :last_name => 'Van De Verg')
      p5b = Person.new(:first_name => 'Luis', :middle_name => 'M', :last_name => 'De La Maza')
      p5c = Person.new(:first_name => 'Maida', :middle_name => 'M', :last_name => 'De Las Alas')
      p5d = Person.new(:first_name => 'Maida', :middle_name => 'M', :last_name => 'De Las Alas', :designation => "PhD")

      t['Van De Verg, Lillian L.'] = p5a
      t['De La Maza, Luis M'] = p5b
      t['De Las Alas, Maida M'] = p5c
      #t['De Las Alas, Maida M, PhD'] = p5d
      #t['Maida M. De Las Alas, PhD'] = p5d
      #t['Maida M. De Las Alas PhD'] = p5d

      #nicknames
      n1 = Person.new(:first_name => 'J.', :middle_name => 'P.', :last_name => 'Smith', :nickname => 'Jake')
      n1b = Person.new(:first_name => 'John', :last_name => 'Smith', :nickname => 'Jake')
      t['J. P. ("Jake") Smith'] = n1
      t['John (Jake) Smith'] = n1b
      
      #edgecases
      t['Mr. John Spence, CISSP, CCNA'] = Person.new(:first_name => 'John', :last_name => 'Spence', :designation => "CISSP, CCNA", :greeting => "Mr.")
      t['Mr.Bruce Hart'] = Person.new(first_name: 'Bruce', last_name: 'Hart', greeting: 'Mr.')


      t['C.J.Reddy']      = Person.new(first_name: 'C.J.', last_name: 'Reddy')
      t['Dr. R.O.Loutfy'] = Person.new(first_name: 'R.O.', last_name: 'Loutfy', greeting: 'Dr.')
      t['B.Ravichandran'] = Person.new(first_name: 'B.', last_name: 'Ravichandran')


    #t['J. Paul Smith, iii']
      #t['John Smith/Jane D.']
      #tests['John P. von Smith']
      #tests['J. von Smith']  #A. von Flotow
      
      # BAD DATA
      # t['Mr. T im McKechnie']

      t.each {|full_name, person|
        begin
          parsed = Person.parse(full_name)
        if person.diff?(parsed)
          puts "'#{full_name}' failed as '#{parsed.to_s}'"
          pp parsed
          puts '----'
          failed += 1
        end
      rescue Exception =>e
        puts "'#{full_name}' failed with exception: #{e}" #\n#{e.backtrace}"
        failed += 1
      end
      }

      puts "#{failed} failed and #{t.keys.length-failed} succeeded"
      return failed == 0

    end
  end
end

