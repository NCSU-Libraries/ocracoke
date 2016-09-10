class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  protected

  def authenticate_with_token
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, token_for_user(options))
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: 'Bad credentials', status: 401
  end

  def token_for_user(options)
    Rails.configuration.api_tokens[options['user']]
  end

end
