# embedrv2

Updated version of https://bitbucket.org/bachmeil/embedr

# Plans

- [x] Use D's metaprogramming capabilities to handle the boilerplate for calling D functions from R
- [x] Make Dub the default for creating shared libraries to be called from R, so that arbitrary Dub packages can be included
- [ ] Make a video showing how easy it is to call libraries of D functions from R
- [ ] Update to reflect the fact that RInsideD was merged into RInside (simplifying installation)
- [ ] Make a video showing how easy it is to write D programs that embed R
- [ ] Document the inclusion of D libraries in R packages posted on Github/Bitbucket
- [ ] Write official R package documentation for the embedrv2 package so it can be accessed from within R
- [ ] Add support for non-Dub D code included in R packages (like my work wrapping Gretl)
- [ ] Get a package for embedrv2 on CRAN so it can be installed the official/simple way

The tough work is done. It's just a matter of finding a few hours to smooth out the details on each of these.