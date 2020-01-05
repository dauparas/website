+++
title = "Vector Quantized Variational AutoEncoder (VQ-VAE)"
date = 2019-06-19T17:03:28-04:00
draft = false

# Tags and categories
# For example, use `tags = []` for no tags, or the form `tags = ["A Tag", "Another Tag"]` for one or more tags.
tags = []
categories = []

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder. 
[image]
  # Caption (optional)
  caption = ""

  # Focal point (optional)
  # Options: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight
  focal_point = ""
+++
This post is based on the VQ-VAE papers.

**Framework**

The VQ-VAE model has an encoder that maps the input space $\mathbf{X}\in \mathbb{R}^{N\times M}$ with $N$ samples each having $M$ features to a encoding (latent) space $\mathbf{Z}=E(\mathbf{X})\in \mathbb{R}^{N\times D}$ where $D$ is the size of the latent space. The latent space is then quantized based on its distance to the prototype vectors in the codebook $e_{k}\in \mathbb{R}^{D},\; k \in 1 \ldots K$. This means that 

\begin{align}
f\_{E}&: \mathbf{X}\in\mathbb{R}^{N\times M} \mapsto \mathbf{E}=f\_E(\mathbf{X})\in\mathbb{R}^{N\times D},\\\\\\
f\_{Q}&: \mathbf{E}\in \mathbb{R}^{N\times D} \mapsto \mathbf{Q}=f\_{Q}(\mathbf{E})\in\mathbb{R}^{K\times D}, \\\\\\
f\_{D}&: \mathbf{Q}\in\mathbb{R}^{K\times D} \mapsto \mathbf{D}=f\_{D}(\mathbf{Q})\in\mathbb{R}^{K\times M}.
\end{align}
