class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.string :content
      t.references :parent, foreign_key: {to_table: :comments}
      t.references :user, null: false, foreign_key: true
      t.references :commentable, polymorphic: true, null: true, index: true

      t.timestamps
    end
  end
end
