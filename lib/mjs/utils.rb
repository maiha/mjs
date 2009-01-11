module Mjs
  module Utils
    def self.camelize(lower_case_and_underscored_word, first_letter = :upper)
      lower_case_and_underscored_word = lower_case_and_underscored_word.to_s
      first_letter_in_uppercase = (first_letter == :upper)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word[0,1].downcase + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end
  end
end
