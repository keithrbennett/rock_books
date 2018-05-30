module RockBooks

  module ParseHelper

    module_function


    def find_document_type(document_lines)
      doc_type_line = document_lines.detect { |line| /^@doc_type: /.match(line) }
      if doc_type_line.nil?
        nil
      else
        doc_type_line.split(/^@doc_type: /).last.strip
      end
    end


    def find_document_type_in_file(filespec)
      find_document_type(File.readlines(filespec))
    end
  end
end