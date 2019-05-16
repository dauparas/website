+++
title = "Nonlinear ICA"
date = 2019-03-29T16:19:43-04:00
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

I have recently got interested in representation learning, especially in disentangled representations of the data. The idea is to find a representation of the high dimensional data like images where the features in the representation space would be "disentangled". It is hard to define what is "the disentangled representation", but anyway.

I came across this recent paper called ["Nonlinear ICA Using Auxiliary Variables and Generalized Contrastive Learning"](https://arxiv.org/pdf/1805.08651.pdf) and was very curious to try it out.

Let me try to summarize the basic idea from the paper.

Authors propose a general framework for nonlinear ICA. It is based on augmenting the data by an auxiliary variable, such as the time index, the history of the time series, labels, or any other available information and learning to discriminate between true augmented data, or data
in which the auxiliary variable has been randomized.

