# ロードマップ

## 進行中

### インフラ移行
- [ ] Render → AWS 移行（EC2 / ECS + RDS + S3）
- [x] CarrierWave → ActiveStorage 移行（S3対応のため）

## 予定

### ゲームデザイン改善
- [x] GPS追跡機能の実装（Leaflet.js + Geolocation API + Nominatim）
  - 50m自動完了、100m接近アラート
  - Google Maps API 不要に（Nominatim/OpenStreetMapに移行）
  - `feature/gps-walking` ブランチで実装済み

### DB整理
- [ ] `monster_species` テーブルのリファクタリング（`monster_stages` テーブルに分離、name_stage_1/2/3 と画像をステージ単位で管理）

### 機能追加
- [ ] （追加予定の機能をここに記載）

## 完了

- [x] MVPリリース（Renderデプロイ）
- [x] Google OAuth2 ログイン
- [x] モンスター育成（EXP・レベルアップ）
- [x] 歩行記録（Destination）
- [x] ランキング機能（週次・月次）
- [x] 投稿・コメント機能
- [x] 画像フォールバック（no_image.png）
