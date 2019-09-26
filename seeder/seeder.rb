require "down"
require 'ruby-s3cmd'
require 'answersengine'

s3cmd = RubyS3Cmd::S3Cmd.new
listings = s3cmd.ls(ENV['AWS_S3_TARGET_DIRECTORY'])

puts "starting s3 uploader script"

dir_names = []

listings.each do |dir|
  file_name = dir.split.last
  dir_names << file_name
end

puts "dir names on s3: #{dir_names.join(', ')}"

# get list of SCRAPERS_TO_EXPORT
scrapers = ENV['SCRAPERS_TO_EXPORT'].split(',').map(&:strip)

client = AnswersEngine::Client::ScraperExport.new

scrapers.each do |scraper_name|
  
  # get exports that were uploaded already
  date_format = '[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}'
  dir_format = Regexp.new("#{date_format}-#{scraper_name}")
  scraper_dir_names = [] 
  uploaded_dates = []
  dir_names.each do |dir_name| 
    if dir_name =~ dir_format 
      scraper_dir_names << dir_name
      date = dir_name.match(Regexp.new("(#{date_format})"))[0]
      uploaded_dates << Date.parse(date)
    end
  end

  # get a list of CSV exports
  exports =  client.all(scraper_name)
  csv_exports = exports.find_all{|export| export['exporter_type'] == 'csv'}

  # get exports that hasn't been uploaded on that date
  csv_exports.reject! do |export| uploaded_dates.include?(Date.parse(export['created_at'])) end

  # only returns the latest and unique exports on that date
  csv_exports.uniq!{|export| Date.parse(export['created_at'])}

  # download and upload each export
  csv_exports.each do |export|
    
    signed_download_url = client.download(export['id'])['signed_url']
    
    Down.download(signed_download_url, destination: "./to_upload/#{export['file_name']}")
    target_directory = File.join(ENV['AWS_S3_TARGET_DIRECTORY'],
      "#{Date.parse(export['created_at']).to_s}-#{scraper_name}", export['file_name'])
    
    puts "Uploading ./to_upload/#{export['file_name']} to #{target_directory}"
    s3cmd.put("./to_upload/#{export['file_name']}", target_directory)
    puts "success"

    outputs << {
      _collection: 'uploaded',
      _id: export['file_name'],
      name: target_directory,
    }
  end
end