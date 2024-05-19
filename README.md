# Docker

I have made a custom Dockerfile to run the Framepool codebase. Some design decisions explained:
- Ubuntu's `apt-get` does not install pipx or poetry correctly, so I used a pip workaround to install both.
- The Docker has a Jupyter notebook entrypoint by default. You can run the Docker's Jupyer notebook like so:
```
docker run -it --rm -v .:/app/mnt:ro -p 8080:8080 framepool
```
- If you want a different entrypoint (ie bash) you can run:
```
docker run -it --entrypoint /bin/bash --rm -v .:/app/mnt:ro framepool
```

I have made a custom script for annotation VCF files with FramePool. It takes a tab-delimited file as input, with columns ???.

You can run this script using: `poetry run python modules/framepool_annotate.py`

# 5UTR

In the paper "Human 5′ UTR design and variant effect prediction from a massively parallel translation assay" (Sample et al), MPRA data is used to train a powerful deep model to predict ribsome load (a measure of translation efficiency) from the seuqnece of the 5 untranslated region. This model can be used to predict the effect of variants (mutations) on the ribosome load (and thus translation efficiency), which could be used to investigate the causes of rare genetic dieseases.

However, the published model, due to its use of a dense layer in the architecture, is inherently limited to specific sequence lengths. We remove this restriction and allow the model to produce predictions for arbitrary length sequences. To achieve this, we replace the dense layer with global max and average pooling operations on the output of the convolutional layers to provide an aggregated record of which sequence motifs were detected. In order to differentiate in which frame a motif is found (which plays a role for some motifs, such as upstream AUG), we perform these pooling operations on each frame seperately. Only then is the pooled motif data fed into a dense layer.

We show that such a model can provide similar performance as the published fixed-length on the same test set, while generalizing better to other contexts, such as longer MPRA sequences and endogenous data. We also show that the model has learnt to detect functionally relevant nucleotides and can correctly quantify the relative strength of uTIS motifs.

To replicate the main results, clone the repository. Next download the data from https://doi.org/10.5281/zenodo.3584237. Place the data_dict.pkl in the Data directory. Then you can run the Model_Training.ipynb notebook to train a Framepool model. If you would like to generate the paper plots, without running predictions, place the contents of the Predictions.tar.gz file in Data/Predictions and then run the Validations.ipynb notebook. 

In case you want to use the model to predict on your own, you can use the kipoi API. The kipoi_example.ipynb notebook in the Kipoi directory provides an example for how this can be done.

