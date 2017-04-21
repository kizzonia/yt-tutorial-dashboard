require 'rails_helper'

RSpec.describe "Api::V1::Playlists", type: :request do


  before(:each) do
    User.destroy_all
    Playlist.destroy_all
    Video.destroy_all

    @user = User.create(
      username: "NewUser",
      password: "password"
    )
    @token = Auth.create_token(@user.id)
    @token_headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': "Bearer: #{@token}"
    }
    @tokenless_headers = {
      'Content-Type': 'application/json'
    }

    @params = {
      playlist: {
        title: "My Playlist",
        playlist_id: "123456",
        description: "",
        thumbnail_url: "demo.jpg",
        videos_attributes: [
          {
            title: "My first video",
            video_id: "jklior",
            description: "",
            thumbnail_url: "vid1.jpg"
          },
          {
            title: "My second video",
            video_id: "lkjfda",
            description: "",
            thumbnail_url: "vid2.jpg"
          }
        ]
      }
    }.to_json
  end

  it "requires all routes to have a token" do
    responses = []
    response_bodies = []

    post '/api/v1/playlists', params: @params.to_json, headers: @tokenless_headers
    responses << response
    response_bodies << JSON.parse(response.body)

    get '/api/v1/playlists', headers: @tokenless_headers
    responses << response
    response_bodies << JSON.parse(response.body)

    responses.each { |r| expect(r).to have_http_status(403) }
    response_bodies.each { |body| expect(body["errors"]).to eq([{ "message" => "You must include a JWT token!"}]) }

  end

  describe "actions" do
    before(:each) do
      @user.playlists.create(title: "title", playlist_id: "abcd123", description: "", thumbnail_url: "this.jpg")
    end

    describe "#index" do
      it "it does not return all playlists" do
        user2 = User.create(username: "User2", password: "password")
        user2.playlists.create(title: "title2", playlist_id: "abcd1234", description: "", thumbnail_url: "this2.jpg")
        get '/api/v1/playlists', headers: @token_headers
        body = JSON.parse(response.body)
        expect(body.count).not_to eq(2)
        expect(body.count).not_to eq("")
      end

      it "returns an array of playlists belonging to a logged in user on success" do
        get '/api/v1/playlists', headers: @token_headers
        body = JSON.parse(response.body)
        expect(body).to eq(
        [
          {
            "id"=>@user.playlists.last.id,
            "title"=>"title",
            "playlist_id"=>"abcd123",
            "description"=>"",
            "thumbnail_url"=>"this.jpg",
            "user_id"=>@user.id
          }
        ]
      )
      end
    end

    describe "#create" do

      it "creates a new instance of Playlist on success" do
        playlist_count = Playlist.all.count
        post '/api/v1/playlists', params: @params, headers: @token_headers
        body = JSON.parse(response.body)

        expect(Playlist.all.count).not_to eq(playlist_count)
        expect(body).to eq(
          {
            "id"=>@user.playlists.last.id,
            "title"=>"My Playlist",
            "playlist_id"=>"123456",
            "description"=>"",
            "thumbnail_url"=>"demo.jpg",
            "user_id"=>@user.id
          }
        )
      end

      it "creates a new Video instance for each video belonging to the playlist" do
        video_count = Video.all.count

        post '/api/v1/playlists', params: @params, headers: @token_headers
        body = JSON.parse(response.body)

        expect(Video.all.count).not_to eq(video_count)
      end

    end

    describe "#show" do
      pending "it does not return all playlists"
      pending "it returns an array of playlists belonging to a logged in user"
    end
  end

end
