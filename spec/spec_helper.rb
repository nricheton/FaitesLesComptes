# -*- encoding : utf-8 -*-

require 'simplecov'
#SimpleCov.start do
#  add_filter "/config/" # on ne teste pas la couverture des fichiers config.
#end


require 'spork'

#
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test' 
  require File.expand_path("../../config/environment", __FILE__)  
  require 'rspec/rails'  
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'email_spec'
  
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/*.rb")].each {|f| require f}
  
  SCHEMA_TEST = 'assotest_20140304044313'

  RSpec.configure do |config|
    config.include Devise::TestHelpers, :type => :controller
    config.mock_with :rspec
    config.use_transactional_fixtures = false

    config.before(:suite) do
      # DatabaseCleaner.clean_with :truncation
      # nettoyage de la base Public
      Apartment::Database.switch()
      User.delete_all
      Holder.delete_all
      Room.delete_all
      # Suppression de toutes les bases sauf SCHEMA_TEST
      Apartment::Database.list_schemas.reject {|name| name == 'public'}.each do |schema|
        Apartment::Database.drop(schema) unless schema == SCHEMA_TEST
      end
      # création de SCHEMA_TEST si n'existe pas encore
      Apartment::Database.create(SCHEMA_TEST) unless Apartment::Database.db_exist?(SCHEMA_TEST)
      # nettoyage des tables de SCHEMA_TEST
      # TODO voir s'il ne faudrait pas compléter ces tables.
      Apartment::Database.process(SCHEMA_TEST) do
        Organism.find_each {|o| o.destroy }
        Nature.delete_all
        Account.delete_all
        ComptaLine.delete_all
        BankAccount.delete_all
        Cash.delete_all
        Destination.delete_all
        Folio.delete_all
        Nomenclature.delete_all
        Rubrik.delete_all
        Adherent::Member.delete_all
      end
    end
    
    # pour les tests
    Delayed::Worker.delay_jobs = false

    #    config.after(:each) do
    #
    #    end

    #    config.before(:each) do
    #      if example.metadata[:js]
    #        DatabaseCleaner.strategy = :truncation
    #      else
    #        DatabaseCleaner.strategy = :truncation
    #      end
    #
    #      DatabaseCleaner.start
    #    end

    #    config.after(:each) do
    #      DatabaseCleaner.clean
    #    end

    #ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
    #DatabaseCleaner.strategy = :truncation
    #
    ####

  end

  #  RSpec.configure do |config|
  #    # == Mock Framework
  #    #
  #    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #    #
  #    # config.mock_with :mocha
  #    # config.mock_with :flexmock
  #    # config.mock_with :rr
  #
  #    #  config.use_transactional_fixtures = true
  #end
  #

end

Spork.each_run do

end
# If you're not using ActiveRecord, or you'd prefer not to run each of your
# examples within a transaction, remove the following line or assign false
# instead of true.












# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.


