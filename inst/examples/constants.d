/* embedrv2 includes the constants provided by the R API
immutable double M_E=2.718281828459045235360287471353;
immutable double M_LOG2E=1.442695040888963407359924681002;
immutable double M_LOG10E=0.434294481903251827651128918917;
immutable double M_LN2=0.693147180559945309417232121458;
immutable double M_LN10=2.302585092994045684017991454684; 
immutable double M_PI=3.141592653589793238462643383280;
immutable double M_2PI=6.283185307179586476925286766559; 
immutable double M_PI_2=1.570796326794896619231321691640;
immutable double M_PI_4=0.785398163397448309615660845820;
immutable double M_1_PI=0.318309886183790671537767526745;
immutable double M_2_PI=0.636619772367581343075535053490;
immutable double M_2_SQRTPI=1.128379167095512573896158903122;
immutable double M_SQRT2=1.414213562373095048801688724210;
immutable double M_SQRT1_2=0.707106781186547524400844362105;
immutable double M_SQRT_3=1.732050807568877293527446341506;
immutable double M_SQRT_32=5.656854249492380195206754896838;
immutable double M_LOG10_2=0.301029995663981195213738894724;
immutable double M_SQRT_PI=1.772453850905516027298167483341;
immutable double M_1_SQRT_2PI=0.398942280401432677939946059934;
immutable double M_SQRT_2dPI=0.797884560802865355879892119869;
immutable double M_LN_SQRT_PI=0.572364942924700087071713675677;
immutable double M_LN_SQRT_2PI=0.918938533204672741780329736406;
immutable double M_LN_SQRT_PId2=0.225791352644727432363097614947; */

// Cannot call functions without arguments from R
// So I've added an unused argument
RList someconstants(double x) {
  auto result = RList(4);
  result["e"] = M_E;
  result["ln2"] = M_LN2;
  result["pi"] = M_PI;
  result["sqrt2"] = M_SQRT2;
  return result;
}
mixin(exportRFunction!someconstants);