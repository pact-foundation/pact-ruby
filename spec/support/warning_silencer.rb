module WarningSilencer
  extend self

  def enable
    old, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old
  end
end
