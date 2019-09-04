directories = `s3cmd ls #{ENV['AWS_S3_BUCKET_NAME']}`
puts "directories: #{directories}"

outputs << {
    _collection: 'directories',
    _id: 'directories',
    directories: directories
  }