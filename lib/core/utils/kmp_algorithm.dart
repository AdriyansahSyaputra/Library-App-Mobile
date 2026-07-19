class KMPAlgorithm {
  // Fungsi 1: Membuat tabel LPS (Longest Proper Prefix which is also Suffix)
  static List<int> _computeLPS(String pattern) {
    int m = pattern.length;
    List<int> lps = List.filled(m, 0);
    int len = 0;
    int i = 1;

    while (i < m) {
      if (pattern[i] == pattern[len]) {
        len++;
        lps[i] = len;
        i++;
      } else {
        if (len != 0) {
          len = lps[len - 1];
        } else {
          lps[i] = 0;
          i++;
        }
      }
    }
    return lps;
  }

  // Fungsi 2: Pencocokan String KMP
  static bool search(String text, String pattern) {
    if (pattern.isEmpty) return true; // Jika pencarian kosong, tampilkan semua

    // Normalisasi ke huruf kecil agar pencarian tidak case-sensitive
    text = text.toLowerCase();
    pattern = pattern.toLowerCase();

    int n = text.length;
    int m = pattern.length;
    List<int> lps = _computeLPS(pattern);

    int i = 0; // index untuk text
    int j = 0; // index untuk pattern

    while (i < n) {
      if (pattern[j] == text[i]) {
        j++;
        i++;
      }

      if (j == m) {
        return true; // Pola ditemukan
      } else if (i < n && pattern[j] != text[i]) {
        if (j != 0) {
          j = lps[j - 1];
        } else {
          i++;
        }
      }
    }
    return false; // Pola tidak ditemukan
  }
}
