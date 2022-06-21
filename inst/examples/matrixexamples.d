RMatrix twice(RMatrix m) {
  RMatrix result = m.sameSize;
  foreach(row; 0..m.rows) {
    foreach(col; 0..m.cols) {
      result[row, col] = 2.0*m[row, col];
    }
  }
  return result;
}
mixin(exportRFunction!twice);

RMatrix addtwo(RMatrix m) {
  RMatrix result = m.sameSize;
  result = m + 2.0;
  return result;
}
mixin(exportRFunction!addtwo);
