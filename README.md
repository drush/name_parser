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

## CHANGES

* Sept 2018 - 1.0.1
  * Add suffix support for Sr, Senior, Junior

* Sept 2018 - 1.0
  * Remove dependencies - runs in any ruby project
  * Refactor tests using minitest
  * Code cleanup via Rubocop

* Dec 2012 - 0.0.1 - Parses a variety of people names

## Roadmap

  * Reorganize the test corpus to be mode readable - load from a data file
  * Support more edge cases
  * Add benckmarks