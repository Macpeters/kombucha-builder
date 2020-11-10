# frozen_string_literal: true

require 'rails_helper'

describe Api::RatingsController, type: :request do
  let(:response_body) { JSON.parse(response.body) }
  let(:current_user) { create(:user) }
  let(:headers) { { 'USER_ID': current_user.id } }
  let(:kombucha) { create(:kombucha) }

  describe "#create" do
    let(:request_params) {
      {
        rating: {
          score: 5,
          kombucha_id: kombucha.id
        }
      }
    }

    it "creates a rating" do
      expect { post "/api/ratings", params: request_params, headers: headers }.to change(Rating, :count).by(1)
    end

    it "only allows one rating per user per kombucha" do
      create(:rating, user_id: current_user, kombucha_id: kombucha.id)
      expect { post "/api/ratings", params: request_params, headers: headers }.not_to change(Rating, :count)
    end

    it "requires the score to be 1-5" do
      request_params[:rating][:score] = 10
      expect { post "/api/ratings", params: request_params, headers: headers }.not_to change(Rating, :count)

      request_params[:rating][:score] = -3
      expect { post "/api/ratings", params: request_params, headers: headers }.not_to change(Rating, :count)
    end
  end
end
