class Rota {
  DateTime displayMonth = DateTime(2022, 1, 1);

  Rota clone() {
    return Rota()..displayMonth = this.displayMonth;
  }
}
