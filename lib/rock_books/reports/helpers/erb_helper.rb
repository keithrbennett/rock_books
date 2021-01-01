module ErbHelper

  def self.erb_template(erb_relative_filespec)
    erb_filespec = File.absolute_path(File.join(File.dirname(__FILE__), '..', 'templates', erb_relative_filespec))
    eoutvar = "@outvar_#{erb_relative_filespec.split('.').first.split('/').last}" # dots will be evaulated by `eval`, must remove them
    ERB.new(File.read(erb_filespec), eoutvar: eoutvar, trim_mode: '-')
  end


  def self.render_binding(erb_relative_filespec, template_binding)
    print "Rendering template #{erb_relative_filespec}..."
    result = erb_template(erb_relative_filespec).result(template_binding)
    puts 'done.'
    result
  end

  # Takes 2 hashes, one with data, and the other with presentation functions/lambdas, and passes their union to ERB
  # for rendering.
  def self.render_hashes(erb_relative_filespec, data_hash, presentation_hash)
    print "Rendering template #{erb_relative_filespec}..."
    combined_hash = (data_hash || {}).merge(presentation_hash || {})
    result = erb_template(erb_relative_filespec).result_with_hash(combined_hash)
    puts 'done.'
    result
  end
end