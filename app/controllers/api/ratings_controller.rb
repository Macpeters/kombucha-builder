# frozen_string_literal: true

class Api::RatingsController < ApiController
  before_action :authenticate_user!

  def create
    @rating = Rating.new(rating_params.merge(user_id: current_user.id))
    if @rating.save
      render json: @rating
    else
      render json: { errors: @rating.errors }, status: :unprocessable_entity
    end
  end

  def update
  end

  private

    def rating_params
      params.require(:rating).permit(:user_id, :kombucha_id, :score)
    end
end
