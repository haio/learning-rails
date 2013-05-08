class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.page(params[:page])
    end
  end

  def help
  end
  
  def about
    flash[:notice] = "Testing the flash"
  end

  def json
    #render json: { time: Time.now }
    # render nothing: true
    #render :home
    #render "othercontroller/action"
    render inline: "<p>This is a P</p>"
  end
end