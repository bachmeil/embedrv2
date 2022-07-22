dubNewShared <- function(packageName="") {
  validPackageName <- all(grepl("[[:lower:]\\-_]", strsplit(packageName, "*")[[1]]))
  if (!validPackageName) { stop(paste0("Package name ", packageName, " is not valid. Can only be lower case characters, -, or _.")) }
	dcode <- paste0(find.package("embedrv2")[1], "/embedr/r.d")
	libr <- system("locate -b '\\libR.so' -l 1", intern=TRUE)
	dir.create("src")
	file.copy(dcode, "src/", overwrite=FALSE)
	
	dub.sdl <- paste0('name "', packageName, '"
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

# Will be changed to work generically for add-on packages
# R package should provide all necessary metadata
#~ dubOptim <- function() {
#~ 	if (dir.exists("src")) {
#~ 		if (!file.exists("src/optim.d")) {
#~ 			file.copy(paste0(find.package("embedr")[1], "/embedr/optim.d"), "src/", overwrite=FALSE)
#~ 		} else {
#~ 			print("src/optim.d already exists. Delete it if you want it overwritten.")
#~ 		}
#~ 	} else {
#~ 		print("Subdirectory src/ does not exist. Nowhere to put optim.d. Exiting...")
#~ 	}
#~ }	
