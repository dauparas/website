+++
title = "Normalizing Flows"
subtitle = "by Justas Dauparas"

# Add a summary to display on homepage (optional).
summary = "Review of normalizing flows paper"

date = 2020-04-25T06:44:46-04:00
draft = true

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
This is a summary of the recent normalizing flows paper.


### Learn about normalizing flows
* [**Review paper**: Normalizing Flows for Probabilistic Modeling and Inference, Papamakarios, Nalisnick et al.](https://arxiv.org/pdf/1912.02762.pdf)
* [**Review paper**: Normalizing Flows: An Introduction and Review of Current Methods, Kobyzev et al.](https://arxiv.org/pdf/1908.09257.pdf)
* [**Video lecture**: Flow Models -- CS294-158-SP20 Deep Unsupervised Learning](https://www.youtube.com/watch?v=JBb5sSC0JoY&feature=youtu.be)
* [**Video lecture**: Invertible Models and Normalizing Flows, Laurent Dinh, ICLR 2020](https://iclr.cc/virtual_2020/speaker_4.html)
* [**Video lecture**: Tutorial on normalizing flows, Eric Jang, ICML 2019](https://slideslive.com/38917907/tutorial-on-normalizing-flows)
* [**Blog**: Flow-based Deep Generative Models, Lilian Weng] (https://lilianweng.github.io/lil-log/2018/10/13 flow-based-deep-generative-models.html)
* [**Blog**: Normalizing Flows Tutorial, Eric Jang](https://blog.evjang.com/2018/01/nf1.html)

**Definitions**

Let $\mathbf{x}$ be a D-dimensional real vector, i.e. $\mathbf{x}\in \mathbb{R}^{D}$, and denote a joint probability density of $\mathbf{x}$ as $p\_{x}(\mathbf{x})=p\_{x}(x\_1, x\_2,..., x\_D)$. We would like to find a transformation $T$ that maps a real vector $\mathbf{u}$ sampled from a simple distribution $p\_{u}(\mathbf{u})$ to $\mathbf{x}$. The keys equations are:
\begin{align}
\tag{1}
\mathbf{x} &\sim p\_{x}(\mathbf{x}), \mathbf{u} \sim p\_{u}(\mathbf{u}),\\\\\\
\mathbf{x} &= T(\mathbf{u}), \mathbf{u} = T^{-1}(\mathbf{x}),\\\\\\
p\_{x}(\mathbf{x})&=p\_{u}(\mathbf{u})\left|\frac{\partial\mathbf{u}}{\partial\mathbf{x}}\right|=p\_{u}(\mathbf{u})\left|\frac{\partial}{\partial\mathbf{x}} T^{-1}(\mathbf{x})\right|=p\_{u}(T^{-1}(\mathbf{x}))\left|\det{J\_{T^{-1}}(\mathbf{x})}\right|,\\\\\\
p\_{x}(\mathbf{x})&=p\_{u}(\mathbf{u})\left|\frac{\partial\mathbf{x}}{\partial\mathbf{u}}\right|^{-1}=p\_{u}(\mathbf{u})\left|\frac{\partial}{\partial\mathbf{u}}T(\mathbf{u})\right|^{-1}=p\_{u}(\mathbf{u})\left|\det{J\_{T}(\mathbf{u})}\right|^{-1}.
\end{align}

**Function composition**

Given two invertible and differentiable transformations $T\_1$ and $T\_2$ their composition $T=T\_1 \circ T\_2$ is also invertible and differentiable:

\begin{align}
\label{eq:sample}\tag{1}
(T\_2 \circ T\_1)^{-1} &= T\_1^{-1} \circ T\_2^{-1},\\\\\\
\tag{2}
\det{J\_{T\_2 \circ T\_1}(\mathbf{u})}&=\det{\frac{\partial}{\partial \mathbf{u}}{T\_2 \circ T\_1}(\mathbf{u})}=\det{\frac{\partial T\_{1}(\mathbf{u})}{\partial \mathbf{u}}\frac{\partial}{\partial T\_{1}(\mathbf{u})}{T\_2 \circ T\_1}(\mathbf{u})}=\det{J\_{T\_{1}}(\mathbf{u})}\cdot\det{J\_{T\_2}(T\_{1}(\mathbf{u}))}
\end{align}

**Maximize log likelihood**
\begin{align}
\mathcal{L}(\boldsymbol{\theta})&=-\mathbb{E}\_{p\_{x}^{\*}(\mathbf{x})}\left\[\log{p\_{x}(\mathbf{x};\boldsymbol{\theta})}\right\]\\\\\\
&=-\mathbb{E}\_{p\_{x}^{\*}(\mathbf{x})}\left\[\log{p\_{u}(T^{-1}(\mathbf{x}; \boldsymbol{\phi});\boldsymbol{\psi})}+\log{\left\|\det{J\_{T^{-1}}(\mathbf{x}; \boldsymbol{\phi})}\right\|}\right\]\\\\\\
&=-\frac{1}{N}\sum\_{n=1}^{N}\log{p\_{u}(T^{-1}(\mathbf{x}\_{n}; \boldsymbol{\phi});\boldsymbol{\psi})}+\log{\left\|\det{J\_{T^{-1}}(\mathbf{x}\_{n}; \boldsymbol{\phi})}\right\|}
\end{align}

**Composing Flows**

\begin{align}
T = T\_{K} \circ ... \circ T\_{1}
\end{align}


**Autoregressive Flows**

