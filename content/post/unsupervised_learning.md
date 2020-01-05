+++
title = "Unsupervised learning"
date = 2019-03-29T11:26:20-04:00
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

I will be following the UC Berkeley's [CS294-158 Deep Unsupervised Learning course](https://sites.google.com/view/berkeley-cs294-158-sp19/home) and sharing my short summaries and takeaways.

The course covers Deep Generative Models and Self-supervised Learning with the focus on the theoretical foundations as well as their newly enabled applications. Stay tuned!

Topics:

* Autoregressive Models
* Lossless Compression
* Flow Models
* Latent Variable Models
* Bits-Back Coding
* Implicit Models

Introduction

What is Unsupervised Learning??? It is a type of machine learning algorithm that draws inferences from data which does not have labeled responses, so no direct classification or regression can be done.
* Generative Models
* Self-supervised Learning (labels are given in a clever way), like time, one patch above the other.

Intelligence is all about compression.

Applications:

* General novel data
* Compression
* Improve downstream tasks
* Flexible building blocks for reusing in other problems

VAEs, GANs, zebras, bigGAN (maybe latent space is useful), styleGAN, WaveNet, video generation, text generation, compression (WaveOne vs JPEG), sentiment detection. 


