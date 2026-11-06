class Task {
  static const abandonedStatus = 3;

  String title;
  int status; // 0:未着手 1:作業中 2:完了 3:諦めた
  Task(this.title, [this.status = 0]);
}
