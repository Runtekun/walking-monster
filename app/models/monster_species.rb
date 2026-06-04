class MonsterSpecies < ApplicationRecord
  has_many :user_monsters
  has_many_attached :images

  def name_for_level(level)
    if level >= evolution_level_2
      name_stage_3
    elsif level >= evolution_level_1
      name_stage_2
    else
      name_stage_1
    end
  end

  def image_for_level(level)
    index = if level >= evolution_level_2
      2
    elsif level >= evolution_level_1
      1
    else
      0
    end
    images.order(:id).to_a[index]
  end
end
