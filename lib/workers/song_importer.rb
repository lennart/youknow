require ::File.join(::File.dirname(__FILE__),*%w{.. .. config boot})
require ::File.join(::File.dirname(__FILE__),*%w{.. .. config app_config})
require ::File.join(::File.dirname(__FILE__),*%w{.. models song_generator})
require ::File.join(::File.dirname(__FILE__),*%w{.. models youtube})
class SongImporter
  @queue = :default
  def self.perform(params)
    filename, metadata = params
    SongGenerator.add_song(File.new(filename),Metadata.new metadata)
    
  end
end
