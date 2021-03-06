# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every :day, at: '3 am' do
  rake 'ocracoke:solr:optimize', output: { error: '~/ocracoke-solr-optimize-error.log', standard: '~/ocracoke-solr-optimize-standard.log'}
end

every :day, at: '4 am' do
  command 'curl "http://localhost:8983/solr/ocracoke/suggest?wt=json&suggest.build=true"', output: { error: '~/ocracoke-solr-build_suggester-error.log', standard: '~/ocracoke-solr-build_suggester-standard.log'}
end
