class CreateBorrowings < ActiveRecord::Migration[8.1]
  def change
    create_table :borrowings do |t|
      t.bigint :member_id, null: false
      t.bigint :book_id, null: false
      t.datetime :borrowed_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :due_at, null: false
      t.datetime :returned_at

      t.timestamps
    end

    add_index :borrowings, :member_id
    add_index :borrowings, :book_id
    add_index :borrowings, [:member_id, :book_id], unique: true, where: "returned_at IS NULL", name: "index_borrowings_active_per_member"

    add_foreign_key :borrowings, :users, column: :member_id, on_delete: :cascade
    add_foreign_key :borrowings, :books, on_delete: :cascade
  end
end
