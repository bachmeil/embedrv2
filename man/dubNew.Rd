\name{dubNew}
\alias{dubNew}
\title{Create Skeleton For a New Dub Project}
\description{
  Creates a dub.sdl file and a new source directory if it doesn't 
  already exist, and adds the required
  library to compile and run a D program that embeds R.
}
\usage{
  dubNew()
}
\examples{
  ## Run in your project directory
  \donttest{
    dubNew()
  }

  ## Run in terminal to compile and run
  \donttest{
    dub run
  }
}