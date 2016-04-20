# File and first and last lines created by Rails. All other code ours.
# Contributors: Alex Humphries

class WelcomeController < ApplicationController
  skip_before_action :logged_in_user
  def index
  end
end
