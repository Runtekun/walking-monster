class RemoveCarrierwaveColumns < ActiveRecord::Migration[7.2]
  def change
    remove_column :posts, :post_image, :string
    remove_column :users, :avatar, :string
    remove_column :monster_species, :image_1, :string
    remove_column :monster_species, :image_2, :string
    remove_column :monster_species, :image_3, :string
  end
end
