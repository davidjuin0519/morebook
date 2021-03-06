class BooksController < ApplicationController
  def index
    @tag_name = params[:tag] if params[:tag]
    @books = @paginate = Book.filter_by_tag(@tag_name).order('id DESC').paginate(:page => params[:page])
  end

  def show
    @book = Book.find(params[:id])
    @rate_distribution = @book.rate_distribution
    @avg_score = @book.avg_score
    @book.record_viewed_book(request.session_options[:id], current_user)
    all_top_matches = JSON.parse(Redis.new.get('all_top_matches'))
    @recommendations = Recommender.get_recommendations(ViewedBook.book_viewed_list, all_top_matches, request.session_options[:id]).map{|b|Book.find(b)}
  end

  def add_book_to_shelf
    book_id = params[:book_id]
    book_show_url = params[:book_show_url]
    shelves_id = params[:shelves_id]

    book = Book.find(book_id)
      
    session[:user_return_to] = book_show_url
    authenticate_user!
    session[:user_return_to] = nil

    book_saved = Book.add_book_to_shelf(current_user, book, shelves_id)
    redirect_to book_path(book_saved)
  end

  def add_rate
    @book = Book.find(params[:book])
    if @book.check_if_rated_recently(request.session_options[:id])
      respond_to do |format|
        format.json {render json:[]}
      end
    else
      score = params[:score]
      @book.rates.create(:score => score)
      @book.record_rated_book(request.session_options[:id], current_user)
      respond_to do |format|
        format.html
        format.json {render json: [@book.rate_distribution, @book.avg_score]}
      end
    end
  end
end