# frozen_string_literal: true

class UrlsController < ApplicationController
  def index
    # recent 10 short urls
    @url = Url.new
    @urls = Url.latest
  end

  def create
    @url = Url.new(url_params)
    if @url.save
      flash[:success] = 'URL created successfully'
    else
      flash[:error] = @url.errors.full_messages
    end

    redirect_to urls_path
  end

  def show
    @url = Url.find_by!(short_url: params[:url])
    @daily_clicks, @browsers_clicks, @platform_clicks = @url.get_analytics
  end

  def visit
    @url = Url.find_by!(short_url: params[:short_url])
    @url.perform_click!(browser.name, browser.platform&.name || 'unknown')

    redirect_to @url.original_url
  end

  private

  def url_params
    params.require(:url).permit(:original_url)
  end
end
