class AsciicastsController < ApplicationController

  before_filter :load_resource, :only => [:show, :bare, :example, :edit, :update, :destroy]
  before_filter :ensure_authenticated!, :only => [:edit, :update, :destroy]
  before_filter :ensure_owner!, :only => [:edit, :update, :destroy]

  respond_to :html, :json, :js

  attr_reader :asciicast

  def index
    render locals: {
      page: AsciicastListPresenter.new(params[:category], params[:order],
                                       params[:page])
    }
  end

  def show
    respond_to do |format|
      format.html do
        view_counter.increment(asciicast, cookies)
        render locals: {
          page: AsciicastPresenter.build(asciicast, current_user, params)
        }
      end

      format.json do
        respond_with asciicast
      end

      format.js do
        respond_with asciicast
      end
    end
  end

  def bare
    response.headers.delete('X-Frame-Options')
    render locals: { page: BareAsciicastPresenter.build(asciicast, params) },
           layout: 'bare'
  end

  def example
    render layout: 'example'
  end

  def edit
  end

  def update
    if asciicast.update_attributes(params[:asciicast])
      redirect_to asciicast_path(asciicast),
                  :notice => 'Asciicast was updated.'
    else
      render :edit
    end
  end

  def destroy
    if asciicast.destroy
      redirect_to profile_path(current_user),
                  :notice => 'Asciicast was deleted.'
    else
      redirect_to asciicast_path(asciicast),
                  :alert => "Oops, we couldn't remove this asciicast. " \
                            "Try again later."
    end
  end

  private

  def load_resource
    @asciicast = Asciicast.find(params[:id])
  end

  def ensure_owner!
    if current_user != asciicast.user
      redirect_to asciicast_path(asciicast), :alert => "You can't do that."
    end
  end

  def view_counter
    @view_counter ||= ViewCounter.new
  end

end
