class GameData {
  static String gameName = '';
  static String title = '';
  static int score = 0;

  static void reset() {
    gameName = '';
    title = '';
    score = 0;
  }

  static String showName1 = '';
  static String showName2 = '';
  static String showName3 = '';
  static String showTitle1 = '';
  static String showTitle2 = '';
  static String showTitle3 = '';
  static int showScore1 = 0;
  static int showScore2 = 0;
  static int showScore3 = 0;

  static void updateTopScore() {
    int score = GameData.score;
    String name = GameData.gameName;
    String title = GameData.title;

    if (score > showScore1) {
      showScore3 = showScore2;
      showTitle3 = showTitle2;
      showName3 = showName2;

      showScore2 = showScore1;
      showTitle2 = showTitle1;
      showName2 = showName1;

      showScore1 = score;
      showTitle1 = title;
      showName1 = name;
    } else if (score > showScore2 && score <= showScore1) {
      showScore3 = showScore2;
      showTitle3 = showTitle2;
      showName3 = showName2;

      showScore2 = score;
      showTitle2 = title;
      showName2 = name;
    } else if (score > showScore3 && score <= showScore2) {
      showScore3 = score;
      showTitle3 = title;
      showName3 = name;
    }
  }
}
