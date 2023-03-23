# frozen_string_literal: true

module Que_0_14_3
  class Railtie < Rails::Railtie
    config.que = Que_0_14_3

    Que_0_14_3.logger         = proc { Rails.logger }
    Que_0_14_3.mode           = :sync if Rails.env.test?
    Que_0_14_3.connection     = ::ActiveRecord if defined? ::ActiveRecord
    Que_0_14_3.json_converter = :with_indifferent_access.to_proc

    rake_tasks do
      load 'que_0_14_3/rake_tasks.rb'
    end
  end
end
