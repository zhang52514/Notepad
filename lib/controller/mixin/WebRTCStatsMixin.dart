import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';

mixin WebRTCStatsMixin {
  RTCPeerConnection? get peerConnection;
  void log(String message);

  Timer? _statsTimer;

  void startStats({Duration interval = const Duration(seconds: 5)}) {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(interval, (_) async {
      if (peerConnection?.connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        try {
          final reports = await peerConnection!.getStats();
          _reportKeyMetrics(reports);
        } catch (e) {
          log("获取Stats失败: $e");
          stopStats();
        }
      } else {
        stopStats();
      }
    });
    log("已启动 Stats 收集，每 ${interval.inSeconds}s 一次");
  }

  void stopStats() {
    _statsTimer?.cancel();
    _statsTimer = null;
    log("已停止 Stats 收集");
  }

  void _reportKeyMetrics(List<StatsReport> reports) {
    String info = "[WebRTC Stats]";
    int? bytesSent;
    int? packetsLost;
    double? rttSec;
    double? fps;
    int? width;
    int? height;

    for (var r in reports) {
      final Map<dynamic, dynamic> m = r.values;
      switch (r.type) {
        case 'outbound-rtp':
          _computeBitrate(r);
          break;
        case 'inbound-rtp':
          final rawLost = m['packetsLost'];
          packetsLost =
              rawLost is String
                  ? int.tryParse(rawLost)
                  : (rawLost is num ? rawLost.toInt() : null);
          break;
        case 'candidate-pair':
          if (m['state'] == 'succeeded') {
            final rawRtt = m['currentRoundTripTime'];
            rttSec =
                rawRtt is String
                    ? double.tryParse(rawRtt)
                    : (rawRtt is num ? rawRtt.toDouble() : null);
          }
          break;
        case 'track':
          if (m['kind'] == 'video') {
            final rawFps = m['framesPerSecond'];
            fps =
                rawFps is String
                    ? double.tryParse(rawFps)
                    : (rawFps is num ? rawFps.toDouble() : null);
            final rawW = m['frameWidth'], rawH = m['frameHeight'];
            width =
                rawW is String
                    ? int.tryParse(rawW)
                    : (rawW is num ? rawW.toInt() : null);
            height =
                rawH is String
                    ? int.tryParse(rawH)
                    : (rawH is num ? rawH.toInt() : null);
          }
          break;
      }
    }

    // 拼接丢包、RTT、FPS、分辨率
    if (packetsLost != null) info += " | Lost: $packetsLost";
    if (rttSec != null)
      info += " | RTT: ${(rttSec * 1000).toStringAsFixed(0)} ms";
    if (fps != null) info += " | FPS: ${fps.toStringAsFixed(1)}";
    if (width != null && height != null) {
      info += " | Res: ${width}x$height";
    }

    log(info);
  }

  int? _lastBytesSent;
  double? _lastTimestamp;
  void _computeBitrate(StatsReport r) {
    final rawBytes = r.values['bytesSent'];
    final bytes =
        rawBytes is String ? int.parse(rawBytes) : (rawBytes as num).toInt();
    final ts = r.timestamp; // ms
    if (_lastBytesSent != null && _lastTimestamp != null) {
      final deltaBytes = bytes - _lastBytesSent!;
      final deltaSecs = (ts - _lastTimestamp!) / 1000.0;
      final bps = deltaSecs > 0 ? (deltaBytes * 8 / deltaSecs).round() : 0;
      log(">>> 实时带宽: $bps bps");
    }
    _lastBytesSent = bytes;
    _lastTimestamp = ts;
  }
}
