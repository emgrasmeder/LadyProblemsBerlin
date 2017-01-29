class Book < Struct.new(:title)

  # Array of unique words longer than 2 characters.
  # Could also be array of tags or categories.
  def words
    @words ||= self.title.gsub(/[a-zA-Z]{3,}/).map(&:downcase).uniq.sort
  end

end


class BookRecommender

  def initialize book, books
    @book, @books = book, books
  end

  def recommendations

    # Map jaccard_index to each item and sort array
    @books.map! do |this_book|

      # We can define jaccard_index getter in runtime as singleton...
      this_book.define_singleton_method(:jaccard_index) do
        @jaccard_index
      end

      # also setter
      this_book.define_singleton_method("jaccard_index=") do |index|
        @jaccard_index = index || 0.0
      end

      # Calculate intersection between sets
      intersection = (@book.words & this_book.words).size
      # ... and union
      union = (@book.words | this_book.words).size

      # Assign the division and rescue if division is not possible with 0
      this_book.jaccard_index = (intersection.to_f / union.to_f) rescue 0.0

      this_book

      # Sort items
    end.sort_by { |book| 1 - book.jaccard_index }

  end

end


# ...
# Read data and define array of books
BOOKS = [Book.new("Hello world"), Book.new("Ruby test"), Book.new("programming in this is hard")]

# Define current book
current_book = Book.new("Ruby programming language")

# Do recommendation...
books = BookRecommender.new(current_book, BOOKS).recommendations

books.each do |book|
  puts "#{book.title} (#{'%.2f' % book.jaccard_index})"
end
