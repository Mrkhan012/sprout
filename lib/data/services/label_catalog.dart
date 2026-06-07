import 'image_recognizer.dart';

/// Turns a raw on-device model label (e.g. `Flowerpot`) into a playful,
/// kid-friendly [RecognizedLabel] with a matching emoji.
///
/// The ML Kit base model returns ~400 everyday concepts in Title Case; this maps
/// the ones a 3–8 year old is likely to point a camera at to a fun emoji, and
/// falls back to a sparkle for anything not in the table so the child always
/// gets *an* answer to "what is this?".
class LabelCatalog {
  LabelCatalog._();

  static const String _fallbackEmoji = '✨';

  /// Present [raw] (a model label) as a friendly result carrying [confidence].
  static RecognizedLabel present(String raw, double confidence) {
    final clean = raw.trim();
    final key = clean.toLowerCase();
    // Exact match first; otherwise (cloud labels are often multi-word, e.g.
    // "Personal computer") match on any known word so we still find an emoji.
    var emoji = _emoji[key];
    if (emoji == null) {
      for (final word in key.split(RegExp(r'[^a-z]+'))) {
        final hit = _emoji[word];
        if (hit != null) {
          emoji = hit;
          break;
        }
      }
    }
    return RecognizedLabel(
      label: clean,
      emoji: emoji ?? _fallbackEmoji,
      confidence: confidence,
    );
  }

  /// Lower-cased model label → emoji. Grouped roughly by what's around a child.
  static const Map<String, String> _emoji = {
    // ── Nature & outdoors ────────────────────────────────────────────────
    'plant': '🌱', 'flower': '🌸', 'flowerpot': '🪴', 'petal': '🌸',
    'tree': '🌳', 'leaf': '🍃', 'grass': '🌿', 'garden': '🌻',
    'sky': '☁️', 'cloud': '☁️', 'sunset': '🌅', 'sunrise': '🌄',
    'mountain': '⛰️', 'hill': '⛰️', 'beach': '🏖️', 'sand': '🏖️',
    'water': '💧', 'sea': '🌊', 'ocean': '🌊', 'river': '🌊', 'lake': '🌊',
    'rain': '🌧️', 'snow': '❄️', 'rainbow': '🌈', 'sun': '☀️',
    'moon': '🌙', 'star': '⭐', 'rock': '🪨', 'wood': '🪵', 'fire': '🔥',

    // ── Animals ──────────────────────────────────────────────────────────
    'dog': '🐶', 'cat': '🐱', 'bird': '🐦', 'fish': '🐟',
    'butterfly': '🦋', 'insect': '🐛', 'bee': '🐝', 'spider': '🕷️',
    'rabbit': '🐰', 'horse': '🐴', 'cow': '🐮', 'sheep': '🐑',
    'pig': '🐷', 'duck': '🦆', 'chicken': '🐔', 'frog': '🐸',
    'turtle': '🐢', 'lizard': '🦎', 'snail': '🐌', 'ant': '🐜',
    'ladybug': '🐞', 'pet': '🐾', 'animal': '🐾', 'wildlife': '🦌',

    // ── Food ─────────────────────────────────────────────────────────────
    'food': '🍽️', 'fruit': '🍎', 'apple': '🍎', 'banana': '🍌',
    'orange': '🍊', 'strawberry': '🍓', 'grape': '🍇', 'vegetable': '🥕',
    'carrot': '🥕', 'tomato': '🍅', 'bread': '🍞', 'cake': '🍰',
    'cookie': '🍪', 'pizza': '🍕', 'ice cream': '🍦', 'candy': '🍬',
    'milk': '🥛', 'juice': '🧃', 'egg': '🥚', 'cheese': '🧀',

    // ── Toys & play ──────────────────────────────────────────────────────
    'toy': '🧸', 'teddy bear': '🧸', 'doll': '🪆', 'ball': '⚽',
    'balloon': '🎈', 'kite': '🪁', 'puzzle': '🧩', 'robot': '🤖',
    'lego': '🧱', 'block': '🧱',

    // ── Books & learning ─────────────────────────────────────────────────
    'book': '📚', 'magazine': '📖', 'paper': '📄', 'pen': '🖊️',
    'pencil': '✏️', 'crayon': '🖍️', 'notebook': '📓', 'newspaper': '📰',

    // ── Clothes ──────────────────────────────────────────────────────────
    'clothing': '👕', 'shirt': '👕', 't-shirt': '👕', 'dress': '👗',
    'jeans': '👖', 'trousers': '👖', 'shoe': '👟', 'boot': '👢',
    'hat': '🧢', 'cap': '🧢', 'glove': '🧤', 'sock': '🧦',
    'scarf': '🧣', 'jacket': '🧥', 'bag': '👜', 'backpack': '🎒',
    'glasses': '👓', 'watch': '⌚',

    // ── Vehicles ─────────────────────────────────────────────────────────
    'vehicle': '🚗', 'car': '🚗', 'bus': '🚌', 'truck': '🚚',
    'bicycle': '🚲', 'bike': '🚲', 'motorcycle': '🏍️', 'train': '🚆',
    'airplane': '✈️', 'boat': '⛵', 'ship': '🚢', 'wheel': '🛞',
    'scooter': '🛴',

    // ── Home & objects ───────────────────────────────────────────────────
    'furniture': '🪑', 'chair': '🪑', 'table': '🪑', 'couch': '🛋️',
    'sofa': '🛋️', 'bed': '🛏️', 'pillow': '🛏️', 'cushion': '🛋️',
    'blanket': '🛌', 'lamp': '💡', 'light': '💡', 'clock': '🕐',
    'mirror': '🪞', 'window': '🪟', 'door': '🚪', 'curtain': '🪟',
    'vase': '🏺', 'bottle': '🍼', 'cup': '☕', 'mug': '☕',
    'plate': '🍽️', 'bowl': '🥣', 'spoon': '🥄', 'fork': '🍴',
    'key': '🔑', 'basket': '🧺', 'box': '📦', 'umbrella': '☂️',
    'candle': '🕯️', 'picture frame': '🖼️', 'painting': '🖼️',

    // ── Electronics ──────────────────────────────────────────────────────
    'phone': '📱', 'mobile phone': '📱', 'smartphone': '📱',
    'laptop': '💻', 'computer': '💻', 'keyboard': '⌨️', 'mouse': '🖱️',
    'television': '📺', 'monitor': '🖥️', 'camera': '📷',
    'headphones': '🎧', 'speaker': '🔊', 'tablet': '📱',

    // ── People ───────────────────────────────────────────────────────────
    'person': '🧑', 'face': '😊', 'smile': '😊', 'selfie': '🤳',
    'hand': '✋', 'hair': '💇', 'eye': '👁️', 'baby': '👶',

    // ── Music & art ──────────────────────────────────────────────────────
    'music': '🎵', 'guitar': '🎸', 'piano': '🎹', 'drum': '🥁',
    'art': '🎨', 'gift': '🎁', 'party': '🎉',
  };
}
