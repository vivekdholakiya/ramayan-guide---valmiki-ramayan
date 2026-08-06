String formatDescription(String text) {
  return text
      .replaceAll(r'/n/n', '\n\n')
      .replaceAll(r'/n', '\n')
      .replaceAll(r'\n\n', '\n\n')
      .trim();
}



String appUrl =
    'https://play.google.com/store/apps/details?id=com.vivek.valmiki.ramayan';