module Api
  module V1
    # Base for the public, read-only JSON API.
    class BaseController < ApplicationController
      allow_unauthenticated_access
      skip_forgery_protection
    end
  end
end
