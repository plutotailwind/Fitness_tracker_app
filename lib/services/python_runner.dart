import 'dart:convert';
import 'dart:io';

class PythonRunner {
  static Future<Process?> runExerciseScript({
    required String pythonExePath, // pass '' to auto-detect
    required String projectRoot,
    required String trainerVideoPath,
  }) async {
    try {
      final scriptPath = PathHelper.join(projectRoot, 'Fitness_tracker', 'exercise.py');
      if (!File(scriptPath).existsSync()) {
        stderr.writeln('exercise.py not found at: ' + scriptPath);
        return null;
      }

      // Auto-detect venv python on Windows if no explicit path is provided
      var python = pythonExePath;
      if (python.isEmpty) {
        if (Platform.isWindows) {
          final venvPy = PathHelper.join(projectRoot, 'Fitness_tracker', '.venv');
          final winPy = PathHelper.join(venvPy, 'Scripts', 'python.exe');
          if (File(winPy).existsSync()) {
            python = winPy;
          } else {
            python = 'python';
          }
        } else {
          final venvPy = PathHelper.join(projectRoot, 'Fitness_tracker', '.venv');
          final nixPy = PathHelper.join(venvPy, 'bin', 'python');
          if (File(nixPy).existsSync()) {
            python = nixPy;
          } else {
            python = 'python3';
          }
        }
      }

      final args = <String>[
        scriptPath,
        '--trainer_video',
        trainerVideoPath,
      ];

      final process = await Process.start(
        python,
        args,
        workingDirectory: PathHelper.join(projectRoot, 'Fitness_tracker'),
        mode: ProcessStartMode.normal,
      );

      // Stream stdout / stderr to Flutter console
      process.stdout.transform(utf8.decoder).listen((data) {
        // ignore: avoid_print
        print('[exercise.py] ' + data.trim());
      });
      process.stderr.transform(utf8.decoder).listen((data) {
        // ignore: avoid_print
        print('[exercise.py][err] ' + data.trim());
      });
      return process;
    } catch (e) {
      stderr.writeln('Failed to start exercise.py: ' + e.toString());
      return null;
    }
  }
}

class PathHelper {
  static String join(String a, String b, [String? c]) {
    final sep = Platform.pathSeparator;
    if (c == null) {
      return a.replaceAll(RegExp(r'[\\/]$'), '') + sep + b.replaceAll(RegExp(r'^[\\/]'), '');
    }
    final ab = join(a, b);
    return join(ab, c);
  }
}


