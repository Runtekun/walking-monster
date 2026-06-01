import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

export default class extends Controller {
  static values = {
    destinationLat: Number,
    destinationLng: Number,
    completeWalkUrl: String
  }

  static targets = ["distance", "nearbyAlert"]

  connect() {
    this.watchId = null
    this.currentLat = null
    this.currentLng = null
    this.isCompleted = false
    this.totalDistanceM = 0
    this.lastLat = null
    this.lastLng = null
    this.isNearbyAlerted = false
    this.map = null
    this.currentMarker = null

    this.initMap()
    this.startTracking()
  }

  disconnect() {
    if (this.watchId) navigator.geolocation.clearWatch(this.watchId)
    if (this.map) { this.map.remove(); this.map = null }
  }

  initMap() {
    const destLat = this.destinationLatValue
    const destLng = this.destinationLngValue

    this.map = L.map("walking-map").setView([destLat, destLng], 15)
    // 国土地理院標準地図: 日本語表示・無料・公式
    L.tileLayer("https://cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png", {
      attribution: '© <a href="https://maps.gsi.go.jp/development/ichiran.html">国土地理院</a>'
    }).addTo(this.map)

    // 目的地マーカー（洞窟アイコン）
    const goalIcon = L.divIcon({
      className: '',
      html: '<div style="font-size:32px;line-height:1;filter:drop-shadow(0 2px 6px rgba(0,0,0,0.7))">🕳️</div>',
      iconSize: [40, 40],
      iconAnchor: [20, 40]
    })
    L.marker([destLat, destLng], { icon: goalIcon })
      .addTo(this.map)
      .bindPopup("🕳️ 目的地")
      .openPopup()

    // 目的地の50m範囲サークル
    L.circle([destLat, destLng], {
      radius: 50,
      color: '#f59e0b',
      fillColor: '#fbbf24',
      fillOpacity: 0.1,
      weight: 2,
      dashArray: '6, 4'
    }).addTo(this.map)
  }

  startTracking() {
    if (!navigator.geolocation) {
      alert("スマートフォンでご利用ください")
      return
    }

    this.watchId = navigator.geolocation.watchPosition(
      (pos) => this.updatePosition(pos),
      (err) => console.error("GPS Error:", err),
      { enableHighAccuracy: true, maximumAge: 5000, timeout: 15000 }
    )
  }

  updatePosition(position) {
    const lat = position.coords.latitude
    const lng = position.coords.longitude

    // 現在地マーカー更新（剣士アイコン）
    if (this.currentMarker) {
      this.currentMarker.setLatLng([lat, lng])
    } else {
      const heroIcon = L.divIcon({
        className: '',
        html: '<div style="font-size:26px;filter:drop-shadow(0 0 6px rgba(59,130,246,0.8))">⚔️</div>',
        iconSize: [32, 32],
        iconAnchor: [16, 16]
      })
      this.currentMarker = L.marker([lat, lng], { icon: heroIcon })
        .addTo(this.map)
        .bindPopup("⚔️ 現在地")
    }
    this.map.panTo([lat, lng])

    // 移動距離を積算（2m以上の移動のみ加算してGPS誤差を除外）
    if (this.lastLat !== null) {
      const moved = this.haversineDistance(this.lastLat, this.lastLng, lat, lng)
      if (moved > 2) {
        this.totalDistanceM += moved
      }
    }
    this.lastLat = lat
    this.lastLng = lng
    this.currentLat = lat
    this.currentLng = lng

    // 目的地までの距離を計算して表示・到達判定
    const distToGoal = this.haversineDistance(lat, lng, this.destinationLatValue, this.destinationLngValue)
    this.updateDistanceDisplay(distToGoal)
    this.checkArrival(distToGoal)
  }

  haversineDistance(lat1, lng1, lat2, lng2) {
    const R = 6371000
    const dLat = (lat2 - lat1) * Math.PI / 180
    const dLng = (lng2 - lng1) * Math.PI / 180
    const a = Math.sin(dLat / 2) ** 2 +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLng / 2) ** 2
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  }

  updateDistanceDisplay(distM) {
    if (this.hasDistanceTarget) {
      this.distanceTarget.textContent = distM >= 1000
        ? `${(distM / 1000).toFixed(1)} km`
        : `${Math.round(distM)} m`
    }
  }

  checkArrival(distM) {
    // 100m以内：接近アラート
    if (distM <= 100 && !this.isNearbyAlerted) {
      this.isNearbyAlerted = true
      this.showNearbyAlert()
    }

    // 50m以内：自動完了
    if (distM <= 50 && !this.isCompleted) {
      this.isCompleted = true
      this.completeWalk()
    }
  }

  showNearbyAlert() {
    if (this.hasNearbyAlertTarget) {
      this.nearbyAlertTarget.classList.remove("hidden")
      setTimeout(() => this.nearbyAlertTarget.classList.add("hidden"), 5000)
    }
  }

  completeWalk() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(this.completeWalkUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        current_lat: this.currentLat,
        current_lng: this.currentLng,
        total_distance_m: Math.round(this.totalDistanceM)
      })
    })
      .then(r => r.json())
      .then(data => {
        if (data.success) {
          this.showCompletion(data)
        } else {
          // GPS誤差などで失敗した場合は再試行できるようにリセット
          this.isCompleted = false
          console.warn("Complete walk failed:", data.error)
        }
      })
      .catch(err => {
        this.isCompleted = false
        console.error("Network error:", err)
      })
  }

  showCompletion(data) {
    if (this.watchId) navigator.geolocation.clearWatch(this.watchId)

    const completeEl = document.getElementById("completion-overlay")
    if (completeEl) {
      document.getElementById("completion-exp").textContent = `+${data.exp} EXP`
      document.getElementById("completion-message").textContent = data.message
      completeEl.classList.remove("hidden")
      // confettiはapplication.jsでグローバルに読み込み済み
      if (typeof confetti !== "undefined") confetti()
    }
  }
}
