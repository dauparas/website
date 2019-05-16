+++
title = "Autoregressive Models"
date = 2019-03-29T12:18:58-04:00
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

Motivation

Generate
Compress
Anomaly detection 

Likelihood-based models: estimate $p(x)$ given $x^{(1)}, x^{(2)},... etc.$ (i.i.d. assumption). This allows computing $p(x)$ for arbitrary $x$, sampling $x\sim p(x)$.

Discrete data!
Classical statistics vs this is the size of the space, e.g. for images 
128 x 128 x 3 = 50,000 dimensional space.

Trade offs:

Computational (fit on computer) and statistical efficiency
Expressiveness and generalization
Sampling quality and speed
Compression rate and speed

Estimating frequences by counting like histogram, suppose samples take on values in {1, 2, 3,... k}
$p_i$ = number of times i appears in the data/number of points in the data set.

Draw U[0, 1]
Return the smallest i s.t. u <= F.

Failures in high dimensions
MNIST: k = 2^784; but only 60k examples
Store a parameterised function $p_\theta (x)$

Designing the model and the training procedure go hand-in-hand. 

Fitting distributions:
arg min loss(\theta, x_1, x_2,..., x_n)
* works with large n
* yield \theta such that loss is small
* we want the model to generalize 

Maximum likelihood 
loss() = -1/n \sum log p_\theta (x_i) it is equivalent to minimizing KL between the empirical data distribution and the model (see your presentation on VAE)

SGD works well for averaging. 

Need to efficiently to compute $\log p(x)$ and its gradient.
Need sum p_i = 1 and p_i > 0; sum is large v.s. energy based models

Sum and product rules in statistics.

Autoregressive model log p(x) = sum log p(x_i vert x_{i-1})
A toy model:
p(x_1, x_2) = p(x_2 vert x_1) p(x_1); x_1, x_2 are scalars. 

For every new feature need a new NN. No way to share information between different conditionals. 
Sharing:
RNN
Masking

MADE paper citation: 
Autoencoder + Mask; need to pick ordering and mask to prevent direct information flow; no sharing of features; need a number of passes for sampling in this case; write the loss
implement this!!!

Nats vs bits measuring!

Masked temporal (1D) Convolutions
Just mask some conv entries; small receptive field; WaveNet paper is using dilated convolutions (dilation rate).
Understand slide 25!

Masked Spatial (2D) Conv - PixelCNN
* blind spot
Gated PixelCNN

PixelCNN++
Moving away from softmax - nearby pixels are likely to co-occur!
Mixture of logistics. 
U-net architecture - multiple resolutions at the same time.

Masked Attention
Self-attention

What is attention?
Each input pixel generates querry, key, and value

Zigzag ordering; does ordering matter?
Inductive bias is very important 

PixelSNAIL - SOTA
Attention + Conv 

Good:
Good expressivity and generalization

Bad:
Sampling is slow
(Fast pixel cnn)
Parallel Pixel CNN

Comparable to GANs.

