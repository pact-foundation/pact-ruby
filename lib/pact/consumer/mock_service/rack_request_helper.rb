module Pact
  module Consumer

    module RackRequestHelper
      REQUEST_KEYS = {
        'REQUEST_METHOD' => :method,
        'PATH_INFO' => :path,
        'QUERY_STRING' => :query,
        'rack.input' => :body
      }

      def params_hash env
        env["QUERY_STRING"].split("&").collect{| param| param.split("=")}.inject({}){|params, param| params[param.first] = URI.decode(param.last); params }
      end

      def request_as_hash_from env
        request = env.inject({}) do |memo, (k, v)|
          request_key = REQUEST_KEYS[k]
          memo[request_key] = v if request_key
          memo
        end

        request[:headers] = headers_from env
        body_string = request[:body].read

        if body_string.empty?
          request.delete :body
        else
          body_is_json = request[:headers]['Content-Type'] =~ /json/
          request[:body] =  body_is_json ? JSON.parse(body_string) : body_string
        end
        request[:method] = request[:method].downcase
        request
      end

      private

      def headers_from env
        headers = env.reject{ |key, value| !(key.start_with?("HTTP") || key == 'CONTENT_TYPE' || key == 'CONTENT_LENGTH')}
        headers.inject({}) do | hash, header |
          hash[standardise_header(header.first)] = header.last
          hash
        end
      end

      def standardise_header header
        header.gsub(/^HTTP_/, '').split("_").collect{|word| word[0] + word[1..-1].downcase}.join("-")
      end
    end
  end
end
