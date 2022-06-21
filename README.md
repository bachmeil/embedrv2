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

**Please note that as of June 2022, I have not done any work related to D programs that embed an R interpreter.** You should continue to use the original embedr for that. That is next on my list. Installation is greatly simplified due to the inclusion of RInsideC functionality in RInside. The final piece I have not figured out is the best way to hold data persistently inside R without lots of boilerplate or clumsy syntax. Most likely this will take the form of creating structs on the D side that pass the data to R on construction, hold information about accessing the R data, and delete the R data on destruction. I think that's going to require reference counting, but would be happy to learn otherwise.

Things are different on the Windows side, too. I spent countless hours playing with DLLs and import libraries and Visual Studio and all that jazz. WSL is stable and available on almost all Windows computers used for data analysis. VS Code has strong support for D, R, and WSL. The lack of a Windows maintainer is not a big deal for embedrv2. I didn't have that option when I started this project.

Finally, I've moved all development from Bitbucket to Github. There was a time that Bitbucket was the cloud version control system of choice. That ceased to be the case several years ago. The move to Github means you can use Github discussions to ask basic questions.

Overall, the experience should be much cleaner, from installation to usage.

# Example

Open R. Install embedrv2:

```
library(devtools)
install_github("bachmeil/embedrv2")
```

Then create a new Dub project:

```
library(embedrv2)
dubNewShared()
```

This creates a dub.sdl file inside the current working directory that holds all the information needed to do the build. Open dub.sdl and make any changes you want. These could include adding dependencies on packages on code.dlang.org. At a minimum you'll need to add a package name that follows the dub rules. Change the first line to say `name "irf"`.

Save this code in a file in the root of the project (not the src subdirectory, but the same directory that holds dub.sdl) named irf.d:

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

Return to R and run the following:

```
compileShared("irf")
dyn.load("libirf.so")
.Call("ar1irf", 0.6, 1.0, 12)
```

That should give you this output:

```
 [1] 1.000000000 0.600000000 0.360000000 0.216000000 0.129600000 0.077760000
 [7] 0.046656000 0.027993600 0.016796160 0.010077696 0.006046618 0.003627971
```

Some explanation: `@extern_R ar1irf` declares `ar1irf` as a function with R "linkage". It creates a C function of the same name that takes and returns arguments R can understand. That function calls your D function and returns a converted version of the output to R.

`mixin(exportRFunctions)` tells D to create R versions of all the functions in the current file preceded by `extern_R`. That allows us to include helper functions like `last` that are not exported to R.

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

# Interoperable types

You can use the following data types as arguments to functions that will be called from R:

- double
- int
- long
- ulong
- string
- string[]
- double[]
- NamedList (An R list with named elements)
- RMatrix (An R matrix of doubles)
- RVector (An R vector of doubles)
- RIntVector (An R vector of ints)

You can use the usual indexing operations with vectors and matrices.

I use the Gretl library for matrix and vector operations. That is irrelevant for the purposes of embedrv2; the goal is to facilitate interoperability, not to provide a bunch of D functionality that is not specific to programs that will run inside R.

The NamedList is used to *receive* a list from R. It is immediately converted to a D struct. It is *not intended to be passed back to R*. If you want to create a list to pass back to R, use an RList instead.

# Examples

- libhello.d: Basic usage
- libmirexample.d: Example calling Mir to demonstrate adding code.dlang.org dependencies
- listex.d: Using lists

# Limitations

The goal of embedrv2 is to facilitate interoperability between D and R. That means support for passing data between the two languages and then accessing/modifying the data. No attempt is made to provide matrix algebra, random number generation, etc. That should be handled by other packages.
