class Destination < ApplicationRecord
  geocoded_by :address
  # latitude/longitudeが未設定の場合のみgeocodeを実行（GPS設定時はスキップ）
  after_validation :geocode, if: -> { latitude.nil? || longitude.nil? }

  belongs_to :user

  validates :start, presence: true
  validates :end, presence: true
  # distance/durationはGPS歩行完了後に設定されるため必須としない
  validate :walkable_distance

  # 歩行データ登録後、リアルタイムランキング更新を実行
  after_create_commit :refresh_user_rankings_realtime

  private

  # 距離が15kmを超えていたらバリデーションエラー
  def walkable_distance
    dist_value = distance.to_s.match(/[\d\.]+/).to_s.to_f
    max_distance_km = 15.0

    if dist_value > max_distance_km
      errors.add(:distance, "は最大#{max_distance_km}kmまでにしてください。")
    end
  end

  # リアルタイムランキング更新用の処理
  def refresh_user_rankings_realtime
    # current_userはモデルにないため関連付けのuserを使う
    UserRankingRealtimeUpdater.refresh_all_periods_for(user)
  end
end
