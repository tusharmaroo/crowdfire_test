class TwitterController < ApplicationController

  before_action :create_service_instance, only: [:result]

  def index
    # poor index page
  end

  def result
    if params[:username].present? || params[:userid].present?
      user_reference = params[:username] || params[:userid]
      begin
        @best_time_to_tweet, @best_day_to_tweet = @api_obj.calculate_best_tweet_time(user_reference)
      rescue
        Rails.logger.info "Tech Issue: Current Time: #{Time.zone.now}, user_reference: #{user_reference}"
        redirect_to root_url
      end
    end
  end

  private
    def create_service_instance
      begin
        @api_obj = TwitterService.new
        rescue
          Rails.logger.info "Error: Not able to create Twitter Service instance"
        end
    end

end
