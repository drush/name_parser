# NameParser

This gem has no dependencies and can be used to parse a wide variety of people's names.

## USAGE
```
gem 'name_parser'

NameParser::Person.parse('Jane Doe')
 => #<NameParser::Person first_name="Jane", last_name="Doe">

NameParser::Person.parse('Doe, Jane')
 => #<NameParser::Person first_name="Jane", last_name="Doe">

 NameParser::Person.parse('Jane P. Doe, MD')
 => #<NameParser::Person first_name="Jane", middle_name="P.", last_name="Doe", designation="MD">

```

## TEST & BUILD
```
bundle
rake
```
