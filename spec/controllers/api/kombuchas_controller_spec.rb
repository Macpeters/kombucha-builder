# frozen_string_literal: true

require 'rails_helper'

describe Api::KombuchasController, type: :request do
  let(:response_body) { JSON.parse(response.body) }
  let(:current_user) { create(:user) }
  let(:headers) { { 'USER_ID': current_user.id } }

  describe "#index" do
    it "renders a collection of kombuchas" do
      create_list(:kombucha, 5)

      get '/api/kombuchas', params: {}, headers: headers

      expect(response.status).to eq(200)
      expect(response_body.length).to eq(Kombucha.count)
    end

    it 'returns by fizzyness_level when the param is present' do
      create_list(:kombucha_with_high_fizziness, 3)
      create(:kombucha_with_low_fizziness)
      create(:kombucha_with_medium_fizziness)

      get '/api/kombuchas', params: { fizziness_level: 'high' }, headers: headers
      expect(response_body.count).to eql(3)
    end

    it 'returns kombuchas without any caffeine when the param is true' do
      caf_kombucha = create(:kombucha)
      caf_kombucha.ingredients << create(:ingredient)
      caf_kombucha.ingredients << create(:caffeine_free_ingredient)

      decaf_kombucha = create(:kombucha)
      decaf_kombucha.ingredients << create(:caffeine_free_ingredient)

      get '/api/kombuchas', params: { caffeine_free: 'true' }, headers: headers
      expect(response_body.count).to eql(1)
      expect(response_body.first['id']).to eql(decaf_kombucha.id)
    end

    it 'returns all kombuchas when the caffine_free param is false' do
      caf_kombucha = create(:kombucha)
      caf_kombucha.ingredients << create(:ingredient)
      caf_kombucha.ingredients << create(:caffeine_free_ingredient)

      decaf_kombucha = create(:kombucha)
      decaf_kombucha.ingredients << create(:caffeine_free_ingredient)

      get '/api/kombuchas', params: { caffeine_free: 'false' }, headers: headers
      expect(response_body.count).to eql(2)
    end

    it 'returns all kombuchas when the caffeine_free param is missing' do
      caf_kombucha = create(:kombucha)
      caf_kombucha.ingredients << create(:ingredient)
      caf_kombucha.ingredients << create(:caffeine_free_ingredient)

      decaf_kombucha = create(:kombucha)
      decaf_kombucha.ingredients << create(:caffeine_free_ingredient)

      get '/api/kombuchas', params: {}, headers: headers
      expect(response_body.count).to eql(2)
    end

    it 'returns vegan kombuchas when the param is true' do
      not_vegan_kombucha = create(:kombucha)
      not_vegan_kombucha.ingredients << create(:ingredient)
      not_vegan_kombucha.ingredients << create(:vegan_ingredient)

      vegan_kombucha = create(:kombucha)
      vegan_kombucha.ingredients << create(:vegan_ingredient)

      get '/api/kombuchas', params: { vegan: 'true' }, headers: headers
      expect(response_body.count).to eql(1)
      expect(response_body.first['id']).to eql(vegan_kombucha.id)
    end

    it 'returns all kombuchas when the vegan param is false' do
      not_vegan_kombucha = create(:kombucha)
      not_vegan_kombucha.ingredients << create(:ingredient)
      not_vegan_kombucha.ingredients << create(:vegan_ingredient)

      vegan_kombucha = create(:kombucha)
      vegan_kombucha.ingredients << create(:vegan_ingredient)

      get '/api/kombuchas', params: { vegan: 'false' }, headers: headers
      expect(response_body.count).to eql(2)
    end

    it 'returns all kombuchas when the vegan param is missing' do
      not_vegan_kombucha = create(:kombucha)
      not_vegan_kombucha.ingredients << create(:ingredient)
      not_vegan_kombucha.ingredients << create(:vegan_ingredient)

      vegan_kombucha = create(:kombucha)
      vegan_kombucha.ingredients << create(:vegan_ingredient)

      get '/api/kombuchas', params: {}, headers: headers
      expect(response_body.count).to eql(2)
    end

    it 'returns a kombuchas matching a combination of high fizz, vegan, and caffeine free' do
      matching_kombucha = create(:kombucha_with_high_fizziness)
      matching_kombucha.ingredients << create(:ingredient, caffeine_free: true, vegan: true)

      low_fiz_kombucha = create(:kombucha_with_low_fizziness)
      low_fiz_kombucha.ingredients << create(:ingredient, caffeine_free: true, vegan: true)

      not_vegan_kombucha = create(:kombucha_with_high_fizziness)
      not_vegan_kombucha.ingredients << create(:ingredient, caffeine_free: true)

      caffeinated_kombucha = create(:kombucha_with_high_fizziness)
      caffeinated_kombucha.ingredients << create(:ingredient, vegan: true)

      get '/api/kombuchas', params: {
        fizziness_level: 'high',
        caffeine_free: 'true',
        vegan: 'true'
      }, headers: headers

      expect(response_body.count).to eql(1)
      expect(response_body.first['id']).to eql(matching_kombucha.id)
    end
  end

  describe "#show" do
    it "shows a kombucha" do
      kombucha = create(:kombucha)

      get "/api/kombuchas/#{kombucha.id}", params: {}, headers: headers

      expect(response.message).to eq("OK")
      expect(response_body["id"]).to eq(kombucha.id)
    end
  end

  describe "#create" do
    let(:request_params) {
      {
        kombucha: {
          name: "Orange Pop",
          fizziness_level: "low"
        }
      }
    }

    it "creates a kombucha" do
      expect { post "/api/kombuchas", params: request_params, headers: headers }.to change(Kombucha, :count).by(1)
    end

    it "does not create kombucha if fizziness level is invalid" do
      request_params[:kombucha][:fizziness_level] = "fake"

      expect { post "/api/kombuchas", params: request_params, headers: headers }.not_to change(Kombucha, :count)
    end
  end

  describe "#update" do
    let(:request_params) {
      {
        kombucha: {
          name: "new name",
          fizziness_level: "low"
        }
      }
    }

    it "updates kombucha fizziness level and name" do
      kombucha = create(:kombucha)

      patch "/api/kombuchas/#{kombucha.id}", params: request_params, headers: headers

      expect(response.message).to eq("OK")
      expect(response_body["name"]).to eq("new name")
    end

    it "does not update kombucha if fizziness level is invalid" do
      kombucha = create(:kombucha)

      request_params[:kombucha][:fizziness_level] = "fake"

      patch "/api/kombuchas/#{kombucha.id}", params: request_params, headers: headers

      expect(response.message).to eq("Unprocessable Entity")
    end
  end
end
