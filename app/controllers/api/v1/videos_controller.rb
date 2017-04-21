class Api::V1::VideosController < ApplicationController

  def index
    playlist = Playlist.find_by(id: params[:playlist_id])

    if playlist && @videos = playlist.videos
      render 'videos/videos.json.jbuilder', videos: @videos
    else
      render json: {
        errors: {
          videos: ["No videos found with the given playlist id"]
        }
      }
    end
  end
end