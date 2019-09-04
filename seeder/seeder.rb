# directories = `s3cmd ls #{ENV['AWS_S3_BUCKET_NAME']}`
directories = %x(s3cmd ls #{ENV['AWS_S3_BUCKET_NAME']}).split.
directories.delete_if {|i| i == "DIR"}
# directories = %x(echo )
# directories = ""
#puts "directories: #{directories}"
directories.each do |dir|
  outputs << {
    _collection: 'directories',
    _id: dir,
    directory: dir,
  }
end
