import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';

mixin WebRTCStatsMixin {
  RTCPeerConnection? get peerConnection;
  void log(String message);

  Timer? _statsTimer;

  // 缓存上次的 bytesSent & timestamp，用于计算带宽
  final Map<String, _StatCache> _caches = {};

  void startStats({Duration interval = const Duration(seconds: 5)}) {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(interval, (_) async {
      if (peerConnection?.connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        try {
          final reports = await peerConnection!.getStats();
          _reportKeyMetrics(reports);
        } catch (e) {
          log("获取 Stats 失败: $e");
          stopStats();
        }
      } else {
        stopStats();
      }
    });
    log("✅ 已启动 Stats 收集，每 ${interval.inSeconds}s 一次");
  }

  void stopStats() {
    _statsTimer?.cancel();
    _statsTimer = null;
    log("🛑 已停止 Stats 收集");
  }

  void _reportKeyMetrics(List<StatsReport> reports) {
    int? packetsLost;
    double? rttSec;
    double? fps;
    int? width, height;
    int? bitrateBps;

    for (var r in reports) {
      final m = r.values;
      switch (r.type) {
        case 'outbound-rtp':
          // 只针对 video track 计算
          if ((m['mediaType'] ?? m['kind']) == 'video') {
            final cache = _caches.putIfAbsent(r.id, () => _StatCache());
            bitrateBps = cache.computeBitrate(r);
          }
          break;
        case 'inbound-rtp':
          if ((m['mediaType'] ?? m['kind']) == 'video') {
            final rawLost = m['packetsLost'];
            packetsLost =
                rawLost is num ? rawLost.toInt() : int.tryParse(rawLost ?? '');
          }
          break;
        case 'candidate-pair':
          if (m['state'] == 'succeeded') {
            final rawRtt = m['currentRoundTripTime'];
            rttSec =
                rawRtt is num
                    ? rawRtt.toDouble()
                    : double.tryParse(rawRtt ?? '');
          }
          break;
        case 'track':
          if (m['kind'] == 'video') {
            final rawFps = m['framesPerSecond'];
            fps =
                rawFps is num
                    ? rawFps.toDouble()
                    : double.tryParse(rawFps ?? '');
            final rawW = m['frameWidth'], rawH = m['frameHeight'];
            width = rawW is num ? rawW.toInt() : int.tryParse(rawW ?? '');
            height = rawH is num ? rawH.toInt() : int.tryParse(rawH ?? '');
          }
          break;
      }
    }

    // 构造结构化输出

    //bitrate_bps（比特率 bps）
    //packets_lost（丢包数）
    //rtt_ms（往返时延 毫秒）
    //fps（帧率 FPS）
    //resolution（分辨率）
    //timestamp（时间戳）
    final stats = {
      'bitrate_bps': bitrateBps,
      'packets_lost': packetsLost,
      'rtt_ms': rttSec != null ? (rttSec * 1000).round() : null,
      'fps': fps?.toStringAsFixed(1),
      'resolution':
          (width != null && height != null) ? '${width}x$height' : null,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 清理 null 字段，只输出实际数据
    stats.removeWhere((_, v) => v == null);

    log("WebRTC Stats → ${jsonEncode(stats)}");
  }
}

/// 用于缓存上次 bytesSent 和 timestamp，并计算带宽
class _StatCache {
  int? _lastBytes;
  double? _lastTs;

  int? computeBitrate(StatsReport report) {
    final raw = report.values['bytesSent'];
    final bytes = raw is num ? raw.toInt() : int.tryParse(raw ?? '');
    final ts = report.timestamp; // ms
    int? bps;
    if (_lastBytes != null && _lastTs != null && bytes != null) {
      final deltaB = bytes - _lastBytes!;
      final deltaS = (ts - _lastTs!) / 1000.0;
      if (deltaB > 0 && deltaS > 0) {
        bps = (deltaB * 8 / deltaS).round();
      }
    }
    _lastBytes = bytes;
    _lastTs = ts;
    return bps;
  }
}
