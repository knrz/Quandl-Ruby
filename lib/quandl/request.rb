require 'open-uri'

module Quandl
  API_URI = 'https://www.quandl.com/api/'

  class Request
    attr_accessor :uri

    def initialize(base, params)
      path = [Quandl.configuration.api_version, base]
      if Quandl.configuration.auth_token
        params[:options][:auth_token] = Quandl.configuration.auth_token
      end
      [:source, :table].each do |param|
        path << params[param] if params[param]
      end
      if params[:query]
        params[:options][:query] = params[:query]
      end
      path = path.join('/')
      if params[:datasets]
        params[:options][:columns] = params[:datasets].map { |set| set.split('/').join('.') }
      end
      if params[:dataset]
        path += "/#{params[:dataset]}"
      end
      path += '.' + (params[:options][:format] || 'json').to_s
      @uri = URI(API_URI + path).tap do |uri|
        uri.query = URI.encode_www_form(params[:options])
      end
    end

    def get
      open(uri).read
    end
  end
end
