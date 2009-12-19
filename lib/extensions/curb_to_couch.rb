module CurbToCouch
  class << self
    def fields_for_doc_with_attachment doc, attachment, name = "untitled.bin", content_type = "application/octet-stream"
      [field_for_curb("_doc",doc.to_json),file_for_curb("_attachments",attachment, name, content_type)]
    end

    def file_for_curb fieldname, data, name, content_type
      curb_file = Curl::PostField.file fieldname, nil, name
      curb_file.content = data.read
      curb_file.content_type = content_type
      curb_file
    end

    def field_for_curb fieldname, content
      Curl::PostField.content fieldname, content
    end

    def post_data uri, fields = []
      easy = Curl::Easy.new uri
      easy.multipart_form_post = true
      easy.verbose = true
      easy.http_post *fields
      easy.body_str
    end

    def download(url, path)
      file = File.new(path,"wb")
      easy = Curl::Easy.new(url)
      easy.follow_location = true
      easy.on_body do |data| 
        file.write data 
      end
      easy.perform
      file.close
      File.new(file.path)
    end
  end
end
