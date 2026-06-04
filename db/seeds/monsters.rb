species_data = [
  {
    description: "炎の力を持ったモンスター。レベルが上がるにつれ、炎の翼を持つ伝説のドラゴンへと進化する。",
    name_stage_1: "ヒノコ", name_stage_2: "カエン", name_stage_3: "フレイムドラゴン",
    evolution_level_1: 5, evolution_level_2: 10,
    images: %w[flame_dragon_stage1.png flame_dragon_stage2.png flame_dragon_stage3.png]
  },
  {
    description: "水の精霊のような存在。清らかな水の力を使って成長していく。",
    name_stage_1: "ミズチ", name_stage_2: "アクア", name_stage_3: "ウォータースピリット",
    evolution_level_1: 4, evolution_level_2: 9,
    images: %w[water_spirit_stage1.png water_spirit_stage2.png water_spirit_stage3.png]
  },
  {
    description: "森の守護者。植物と一体化したような姿を持ち、成長すると巨大な樹の獣になる。",
    name_stage_1: "モリゾー", name_stage_2: "ジャングラ", name_stage_3: "リーフビースト",
    evolution_level_1: 6, evolution_level_2: 12,
    images: %w[leaf_beast_stage1.png leaf_beast_stage1.png leaf_beast_stage1.png]
  }
]

species_data.each do |data|
  image_filenames = data.delete(:images)
  species = MonsterSpecies.find_or_create_by!(name_stage_1: data[:name_stage_1]) do |s|
    s.assign_attributes(data)
  end

  next if species.images.attached?

  image_filenames.each do |filename|
    path = Rails.root.join("app/assets/images/#{filename}")
    next unless File.exist?(path)
    species.images.attach(
      io: File.open(path),
      filename: filename,
      content_type: "image/png"
    )
  end
end
