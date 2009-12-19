module MainHelper
  def sinatra(*path_components)
    ::File.join(SINATRA_ROOT,*path_components)
  end
end
