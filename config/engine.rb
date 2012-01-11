require 'rails'

# An engine doesn't require it's own dependencies automatically. We also don't
# want the applications to have to do that.
require 'cancan'
require 'authlogic'
require 'kaminari'
require 'iq_rdf'
require 'json'
require 'rails_autolink'

module Iqvoc

  class Engine < Rails::Engine

    # paths.lib.tasks  << "lib/engine_tasks"

  end

end
