# frozen_string_literal: true

require 'utilities'
class ApplicationRecord < ActiveRecord::Base
  include Utilities
  self.abstract_class = true

end
