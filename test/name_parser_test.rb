require 'test_helper'
include NameParser

describe NameParser do
  it 'parses names' do
    # NameParser::Person.test
    name_tests
  end
end

def name_tests
  failed = 0
  t = {}

  t['Smith']       = Person.new(last_name: 'Smith')
  t['Smith, John'] = t['John Smith'] = Person.new(first_name: 'John', last_name: 'Smith')
  t['J. Smith']    = Person.new(first_name: 'J.', last_name: 'Smith')
  t['Drew Smith'] = Person.new(first_name: 'Drew', last_name: 'Smith')

  p3 = Person.new(first_name: 'John', middle_name: 'Paul', last_name: 'Smith')
  p3b = Person.new(first_name: 'John', middle_name: 'P.', last_name: 'Smith')
  p3c = Person.new(first_name: 'J', middle_name: 'Paul', last_name: 'Smith')
  p3d = Person.new(first_name: 'J.P.', last_name: 'Smith', designation: 'PhD')
  p3e = Person.new(first_name: 'John', last_name: 'Smith', suffix: 'Jr.')

  t['John Paul Smith']         = p3
  t['  John   Paul   Smith  '] = p3 # extra spaces
  t['Smith, John Paul']        = p3
  t['John P. Smith']     = p3b
  t['Smith, John P.']    = p3b
  t['Smith John P.']     = p3b
  t['J Paul Smith']      = p3c
  t['J.P. Smith, PH.D.'] = p3d
  t['John Smith, Jr.'] = p3e
  t['Smith, John, Jr.'] = p3e

  p4 = Person.new(first_name: 'John', middle_name: 'Paul', last_name: 'Smith', designation: 'PhD')
  p4b = Person.new(first_name: 'John', middle_name: 'P.', last_name: 'Smith', designation: 'PhD')
  p4c = Person.new(first_name: 'John', middle_name: 'P.', last_name: 'Smith', suffix: 'Jr.')
  p4d = Person.new(first_name: 'John', middle_name: 'Paul', last_name: 'Smith', suffix: 'Jr.', designation: 'PhD')
  p4e = Person.new(first_name: 'John', middle_name: 'P.', last_name: 'Smith', suffix: 'III')
  p4f = Person.new(first_name: 'Julian', last_name: 'Vergel de Dios')
  p4g = Person.new(first_name: 'Luiz', middle_name: 'Barroca', last_name: 'Da Silva')
  p4h = Person.new(first_name: 'Teresa', middle_name: 'L. Z.', last_name: 'Jones')
  p4i = Person.new(first_name: 'Mohd Amir', middle_name: 'F', last_name: 'Abdullah')
  p4j = Person.new(first_name: 'Elaine', middle_name: 'J', last_name: 'Benaksas Schwartz')
  p4k = Person.new(first_name: 'Kathy', middle_name: 'M', last_name: 'Mann Koepke')
  p4l = Person.new(first_name: 'Chien Hsing', middle_name: 'K', last_name: 'Chang')
  p4m = Person.new(first_name: 'Thomas', middle_name: 'C K', last_name: 'Chan')
  p4n = Person.new(first_name: 'Maria', middle_name: 'A', last_name: 'De Bernardi')

  t['John P. Smith, PH.D.'] = p4b
  t['John P. Smith PH.D.'] = p4b
  t['John P. Smith PhD'] = p4b
  t['John P. Smith Jr.'] = p4c
  t['John Paul Smith, Jr., PH.D.'] = p4d # could have 4-5 tokens
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
  # t['Peggy Sue Smith']
  # t['Peggy Sue Vergel de Dios']

  d1 = Person.new(greeting: 'Dr.', first_name: 'John', middle_name: 'P.', last_name: 'Smith', suffix: 'Jr.')
  d1b = Person.new(greeting: 'Dr.', first_name: 'John', last_name: 'Smith')
  d1c = Person.new(greeting: 'Dr.', first_name: 'John', middle_name: 'P.', last_name: 'Smith')
  d1d = Person.new
  t['DR. John P. Smith, Jr.'] = d1
  t['Dr. John Smith'] = d1b

  p5a = Person.new(first_name: 'Lillian', middle_name: 'L.', last_name: 'Van De Verg')
  p5b = Person.new(first_name: 'Luis', middle_name: 'M', last_name: 'De La Maza')
  p5c = Person.new(first_name: 'Maida', middle_name: 'M', last_name: 'De Las Alas')
  p5d = Person.new(first_name: 'Maida', middle_name: 'M', last_name: 'De Las Alas', designation: 'PhD')

  t['Van De Verg, Lillian L.'] = p5a
  t['De La Maza, Luis M'] = p5b
  t['De Las Alas, Maida M'] = p5c
  # t['De Las Alas, Maida M, PhD'] = p5d
  # t['Maida M. De Las Alas, PhD'] = p5d
  # t['Maida M. De Las Alas PhD'] = p5d

  # nicknames
  n1 = Person.new(first_name: 'J.', middle_name: 'P.', last_name: 'Smith', nickname: 'Jake')
  n1b = Person.new(first_name: 'John', last_name: 'Smith', nickname: 'Jake')
  t['J. P. ("Jake") Smith'] = n1
  t['John (Jake) Smith'] = n1b

  # edgecases
  # t['Mr. John Spence, CISSP, CCNA'] = Person.new(first_name: 'John', last_name: 'Spence', designation: 'CISSP, CCNA', greeting: 'Mr.')
  t['Mr.Bruce Hart'] = Person.new(first_name: 'Bruce', last_name: 'Hart', greeting: 'Mr.')

  t['C.J.Reddy']      = Person.new(first_name: 'C.J.', last_name: 'Reddy')
  t['Dr. R.O.Loutfy'] = Person.new(first_name: 'R.O.', last_name: 'Loutfy', greeting: 'Dr.')
  t['B.Ravichandran'] = Person.new(first_name: 'B.', last_name: 'Ravichandran')

  # t['J. Paul Smith, iii']
  # t['John Smith/Jane D.']
  # tests['John P. von Smith']
  # tests['J. von Smith']  #A. von Flotow

  # BAD DATA
  # t['Mr. T im McKechnie']

  t.each do |full_name, person|
    begin
      parsed = Person.parse(full_name)
      if person.diff?(parsed)
        puts "'#{full_name}' failed as '#{parsed}'"
        pp parsed
        puts '----'
        failed += 1
      end
    rescue Exception => e
      msg = "'#{full_name}' failed with exception: #{e}" # #{e.backtrace}"
      failed += 1
      raise msg
    end
  end

  msg = "#{failed} failed and #{t.keys.length - failed} succeeded"

  raise msg if failed > 0
  puts msg
end
