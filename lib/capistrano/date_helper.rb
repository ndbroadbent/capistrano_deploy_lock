module Capistrano
  class DateHelper
    class << self
      include ActionView::Helpers::DateHelper
    end
  end
end