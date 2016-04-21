class CreateTextFiles < ActiveRecord::Migration
  def change
    create_table :text_files do |t|
      t.string :title
      t.text :text

      t.timestamps null: false
    end
  end
end
