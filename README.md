# LOCO-EFA-based leaf morphometry, automatic PCA graph creator and rudimentary model to predict species
Using lobe contribution elliptic fourier analysis to analyse leaf morphology, and (sort of) categorise by species
LOCO-EFA (Sanchez-Corrales et al. 2018) tries to explain an object's shape by using its outline. It addresses some of the downsides of regular EFA, you can read more about it in the original paper here https://pubmed.ncbi.nlm.nih.gov/29444894/; the original LOCO-EFA R library is here https://github.com/stanmaree/cellshape.

Image files MUST be thresholded PNGs in the following naming scheme "Genus species 00.png". If you need more than 2 digits to number your files, the scripts might still work but I haven't tested it. It should be pretty straightforward to modify it however.
I recommend using ImageMagick to batch-threshold your files. "mogrify -auto-threshold OTSU *.png" is the command I used; there are methods other than OTSU but this gave me the best results.

Since the petiole skews the results, I made a quick script that automatically reads in each image and removes the petiole, then outputs the modified images in a separate folder. Unfortunately, it will remove details from leaves with serrations or other sharp details due to how it works. Also, the value in the petiolereomver script will need to be adjusted (higher value = more detail loss, finding a balance is ideal) based on the resolution of your images. The thickest part of the petiole (usually the base) might still be retained, however as long as it's not attached to the rest of the leaf LOCO-EFA will ignore it, so these artifacts do not affect the results (as far as I can tell). Due to these limitations, I would only use the petioleremover if you're working with a lot of images, otherwise manual removal is best.

For testing purposes I've included a dataset that is pre-thresholded and de-petioled (both done manually).

To use this, download the repo and load the files into R studio. Make sure you have the latest R version installed. Install the required packages and change the path in the scripts to reflect where your dataset is. Hopefully, if you run it after that it should all just work.

![My Image]("images/petiole comparison graph.png")
