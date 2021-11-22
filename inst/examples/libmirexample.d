import mir.random;
import mir.random.variable;

RVector rngexample(int n) {
	auto gen = Random(unpredictableSeed);
	auto rv = uniformVar(-10, 10); // [-10, 10]
	auto result = RVector(n);
	foreach(ii; 0..n) {
		result[ii] = rv(gen);
	}
	return result;
}
mixin(createRFunction!rngexample);
