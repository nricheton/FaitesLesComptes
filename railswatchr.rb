def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts "Running #{file}"
  system "bundle exec rspec #{file} --color --drb"
  puts
end

watch("spec/.*/*_spec.rb") do |match|
  run_spec match[0]
end

watch("app/(.*/.*).rb") do |match|
  run_spec %{spec/#{match[1]}_spec.rb}
end

watch("app/(.*).erb") do |match|
  run_spec %{spec/#{match[1]}.erb_spec.rb}
end

watch("spec/.*/*_spec.erb") do |match|
  run_spec match[0]
end

#START:MIGRATION
watch('^db/migrate/(.*)\.rb') do |match|
  system("rake db:migrate:reset RAILS_ENV=test --trace")
end
#END:MIGRATION

#START: JS
watch('^(app/assets/javascripts/(.*)\.js)') do |m|
 jslint_check("#{m[1]}")
end

watch('^(spec/javascripts/(.*)\.js)') do |m|
  puts 'Dans watch .js avec appel de jslint';
  jslint_check("#{m[1]}")
end

#START: SCSS with SASS --CHECK
watch('^app/assets/stylesheets/(.*\.scss)') do |m|
  puts 'Dans watch .scss avec appel de check_scss';
    check_scss(m[1])
    puts "checked #{m[1]}"
end





def check_scss(scss_file)
    system("clear; sass --check app/assets/stylesheets/#{scss_file}" )
end
# END: SCSS

def jslint_check(files_to_check)
 # system('clear')
 puts "checking #{files_to_check}"
 system("jslint #{files_to_check}")
end