class CreateUserIterableEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :user_iterable_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :iterable_event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
