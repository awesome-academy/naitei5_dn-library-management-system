require "rails_helper"

RSpec.describe Book, type: :model do
  context "testing book's scopes" do
    it "correctly orders books by descending published date" do
      b1 = FactoryBot.create :book, published_date: 3.days.ago
      b2 = FactoryBot.create :book, published_date: 2.days.ago
      b3 = FactoryBot.create :book, published_date: 4.days.ago

      expect(Book.ordered_by_date).to eq([b2, b1, b3])
    end

    it "correctly selects only published books" do
      b_pub1 = FactoryBot.create :book, :published
      b_pub2 = FactoryBot.create :book, :published
      b_unpub = FactoryBot.create :book, :unpublished

      expect(Book.published).to eq([b_pub1, b_pub2])
    end
  end

  context "testing book's dependent" do
    it "correctly destroys its own comments" do
      book = FactoryBot.create :book
      comment = FactoryBot.create :comment
      book.comments << comment
      expect(Comment.find_by id: comment.id).to be_truthy

      book.destroy
      expect(Comment.find_by id: comment.id).to be_falsy
    end
  end
end
