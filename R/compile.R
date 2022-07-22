dubNewShared <- function() {
	dcode <- paste0(find.package("embedrv2")[1], "/embedr/r.d")
	libr <- system("locate -b '\\libR.so' -l 1", intern=TRUE)
	dir.create("src")
	file.copy(dcode, "src/", overwrite=FALSE)
	
	dub.sdl <- paste0('name ""
description ""
authors ""
copyright "Copyright ', format(Sys.Date(), "%Y"), '"
license ""
versions "inline"
targetType "dynamicLibrary"
lflags "', libr, '"')
	
	if (!file.exists("dub.sdl")) {
		cat(dub.sdl, file="dub.sdl")
	} else {
		print("dub.sdl already exists. Delete it or rename it if you want it overwritten.")
	}
}

# This is the default for compiling shared libraries
# Boilerplate should be handled by createRLibrary on the D side
compileShared <- function(filename, rebuild=FALSE, initCode="", exitCode="") {
	
	libname <- tools::file_path_sans_ext(filename)
	if (!startsWith(libname, "lib")) {
		libname <- paste0("lib", libname)
	}
	
	if (!endsWith(filename, ".d")) {
		filename <- paste0(filename, ".d")
	}
	
	code <- paste0(
'module ', libname, ';
import embedr.r;
mixin(addRBoilerplate!"', tools::file_path_sans_ext(filename), '"(`', initCode, '`, `', exitCode, '`));
',
paste(readLines(filename), collapse="\n"))

	cat(code, file="src/__tmp__compile__file.d", sep="")
	cmd.dub <- if (rebuild) {
		"dub run --force"
	} else {
		"dub run"
	}
	out.dub <- system(cmd.dub, intern=TRUE)
	print(out.dub)
	dyn.load(paste0(libname, ".so"))
}

# This is about the best you can do for reloading a package in R
reload.embedrv2 <- function() {
	detach("package:embedrv2", unload = TRUE)
  library(embedrv2)
}

# These functions are all for Linux systems
# DMD works for Linux, as does LDC, but LDC support has not yet been added
# I think it should be trivial, but I need time to test it
computeLibs <- function(libs) {
	dependencies <- NULL
	for (lib in libs) {
		dependencies <- c(dependencies, getExportedValue(lib, "deps")())
	}
	return(unique(c(libs, dependencies)))
}

dmd <- function(name, dlibs="", other="", run=TRUE) {
	module <- paste0(find.package("embedr")[1], "/embedr/r.d")
	rinside <- paste0(find.package("RInsideC")[1], "/lib/libRInside.so")
	libr <- system("locate -b '\\libR.so' -l 1", intern=TRUE)

	# Construct the compilation line
	cmd <- paste0("dmd ", name, ".d -version=r -version=standalone ", module, " -L", libr, " ", rinside)
	
	# Add compilation information about any additional packages
	if (!isTRUE(dlibs == "")) {
		# Have to load dependencies of dependencies
		# Pull all dlibs until the vector stops changing
		v <- computeLibs(dlibs)
		difference <- 1
		while (difference > 0) {
			v.start <- v
			v <- computeLibs(v.start)
			difference <- length(v) - length(v.start)
		}
		allLibs <- v
		
		for (dlib in allLibs) {
			m <- getExportedValue(dlib, "modules")()
			mdir <- getExportedValue(dlib, "moddir")()
			mod <- paste0(find.package(dlib)[1], "/", mdir, "/", m, ".d", sep="", collapse=" ")
			flags <- getExportedValue(dlib, "flags")()
			fullAddition <- paste0(" ", mod, " ", flags)
			cmd <- paste0(cmd, fullAddition)
		}
	}
	
	# Add any additional flags passed by the caller and compile
	cmd <- paste0(cmd, " ", other)
	print(cmd)
	out <- system(cmd, intern=TRUE)
	print(out)

	# Run the executable
  if (run) {
    cmd <- paste0("./", name);
    print(cmd)
    cat("\n\n")
    system(cmd)
  }
}

dubNew <- function() {
	dcode <- paste0(find.package("embedr")[1], "/embedr/r.d")
	rinside <- paste0(find.package("RInsideC")[1], "/lib/libRInside.so")
	libr <- system("locate -b '\\libR.so' -l 1", intern=TRUE)
	dir.create("src")
	file.copy(paste0(find.package("embedr")[1], "/embedr/r.d"), "src/", overwrite=FALSE)
	
	dub.sdl <- paste0('name ""
description ""
authors ""
copyright "Copyright ', format(Sys.Date(), "%Y"), ', "
license ""
versions "standalone"
targetType "executable"
lflags "', libr, '" "', rinside, '"')
	
	if (!file.exists("dub.sdl")) {
		cat(dub.sdl, file="dub.sdl")
	} else {
		print("dub.sdl already exists. Delete it if you want it overwritten.")
	}
}

# Will be changed to work generically for add-on packages
# R package should provide all necessary metadata
dubOptim <- function() {
	if (dir.exists("src")) {
		if (!file.exists("src/optim.d")) {
			file.copy(paste0(find.package("embedr")[1], "/embedr/optim.d"), "src/", overwrite=FALSE)
		} else {
			print("src/optim.d already exists. Delete it if you want it overwritten.")
		}
	} else {
		print("Subdirectory src/ does not exist. Nowhere to put optim.d. Exiting...")
	}
}	

# This allows you to avoid Dub
# I don't plan to remove it, but rather emphasize Dub usage
# I plan to change this function
manualCompilation <- function(code, libname, deps="", other="", rebuild=FALSE, random=FALSE) {
	if (file.exists(paste0("lib", libname, ".so")) & !rebuild) {
	  dyn.load(paste0("lib", libname, ".so"))
		return("Dynamic library already exists - pass argument rebuild=TRUE if you want to rebuild it.")
	}
#~ 	cat(boilerplate(libname, random=random), code, file="__tmp__compile__file.d", sep="")
	cat(code, file="__tmp__compile__file.d", sep="")
	# Save code to file with temporary name
	apiModule <- paste0(find.package("embedr")[1], "/embedr/r.d")
	
	# compile fPIC and so
	cmd.fpic <- paste0("dmd -mixin=mixinfile.d -c __tmp__compile__file.d -fPIC -version=inline ", apiModule)
	cmd.so <- paste0("dmd -oflib", libname, ".so __tmp__compile__file.o r.o ", " -shared -defaultlib=libphobos2.so");

	print(cmd.fpic)
	out.fpic <- system(cmd.fpic, intern=TRUE)
	print(out.fpic)
	
	print(cmd.so)
	out.so <- system(cmd.so, intern=TRUE)
	print(out.so)
	
	# Load the .so
	dyn.load(paste0("lib", libname, ".so"))
}

# Also used to avoid Dub
# Will not emphasize use of this function in v2
# I plan to change this, so don't use it now
compileSharedLibrary <- function(filename, deps="", other="", rebuild=FALSE, random=FALSE) {
	libname <- tools::file_path_sans_ext(filename)
	if (!startsWith(libname, "lib")) {
		libname <- paste0("lib", libname)
	}
	if (!endsWith(filename, ".d")) {
		filename <- paste0(filename, ".d")
	}
	manualCompilation(paste0('module ', libname, ';\nimport embedr.r;\nmixin(createRLibrary!"', tools::file_path_sans_ext(filename), '");\n', paste(readLines(filename), collapse="\n")), libname, deps, other, rebuild=TRUE)
}

# I'll probably move to something like this for manual compilation
so.create <- function(s, options=list()) {
	filename <- "__tmp__compile__file"
	dfilename <- paste0(filename, ".d")
	ofilename <- paste0(filename, ".o")
	compiler <- "dmd"
	srcfiles <- ""
	objfiles <- ""
	deps <- character(0)
	load <- ""
	unload <- ""
	code <- s
	
	if (is.null(options$libname)) {
		libname <- if (startsWith(s, "lib")) {
			substring(s, 4)
		} else {
			s
		}
		if (endsWith(libname, ".d")) {
			n <- nchar(libname)
			libname <- substring(libname, 1, n-2)
		}
	} else {
		libname <- options$libname
	}
	
	if (is.null(options$rebuild)) {
		if (file.exists(paste0("lib", libname, ".so"))) {
			return(NULL)
		}
	} else {
		if (!options$rebuild) {
			if (file.exists(paste0("lib", libname, ".so"))) {
				return(NULL)
			}
		}
	}

	if (!is.null(options$load)) {
		load <- options$load
	}
	
	if (!is.null(options$unload)) {
		unload <- options$unload
	}
	
	if (is.null(options$string)) {
		code <- paste(readLines(s), collapse="\n")
	}
	if (!is.null(options$string)) {
		if (!options$string) {
			code <- paste(readLines(s), collapse="\n")
		}
	}
	
	# Have to write everything to disk no matter what
	# Need to add boilerplate before compiling
	cat(boilerplate(libname, load, unload), code, file=dfilename, sep="")
	
	if (!is.null(options$compiler)) {
		compiler <- options$compiler
	}

	if (!is.null(options$src)) {
		srcfiles <- paste(options$src, collapse=" ")
		for (f in options$src) {
			cat("f: ", f, "\n")
			objfiles <- paste(objfiles, paste0(substring(f, 1, nchar(f)-2), ".o"))
		}
		cat("objfiles: ", objfiles, "\n")
	}

	if (!is.null(options$deps)) {
		deps <- options$deps
	}
	
	cmd.fpic <- function() {
		inc <- paste0(find.package("embedr")[1], "/embedr/r.d")
		for (dep in deps) {
			inc <- paste(inc, get("fpicIncludes", envir=asNamespace(dep))())
		}
		return(paste0(compiler, " -c ", dfilename, " -fPIC -version=inline ", srcfiles, " ", inc))
	}
	
	cmd.so <- function() {
		obj <- paste(ofilename, "r.o", objfiles)
		for (dep in deps) {
			obj <- paste(obj, get("soFlags", envir=asNamespace(dep))())
		}
		return(paste0(compiler, " -oflib", libname, ".so ", obj, " -shared -defaultlib=libphobos2.so"))
	}
	
	cmd <- cmd.fpic()
	print(cmd)
	out.fpic <- system(cmd, intern=TRUE)
	print(out.fpic)
	
	cmd <- cmd.so()
	print(cmd)
	out.so <- system(cmd, intern=TRUE)
	print(out.so)
	
	# Load the .so
	dyn.load(paste0("lib", libname, ".so"))
}
