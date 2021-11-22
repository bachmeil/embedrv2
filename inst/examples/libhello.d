double add(double x, double y) {
	double result = x + y;
	return result;
}
mixin(createRFunction!add);

RVector twice(RVector x) {
	auto result = RVector(x.length);
	foreach(ii; 0..x.length) {
		result[ii] = 2.0*x[ii];
	}
	return result;
}
mixin(createRFunction!twice);
