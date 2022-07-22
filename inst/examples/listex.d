/* Note: Always treat R lists as read-only (if they are passed as an
 * argument to the function, or as write-only (if they are used to pass
 * objects back to R). Do not attempt to pass a list you've received
 * from R inside the D code. It's too easy to end up with segfaults due
 * to the difficulty of handling protection. This is not a meaningful
 * constraint in most cases. You're probably doing it wrong if you want
 * to do otherwise. */
@extern_R RList listchange(RList x) {
  auto result = RList(2);
  result["a"] = x["b"];
  result["b"] = x["a"];
  return result;
}
mixin(exportRFunctions);
