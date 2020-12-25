module ErbHelper

  def self.erb_template(erb_filename)
    erb_filespec = File.absolute_path(File.join(File.dirname(__FILE__), '..', 'templates', erb_filename))
    eoutvar = "@outvar_#{erb_filename.split('.').first}" # dots will be evaulated by `eval`, must remove them
    ERB.new(File.read(erb_filespec), eoutvar: eoutvar, trim_mode: '-')
  end


  def self.render_binding(erb_filename, template_binding)
    puts "Rendering template #{erb_filename}..."
    erb_template(erb_filename).result(template_binding)
  end

  # Takes 2 hashes, one with data, and the other with presentation functions/lambdas, and passes their union to ERB
  # for rendering.
  def self.render_hashes(erb_filename, data_hash, presentation_hash)
    puts "Rendering template #{erb_filename}..."
    combined_hash = (data_hash || {}).merge(presentation_hash || {})
    erb_template(erb_filename).result_with_hash(combined_hash)
  end
end