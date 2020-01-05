+++
title = "Pseudolikelihood"
subtitle = ""

# Add a summary to display on homepage (optional).
summary = ""

date = 2019-06-07T06:44:46-04:00
draft = false

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors = []

# Tags and categories
# For example, use `tags = []` for no tags, or the form `tags = ["A Tag", "Another Tag"]` for one or more tags.
tags = []
categories = []

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["deep-learning"]` references 
#   `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
# projects = ["internal-project"]

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder. 
[image]
  # Caption (optional)
  caption = ""

  # Focal point (optional)
  # Options: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight
  focal_point = ""
+++

<a href="https://colab.research.google.com/github/sokrypton/seqmodels/blob/master/seqmodels.ipynb" target="_parent"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/></a>

**Bayesian inference**

**Modelling sequences**

We would like to model a distribution of some sequences of lenght $L$ where every element in the sequence can take $K$ different values. Write the parametric probability distribution for the sequence as a joint probability of elements in the sequence, i.e.
\begin{align}
p(\mathbf{x};\boldsymbol{\theta})=p(x\_1, x\_2,..., x\_L;\boldsymbol{\theta}),
\end{align}
where $\boldsymbol{\theta}$ are parameters of the distribution. Now suppose that we got $N$ examples drawn from this distribution. Denote the data as $\mathbf{X}\in \mathbb{R}^{N\times L\times K}$. The goal is to find $\boldsymbol{\theta}$ that explains the data.

\begin{align}
p(\boldsymbol{\theta}\vert \mathbf{X}) = \frac{p(\mathbf{X}\vert \boldsymbol{\theta})p(\boldsymbol{\theta})}{\sum\_{\boldsymbol{\theta}}p(\mathbf{X}\vert \boldsymbol{\theta})p(\boldsymbol{\theta})}.
\end{align}

**Partition function**

Suppose we come up with a probabilistic model which has an unnormalized probability distribution $\tilde{p}(\mathbf{x} ; \boldsymbol{\theta})$. To obtain a normalized probability distribution $p(\mathbf{x} ; \boldsymbol{\theta})$ we divide by the sum of all possible values that $\mathbf{x}$ can take, i.e.
$$p(\mathbf{x} ; \boldsymbol{\theta})=\frac{\tilde{p}(\mathbf{x} ; \boldsymbol{\theta})}{\sum_{\mathbf{x}}\tilde{p}(\mathbf{x} ; \boldsymbol{\theta})}=\frac{\tilde{p}(\mathbf{x} ; \boldsymbol{\theta})}{Z(\boldsymbol{\theta})}.$$
The letter Z stands for the German word *Zustandssumme*, "sum over states". It is called the **partition function** because it encodes how the probabilities are partitioned among the different states, based on their individual unnormalized probabilities. The problem is that the partition function often cannot be calculated exactly due to the large number of elements in the sum. For sequences we would have $K^L$ elements. The gradient of the log-likelihood with respect to the parameters has a term corresponding to the gradient of the partition function:
$$\nabla\_{\boldsymbol{\theta}}\log{p(\mathbf{x} ; \boldsymbol{\theta})}= \nabla\_{\boldsymbol{\theta}}\log{\tilde{p}(\mathbf{x} ; \boldsymbol{\theta})-\nabla\_{\boldsymbol{\theta}}\log{Z(\boldsymbol{\theta})}}$$ 
and this makes learning the model often intractable. For models that have non-zero probability for every state, i.e. $\tilde{p}(\mathbf{x} ; \boldsymbol{\theta})>0$ for all $\mathbf{x}$, we can write $\tilde{p}(\mathbf{x} ; \boldsymbol{\theta})=\exp (\log \tilde{p}(\mathbf{x}))$ and then 
$$\begin{align} 
\label{eq:1}
\nabla\_{\boldsymbol{\theta}} \log Z(\boldsymbol{\theta})&=\frac{\sum\_{\mathbf{x}} \nabla\_{\boldsymbol{\theta}} \tilde{p}(\mathbf{x}; \boldsymbol{\theta})}{Z(\boldsymbol{\theta})}=\frac{\sum\_{\mathbf{x}} \nabla\_{\boldsymbol{\theta}} \exp (\log \tilde{p}(\mathbf{x}))}{Z}=\sum\_{\mathbf{x}} p(\mathbf{x}) \nabla\_{\boldsymbol{\theta}} \log \tilde{p}(\mathbf{x}), \\\\\\
\color{green}{\nabla\_{\boldsymbol{\theta}} \log Z(\boldsymbol{\theta})}\&\color{green}{=}\color{green}{\mathbb{E}\_{\mathbf{x} \sim p(\mathbf{x})} \nabla\_{\boldsymbol{\theta}} \log \tilde{p}(\mathbf{x})}.
\end{align}$$
The last identity is the basis (hence in green) for a variety of Monte Carlo methods for approximately maximizing the likelihood of models with intractable partition functions. Read more about partition function here: https://www.deeplearningbook.org/contents/partition.html .

**Pseudolikelihood**

Notice that it is easy to compute ratios of probabilities in unnormalized probabilistic models. This is because the partition function appears in both the numerator and the denominator of the ratio and cancels out:
\begin{align}
\frac{p(\mathbf{x};\boldsymbol{\theta})}{p(\mathbf{y};\boldsymbol{\theta})}=\frac{\frac{1}{Z} \tilde{p}(\mathbf{x};\boldsymbol{\theta})}{\frac{1}{Z} \tilde{p}(\mathbf{y};\boldsymbol{\theta})}=\frac{\tilde{p}(\mathbf{x};\boldsymbol{\theta})}{\tilde{p}(\mathbf{y};\boldsymbol{\theta})}.
\end{align}

Moreover, using the chain rule of probability we can write the log-likelihood:
\begin{align}
\log p(\mathbf{x};\boldsymbol{\theta})=\log p\left(x\_{1};\boldsymbol{\theta}\right)+\log p\left(x\_{2} | x\_{1};\boldsymbol{\theta}\right)+\cdots+p\left(x\_{L} | \mathbf{x}\_{1 : L-1};\boldsymbol{\theta}\right).
\end{align}
The **pseudolikelihood** ([Besag, 1975](https://pdfs.semanticscholar.org/1406/b6d771c270aff4dcb1c96e4f5c62c02c00a5.pdf)) objective function is given by:
\begin{align}
\mathcal{L}\_{pl}(\mathbf{x};\boldsymbol{\theta})=\sum\_{\ell=1}^{L} \log p\left(x\_{\ell} | \boldsymbol{x}\_{-\ell};\boldsymbol{\theta}\right)
\end{align}
If each random variable has $K$ diﬀerent values, this requires only $K\times L$ evaluations of $\tilde{p}$ to compute, as opposed to the $K^L$ evaluations needed to compute the partition function.

**Markov Random Field with pseudolikelihood**

For the Markov Random Field we assume that given parameters $\color{green}{\mathbf{b}}\in \mathbb{R}^{L\times K}$ and $\color{red}{\mathbf{W}}\in \mathbb{R}^{L\times K\times L\times K}$ the positions are independent
\begin{align}
\tilde{p}(\mathbf{x}\vert\boldsymbol{\theta}) &= \tilde{p}(\mathbf{x}\vert\color{green}{\mathbf{b}}, \color{red}{\mathbf{W}})=\prod\_{\ell=1}^{L}\tilde{p}(x\_{\ell}\vert\color{green}{\mathbf{b}}, \color{red}{\mathbf{W}}),\\\\\\
\tilde{p}(x\_{\ell}\vert\color{green}{\mathbf{b}}, \color{red}{\mathbf{W}})&=\exp{\left(\sum_{k=1}^{K}\color{green}{b\_{\ell k}}x\_{\ell k}+\sum\_{k=1}^{K}\sum\_{s=\ell+1}^{L}\sum\_{r=1}^{K} x\_{rs} \color{red}{W\_{rs\ell k}}x\_{\ell k}\right)}
\end{align}


Suppose we are given $N$ sequences of length $L$ and every element in the sequence has an alphabet of size $K$. Denote this data by $\mathbf{X}\in \mathbb{R}^{N\times L\times K}$. The sum over alphabet adds up to one for every sequence and every element, i.e. $\sum\_{k=1}^K X\_{nlk} = 1$ for all $n\in {1,2,...,N}$ and $l\in {1,2,...,L}$. Take the simple model with two parameters 
\begin{align}
l(\mathbf{x};\color{green}{\boldsymbol{b}},\color{red}{\boldsymbol{W}})=\sum\_{\ell=1}^{L} \log p\left(x\_{l} | \boldsymbol{x}\_{-l};\color{green}{\boldsymbol{b}},\color{red}{\boldsymbol{W}}\right)=\sum\_{l=1}^{L} \log{\frac{p\left(x\_{l},\boldsymbol{x}\_{-l};\color{green}{\boldsymbol{b}},\color{red}{\boldsymbol{W}}\right)}{\sum\_{x\_l}p\left(x\_{l},\boldsymbol{x}\_{-l};\color{green}{\boldsymbol{b}},\color{red}{\boldsymbol{W}}\right)}}
\end{align}
\begin{align}
\tilde{p}(\mathbf{X}; \color{green}{\boldsymbol{b}},\color{red}{\boldsymbol{W}})&=\prod\_{l=1}^{L}\exp{\left(\sum_{k=1}^{K}\color{green}{b\_{lk}}X\_{lk}+\sum\_{k=1}^{K}\sum\_{s=l+1}^{L}\sum\_{r=1}^{K} X\_{rs} \color{red}{W\_{rslk}}X\_{lk}\right)},\\\\\\
Z(\color{green}{\boldsymbol{b}},\color{red}{\boldsymbol{W}})&=\sum\_{\mathbf{X}}\tilde{p}(\mathbf{X}; \color{green}{\boldsymbol{b}},\color{red}{\boldsymbol{W}})=\sum\_{k_1=1}^{K}\sum\_{k_2=1}^{K}...\sum\_{k_L=1}^{K}\tilde{p}(\mathbf{x\_1}(k\_1), \mathbf{x\_2}(k\_2),...\mathbf{x\_L}(k\_L); \color{green}{\boldsymbol{b}},\color{red}{\boldsymbol{W}}),\\\\\\
Z(\color{green}{\boldsymbol{b}},\color{red}{\boldsymbol{W}})&=\prod\_{l=1}^{L} \sum
\end{align}



<!-- ![image alt text](./1.png) -->

{{< figure src="./1.png" caption="Figure 1. The data matrix $\mathbf{X}\in \mathbb{R}^{N\times LK} = \mathbb{R}^{N\times L\times K}$ has $N$ sequences, every sequence is of length $L$ and every position in the sequence can have $K$ different states. In this picture states are encoded using a one-hot representation." width="420">}}
