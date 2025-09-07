import 'dart:math';
import '../models/reference_video.dart';

class PoseComparator {
  /// Compare live pose sequence to reference sequence using DTW
  static ComparisonResult comparePoses({
    required List<PoseFrame> liveSequence,
    required List<PoseFrame> referenceSequence,
    required String exerciseType,
  }) {
    if (liveSequence.isEmpty || referenceSequence.isEmpty) {
      return ComparisonResult(
        overallScore: 0.0,
        feedback: ['No pose data available for comparison'],
        repAccuracy: [],
        phaseAlignment: 0.0,
      );
    }

    // Normalize sequences to same length for comparison
    final normalizedLive = _normalizeSequence(liveSequence);
    final normalizedRef = _normalizeSequence(referenceSequence);

    // Compute DTW distance
    final dtwMatrix = _computeDTW(normalizedLive, normalizedRef);
    final dtwDistance = dtwMatrix[normalizedLive.length - 1][normalizedRef.length - 1];

    // Convert DTW distance to similarity score (0-100)
    final maxPossibleDistance = _computeMaxDistance(normalizedLive, normalizedRef);
    final similarityScore = maxPossibleDistance > 0 
        ? (1 - (dtwDistance / maxPossibleDistance)) * 100 
        : 100.0;

    // Generate detailed feedback
    final feedback = _generateFeedback(
      normalizedLive, 
      normalizedRef, 
      exerciseType,
      similarityScore,
    );

    // Compute rep-by-rep accuracy
    final repAccuracy = _computeRepAccuracy(normalizedLive, normalizedRef);

    // Compute phase alignment
    final phaseAlignment = _computePhaseAlignment(normalizedLive, normalizedRef);

    return ComparisonResult(
      overallScore: similarityScore.clamp(0.0, 100.0),
      feedback: feedback,
      repAccuracy: repAccuracy,
      phaseAlignment: phaseAlignment,
    );
  }

  /// Normalize pose sequence to fixed length for comparison
  static List<Map<String, double>> _normalizeSequence(List<PoseFrame> sequence) {
    if (sequence.length <= 1) return [];
    
    final normalized = <Map<String, double>>[];
    final targetLength = 50; // Normalize to 50 frames
    
    for (int i = 0; i < targetLength; i++) {
      final progress = i / (targetLength - 1);
      final frameIndex = (progress * (sequence.length - 1)).round();
      final frame = sequence[frameIndex];
      
      // Extract key metrics for comparison
      final metrics = <String, double>{};
      
      // Add computed angles
      frame.computedAngles.forEach((key, value) {
        metrics[key] = value;
      });
      
      // Add key features
      frame.features.forEach((key, value) {
        if (value is bool) {
          metrics[key] = value ? 1.0 : 0.0;
        } else if (value is num) {
          metrics[key] = value.toDouble();
        }
      });
      
      normalized.add(metrics);
    }
    
    return normalized;
  }

  /// Compute Dynamic Time Warping matrix
  static List<List<double>> _computeDTW(
    List<Map<String, double>> sequence1,
    List<Map<String, double>> sequence2,
  ) {
    final n = sequence1.length;
    final m = sequence2.length;
    
    // Initialize DTW matrix
    final dtw = List.generate(n, (i) => List.filled(m, double.infinity));
    dtw[0][0] = 0;
    
    // Fill first row and column
    for (int i = 1; i < n; i++) {
      dtw[i][0] = dtw[i - 1][0] + _computeFrameDistance(sequence1[i], sequence2[0]);
    }
    
    for (int j = 1; j < m; j++) {
      dtw[0][j] = dtw[0][j - 1] + _computeFrameDistance(sequence1[0], sequence2[j]);
    }
    
    // Fill rest of matrix
    for (int i = 1; i < n; i++) {
      for (int j = 1; j < m; j++) {
        final cost = _computeFrameDistance(sequence1[i], sequence2[j]);
        dtw[i][j] = cost + min(min(dtw[i - 1][j], dtw[i][j - 1]), dtw[i - 1][j - 1]);
      }
    }
    
    return dtw;
  }

  /// Compute distance between two pose frames
  static double _computeFrameDistance(
    Map<String, double> frame1,
    Map<String, double> frame2,
  ) {
    double totalDistance = 0.0;
    int validComparisons = 0;
    
    // Compare common metrics
    frame1.forEach((key, value1) {
      if (frame2.containsKey(key)) {
        final value2 = frame2[key]!;
        final diff = (value1 - value2).abs();
        totalDistance += diff;
        validComparisons++;
      }
    });
    
    return validComparisons > 0 ? totalDistance / validComparisons : double.infinity;
  }

  /// Compute maximum possible DTW distance
  static double _computeMaxDistance(
    List<Map<String, double>> sequence1,
    List<Map<String, double>> sequence2,
  ) {
    double maxDistance = 0.0;
    
    for (final frame1 in sequence1) {
      for (final frame2 in sequence2) {
        final distance = _computeFrameDistance(frame1, frame2);
        if (distance > maxDistance) maxDistance = distance;
      }
    }
    
    return maxDistance * (sequence1.length + sequence2.length);
  }

  /// Generate feedback based on comparison
  static List<String> _generateFeedback(
    List<Map<String, double>> live,
    List<Map<String, double>> reference,
    String exerciseType,
    double score,
  ) {
    final feedback = <String>[];
    
    if (score >= 90) {
      feedback.add('Excellent form! Keep it up.');
    } else if (score >= 80) {
      feedback.add('Good form with minor adjustments needed.');
    } else if (score >= 70) {
      feedback.add('Form needs improvement. Focus on technique.');
    } else {
      feedback.add('Form needs significant improvement. Consider reviewing the reference.');
    }
    
    // Exercise-specific feedback
    switch (exerciseType.toLowerCase()) {
      case 'squats':
        if (score < 80) {
          feedback.add('Focus on keeping knees aligned with toes');
          feedback.add('Maintain proper depth - not too shallow or deep');
        }
        break;
      case 'pushups':
        if (score < 80) {
          feedback.add('Keep your body in a straight line');
          feedback.add('Lower your body fully before pushing up');
        }
        break;
      case 'jumpingjacks':
        if (score < 80) {
          feedback.add('Raise arms fully overhead');
          feedback.add('Jump with feet apart and together');
        }
        break;
      case 'yoga':
        if (score < 80) {
          feedback.add('Maintain proper alignment');
          feedback.add('Breathe steadily throughout the pose');
        }
        break;
    }
    
    return feedback;
  }

  /// Compute accuracy for each rep
  static List<double> _computeRepAccuracy(
    List<Map<String, double>> live,
    List<Map<String, double>> reference,
  ) {
    // For now, return overall accuracy split into segments
    // In a real implementation, you'd detect rep boundaries
    final segments = 5;
    final accuracy = <double>[];
    
    for (int i = 0; i < segments; i++) {
      final start = (i * live.length / segments).round();
      final end = ((i + 1) * live.length / segments).round();
      
      double segmentScore = 0.0;
      int comparisons = 0;
      
      for (int j = start; j < end && j < live.length; j++) {
        final refIndex = (j * reference.length / live.length).round();
        if (refIndex < reference.length) {
          final distance = _computeFrameDistance(live[j], reference[refIndex]);
          segmentScore += (1 - distance.clamp(0.0, 1.0)) * 100;
          comparisons++;
        }
      }
      
      accuracy.add(comparisons > 0 ? segmentScore / comparisons : 0.0);
    }
    
    return accuracy;
  }

  /// Compute phase alignment between sequences
  static double _computePhaseAlignment(
    List<Map<String, double>> live,
    List<Map<String, double>> reference,
  ) {
    if (live.length < 2 || reference.length < 2) return 0.0;
    
    // Simple phase correlation using key metrics
    double alignment = 0.0;
    int comparisons = 0;
    
    for (int i = 0; i < live.length; i++) {
      final refIndex = (i * reference.length / live.length).round();
      if (refIndex < reference.length) {
        final liveProgress = i / (live.length - 1);
        final refProgress = refIndex / (reference.length - 1);
        final phaseDiff = (liveProgress - refProgress).abs();
        alignment += (1 - phaseDiff) * 100;
        comparisons++;
      }
    }
    
    return comparisons > 0 ? alignment / comparisons : 0.0;
  }
}

/// Result of pose comparison
class ComparisonResult {
  final double overallScore;
  final List<String> feedback;
  final List<double> repAccuracy;
  final double phaseAlignment;

  ComparisonResult({
    required this.overallScore,
    required this.feedback,
    required this.repAccuracy,
    required this.phaseAlignment,
  });
}
