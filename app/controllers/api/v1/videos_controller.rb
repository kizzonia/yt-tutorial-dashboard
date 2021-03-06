class Api::V1::VideosController < ApplicationController
  before_action :authenticate_token!

  def index
    playlist = Playlist.find_by(id: params[:playlist_id])

    if playlist && playlist.user == current_user && @videos = playlist.videos.sort_by {|x| x.id}
      render 'videos/videos.json.jbuilder', videos: @videos
    else
      render json: {
        errors: ["No videos found with the given playlist id"]
      }
    end
  end

  def reset_videos
    playlist = Playlist.find_by(id: params[:playlist_id])

    if playlist && playlist.user == current_user
      @videos = playlist.videos
      @videos.update(complete?: false)
      render 'videos/videos.json.jbuilder', videos: @videos
    else
      render json: {
        errors: ["No videos found with the given playlist id"]
      }
    end
  end

  def show
    @video = Video.find_by(id: params[:id])
    if @video && current_user.videos.include?(@video)
      render 'videos/video.json.jbuilder', video: @video
    else
      render json: {
        errors: ["No video found with the given id"]
      }
    end
  end

  def complete
    @video = Video.find_by(id: params[:id])
    if @video && current_user.videos.include?(@video)
      @video.update(complete?: true)
      render 'videos/video.json.jbuilder', video: @video
    else
      render json: {
        errors: ["No video found with the given id"]
      }
    end
  end

  def activate
    @video = Video.find_by(id: params[:id])
    if @video && current_user.videos.include?(@video)
      @video.playlist.videos.each do |video|
        video.update(is_active: false)
      end
      @video.update(is_active: true)
      render 'videos/video.json.jbuilder', video: @video
    else
      render json: {
        errors: ["No video found with the given id"]
      }
    end
  end

  private

  def video_params
    params.require(:video).permit(:title)
  end
end
