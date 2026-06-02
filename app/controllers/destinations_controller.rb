class DestinationsController < ApplicationController
  before_action :set_destination, only: [ :show, :destroy, :complete_walk, :walking ]

  def index
    @destinations = current_user.destinations
    @user_monster = current_user.user_monster
    @species = @user_monster&.monster_species
  end

  def create
    @destination = current_user.destinations.new(destination_params)
    if @destination.save
      redirect_to walking_destination_path(@destination), notice: "冒険を開始します！"
    else
      flash.now[:alert] = "保存に失敗しました: #{@destination.errors.full_messages.to_sentence}"
      @destinations = current_user.destinations
      @user_monster = current_user.user_monster
      @species = @user_monster&.monster_species
      render :index
    end
  end

  def show
  end

  def destroy
    @destination.destroy
    redirect_to destinations_path, notice: "冒険記録を削除しました"
  end

  # 歩行中GPS追跡のためのアクション
  def walking
    if @destination.walked_at.present?
      redirect_to destinations_path, alert: "この冒険は完了済みです"
    end
  end

  def complete_walk
    if @destination.walked_at.present?
      return render json: { error: "この経路はすでに完了しています。" }, status: :unprocessable_entity
    end

    # GPS座標検証（サーバー側）
    current_lat = params[:current_lat].to_f
    current_lng = params[:current_lng].to_f

    if current_lat != 0.0 && current_lng != 0.0
      distance_to_goal_km = Geocoder::Calculations.distance_between(
        [current_lat, current_lng],
        [@destination.latitude, @destination.longitude]
      )
      distance_to_goal_m = distance_to_goal_km * 1000

      if distance_to_goal_m > 50
        return render json: {
          error: "目的地に到達していません（目的地まであと#{distance_to_goal_m.round}m）"
        }, status: :unprocessable_entity
      end
    end

    # EXP計算（JS側で計測した実歩行距離を使用）
    total_distance_m = params[:total_distance_m].to_f
    exp = (total_distance_m / 100.0 * 10).floor

    user_monster = current_user.user_monster
    if user_monster
      user_monster.experience += exp
      user_monster.recalculate_level!
      user_monster.save!
    end

    @destination.walked_at = Time.current
    @destination.distance = "#{(total_distance_m / 1000.0).round(2)} km"
    @destination.steps = (total_distance_m / 0.7).round
    @destination.save!

    UserRankingRealtimeUpdater.refresh_all_periods

    render json: {
      success: true,
      exp: exp,
      level: user_monster&.level,
      message: "お疲れ様！モンスターが#{exp}EXPを獲得したよ！"
    }
  end

  private

  def set_destination
    @destination = current_user.destinations.find_by(id: params[:id])
    unless @destination
      redirect_to destinations_path, alert: "指定された経路は見つかりませんでした"
    end
  end

  def destination_params
    params.require(:destination).permit(:start, :end, :latitude, :longitude, :address)
  end
end
