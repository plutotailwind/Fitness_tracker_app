import numpy as np
from collections import deque
import time
import cv2
from typing import Optional

# Lazy imports for CLIP and PIL to avoid heavy startup costs if not needed
_clip_model = None
_clip_preprocess = None
_clip_device = None


def _lazy_load_clip():
	global _clip_model, _clip_preprocess, _clip_device
	if _clip_model is not None:
		return
	try:
		import torch
		import clip  # type: ignore
		from PIL import Image  # noqa: F401
		_clip_device = "cuda" if torch.cuda.is_available() else "cpu"
		_clip_model, _clip_preprocess = clip.load("ViT-B/32", device=_clip_device)
	except Exception as e:
		print(f"[WEIGHTS][CLIP] Failed to load CLIP: {e}")
		_clip_model = None
		_clip_preprocess = None
		_clip_device = None


class WeightsClipDetector:
	"""
	Stateful CLIP-based weights detector.
	- Waits for both wrists to be stably visible for a warmup window
	- Then samples N crops around wrists and runs CLIP classification
	- Only when majority == 'bottle' -> weights equipped
	"""
	def __init__(self):
		self.warmup_required_secs = 5.0
		self.sample_every_secs = 2.0
		self.num_samples = 5
		self.conf_threshold = 0.60
		self.categories = ["dumbbell", "hand", "bottle"]
		self.clip_text_tokens = None
		self.wrist_visible_start: Optional[float] = None
		self.prediction_window_active = False
		self.predictions = []
		self.last_prediction_time =  None
		self.prediction_window_start = None
		self.weights_equipped = False

		# Prepare CLIP
		_lazy_load_clip()
		self._init_tokens()

	def _init_tokens(self):
		try:
			import torch
			import clip  # type: ignore
			if _clip_model is not None:
				self.clip_text_tokens = clip.tokenize(self.categories).to(_clip_device)
		except Exception as e:
			print(f"[WEIGHTS][CLIP] tokenize failed: {e}")
			self.clip_text_tokens = None

	def _classify_crop(self, frame_bgr, bbox):
		"""Crop around bbox and run CLIP classification, return probs np.array shape [len(categories)]."""
		if _clip_model is None or _clip_preprocess is None or self.clip_text_tokens is None:
			return None
		try:
			from PIL import Image
			import torch
			x1, y1, x2, y2 = bbox
			h, w, _ = frame_bgr.shape
			x1, y1 = max(0, x1), max(0, y1)
			x2, y2 = min(w, x2), min(h, y2)
			crop = frame_bgr[y1:y2, x1:x2]
			if crop.size == 0:
				crop = frame_bgr
			image_rgb = cv2.cvtColor(crop, cv2.COLOR_BGR2RGB)
			pil_image = Image.fromarray(image_rgb)
			image_preprocessed = _clip_preprocess(pil_image).unsqueeze(0).to(_clip_device)
			with torch.no_grad():
				logits_per_image, _ = _clip_model(image_preprocessed, self.clip_text_tokens)
				probs = logits_per_image.softmax(dim=-1).cpu().numpy()[0]
			return probs
		except Exception as e:
			print(f"[WEIGHTS][CLIP] classify error: {e}")
			return None

	def _build_wrist_bboxes(self, frame_bgr, us_lmk_arr):
		"""Build simple bounding boxes around left/right wrists from pose landmarks (normalized coords)."""
		# Mediapipe Pose indices: 15 (left wrist), 16 (right wrist)
		if us_lmk_arr is None or us_lmk_arr.shape[0] < 17:
			return []
		h, w, _ = frame_bgr.shape
		bboxes = []
		margin = 40
		for idx in (15, 16):
			try:
				x = int(us_lmk_arr[idx, 0] * w)
				y = int(us_lmk_arr[idx, 1] * h)
				x1, y1 = max(0, x - margin), max(0, y - margin)
				x2, y2 = min(w, x + margin), min(h, y + margin)
				bboxes.append((x1, y1, x2, y2))
			except Exception:
				continue
		return bboxes

	def update(self, frame_bgr, us_lmk_arr) -> bool:
		"""
		Return True only after final majority decision == 'bottle'.
		After True once, remains True.
		"""
		if self.weights_equipped:
			return True

		# Determine if both wrists are reasonably on screen from pose landmarks (not exact, but sufficient gate)
		both_wrists_visible = False
		try:
			wr_l = us_lmk_arr[15]
			wr_r = us_lmk_arr[16]
			# visible if normalized coords are within [0,1]
			both_wrists_visible = (0.0 <= wr_l[0] <= 1.0 and 0.0 <= wr_l[1] <= 1.0 and
			                     0.0 <= wr_r[0] <= 1.0 and 0.0 <= wr_r[1] <= 1.0)
		except Exception:
			both_wrists_visible = False

		current_time = time.time()
		if both_wrists_visible:
			if self.warmup_required_secs > 0 and self.wrist_visible_start is None:
				self.wrist_visible_start = current_time
			elif (not self.prediction_window_active) and (current_time - (self.wrist_visible_start or current_time) >= self.warmup_required_secs):
				# Start prediction window
				self.prediction_window_active = True
				self.predictions = []
				self.last_prediction_time = current_time
				self.prediction_window_start = current_time
		else:
			# Reset if wrists not visible
			self.wrist_visible_start = None
			self.prediction_window_active = False
			self.predictions = []
			self.last_prediction_time = None
			self.prediction_window_start = None

		# If window active, take periodic samples
		if self.prediction_window_active and len(self.predictions) < self.num_samples:
			if current_time - (self.last_prediction_time or 0) >= self.sample_every_secs:
				bboxes = self._build_wrist_bboxes(frame_bgr, us_lmk_arr)
				if bboxes:
					probs = self._classify_crop(frame_bgr, bboxes[0])
					if probs is not None:
						pred_idx = int(np.argmax(probs))
						confidence = float(probs[pred_idx])
						pred_label = self.categories[pred_idx] if confidence >= self.conf_threshold else "uncertain"
						self.predictions.append(pred_label)
						print(f"[WEIGHTS][CLIP] Sample {len(self.predictions)}: {pred_label} (probs: {probs})")
				self.last_prediction_time = current_time

		# If enough samples, take majority decision
		if self.prediction_window_active and len(self.predictions) >= self.num_samples:
			from collections import Counter
			final_prediction = Counter(self.predictions).most_common(1)[0][0]
			print("[WEIGHTS][CLIP] FINAL PREDICTION:", final_prediction)
			self.prediction_window_active = False
			if final_prediction == "bottle":
				self.weights_equipped = True
				return True
			# else: keep checking
		return False


# Singleton detector
_detector: Optional[WeightsClipDetector] = None


def detect_weights(wrist_history_xy: deque, current_frame_bgr=None, current_us_landmarks=None) -> bool:
	"""
	CLIP-based weights detection. Ignores the wrist history and uses the current frame + pose landmarks
	to drive the detector. Returns True only after majority == 'bottle'.
	"""
	global _detector
	if _detector is None:
		_detector = WeightsClipDetector()
	if current_frame_bgr is None or current_us_landmarks is None:
		# Not enough context; keep previous state
		return _detector.weights_equipped
	return _detector.update(current_frame_bgr, current_us_landmarks)


