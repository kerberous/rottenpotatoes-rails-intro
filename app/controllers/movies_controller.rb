class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.uniq.pluck(:rating)
    if_redirect = false

    if params[:ratings]
      session[:ratings]= params[:ratings].keys
    else if session[:ratings]
           if_redirect = true
         else
           session[:ratings] = @all_ratings
         end
    end
    @selected_ratings = session[:ratings]

    if params[:sortby]
      session[:sortby] = params[:sortby]
    else if session[:sortby]
           if_redirect = true
         end
    end

    @movies = Movie.where(:rating => session[:ratings]).order(session[:sortby]).all

    if session[:sortby]=='title'
      @title_header = 'hilite'
    end
    if session[:sortby]=='release_date'
      @release_date_header = 'hilite'
    end

    if if_redirect
      ratings_hash = {}
      session[:ratings].each do |selected|
        ratings_hash[selected] = 1
      end
      redirect_to movies_path(:ratings => ratings_hash, :sortby => session[:sortby])
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end


end
