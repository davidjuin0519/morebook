class ViewedBook < ActiveRecord::Base
  belongs_to :user

	def self.list_recent_five_viewed_books(session_id, user)
    viewed_books = self.find_by(:session_id => session_id).books_id.split(',').
                        map{|b|Book.find_by(:id => b.to_i)}
    viewed_books.shift
    viewed_books.first(5)
  end

  def self.update_user_id(sid, user)
  	viewed_books = self.find_by(:session_id => sid)
  	if viewed_books && user
  		viewed_books.update(:user_id => user.id)
  	end
  end

  def self.update_session_id(current_sid, old_sid)
    prev_viewed_books = self.find_by(:session_id => old_sid)
    if prev_viewed_books
      prev_viewed_books.update(:session_id => current_sid)
    end
  end

  def self.fake_data
    tags = Tag.select{|t|t.depth==3}
    users = User.all.last(10*tags.count)
    10.times do |t|
      users.pop(tags.count).each_with_index do |u, i|
        viewed_books = tags[i].books.shuffle.first(10).map{|b|b.id}.join(',')
        self.create(:user_id => u.id, :books_id => viewed_books)
        p "#{'='*20}Iteration##{t+1} ViewedBook##{i+1}#{'='*20}"
      end
    end
  end

  def self.book_viewed_list
    results = {}
    unviewed_books_id = Book.all.map{|b|b.id.to_s}
    
    results = ViewedBook.all.reduce({}) do |result, viewed_book|
      user_id = viewed_book.user_id
      viewed_book.books_id.split(',').each do |book_id|
        unviewed_books_id.delete(book_id)
        result[book_id] ||= []
        result[book_id].push(user_id)
      end
      result
    end
    unviewed_books_id.each do |u|
      results[u] = []
    end
    results.sort_by{|k,v|k}.reverse.to_h
  end
end