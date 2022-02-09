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

# What does this mean for embedr?

Nothing. I don't believe in destroying old projects just because a new version was released. embedr will be available forever. There won't be any new functionality, and I won't put much time into maintenance, but there's really no reason it should need much maintenance. It's a small amount of code built on top of two old, stable languages.

# What are the major changes?

Since this is a new project, I'm willing to rip anything out and start over. 

The original version of embedr was released in 2013 or 2014. At that time, Dub had bad documentation and it was honestly difficult to get it to work with embedr. I spent many hours on it but went down in flames. Things are different in 2022. Dub now works well for this type of thing, so everything will be centered around a Dub workflow. That was always the goal, and now it's here. The biggest advantage of Dub is that it opens the door to all the existing packages like Mir.

A second big change is that I had time to figure out D's compile time metaprogramming. The end result is that you no longer have to write wrappers for your D functions. For instance, you don't have to convert between the R and D data types. You create a file with D functions. You call `exportRFunction`, `exportRFunctions`, or `exportRModule` as a mixin and D handles the data passing for you. There's now a `@export_R` UDA that functions as `export (R)` would if it existed.

For D programs embedding R, the installation is much simplified, due to the inclusion of the RInsideC functionality in RInside.

Things are different on the Windows side too. WSL is now stable and available on the computers of almost all potential Windows users. VS Code has strong support for D, R, and WSL. That's good, because it means the lack of a Windows maintainer is no longer a big deal - just run your program in WSL if you're using Windows. That wasn't possible in 2014. VS Code wasn't released until 2015. WSL wasn't released until 2016. I stopped new development on embedr in early 2018 due to a change in my job, so Windows is a very different beast today than when I was actively working on embedr.

I also moved everything from Bitbucket (which these days is not the most pleasant experience) to Github. You can use Github discussions to ask basic questions.

Overall, the experience should feel much cleaner, from installation to usage.

# Example

Open R. Install embedrv2:

```
library(devtools)
install_github("bachmeil/embedrv2")
```

Create a new Dub project inside R:

```
library(embedrv2)
dubNewShared()
```

This handles all the dependencies trivially, since we're working inside R. It creates a new project and a blank dub.sdl.

```
@extern_R ar1irf(double alpha, double shock, int h) {
	double[] result;
	result ~= shock;
	foreach(ii; 1..h) {
		result ~= alpha * result.last;
	}
	return result;
}
mixin(exportRFunctions);

double last(double[] v) {
	if (v.length > 0) {
		return v[$-1];
	} else {
		return 0.0;
	}
}
```

From inside R:

```
compileShared("irf")
dyn.load("libirf.so")
.Call("ar1irf", 0.6, 1.0, 12)
```

Some explanation: `@extern_R ar1irf` declares `ar1irf` as a function with R "linkage". It creates a C function of the same name that takes and returns arguments R can understand. That function calls your D function and returns a converted version of the output to R.

`mixin(exportRFunctions)` tells D to create R versions of all the functions in the current file preceded by `extern_R`. That allows us to include helper functions like `last` that are not exported.

You can export multiple functions to R by putting them inside a block, like this:

```
@extern_R {
function 1
function 2
function 3
...
}
```

Alternatively, you can use `mixin(exportRModule)` to export all functions in the current file. This is equivalent to putting all of the functions inside a `@extern_R` block and calling `mixin(exportRFunctions)`. `mixin(exportRModule)` is normally not what you'd want to do because you can't include any helper functions.
