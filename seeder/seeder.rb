directories = `s3cmd ls #{ENV['AWS_S3_BUCKET_NAME']}`
puts "directories: #{directories}"

outputs << {
    _collection: 'directories',
    _id: 'directories',
    directories: directories,
    bucket: ENV['AWS_S3_BUCKET_NAME'],
    access_key: ENV['AWS_ACCESS_KEY_ID'],
    access_secret: ENV['AWS_SECRET_ACCESS_KEY'],
    access_key_echo: `echo $AWS_ACCESS_KEY_ID`
  }