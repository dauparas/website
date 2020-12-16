+++
title = "Normalizing Flows"
subtitle = "by Justas Dauparas"

# Add a summary to display on homepage (optional).
summary = "Review of normalizing flows paper"

date = 2020-04-25T06:44:46-04:00
draft = true
unlisted:true

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
In progress...

### Learn about normalizing flows
* [**Review paper**: Normalizing Flows for Probabilistic Modeling and Inference, Papamakarios, Nalisnick et al.](https://arxiv.org/pdf/1912.02762.pdf)
* [**Review paper**: Normalizing Flows: An Introduction and Review of Current Methods, Kobyzev et al.](https://arxiv.org/pdf/1908.09257.pdf)
* [**Video lecture**: Flow Models -- CS294-158-SP20 Deep Unsupervised Learning](https://www.youtube.com/watch?v=JBb5sSC0JoY&feature=youtu.be)
* [**Video lecture**: Invertible Models and Normalizing Flows, Laurent Dinh, ICLR 2020](https://iclr.cc/virtual_2020/speaker_4.html)
* [**Video lecture**: Tutorial on normalizing flows, Eric Jang, ICML 2019](https://slideslive.com/38917907/tutorial-on-normalizing-flows)
* [**Blog**: Flow-based Deep Generative Models, Lilian Weng] (https://lilianweng.github.io/lil-log/2018/10/13/flow-based-deep-generative-models.html)
* [**Blog**: Normalizing Flows Tutorial, Eric Jang](https://blog.evjang.com/2018/01/nf1.html)

**Definitions**

* $p\_{x}^{\*}(\mathbf{x})=p\_{x}^{\*}(x\_1, x\_2,..., x\_D) \sim \mathbf{x}\in\mathbb{R}^{D}$, unknown true distribution of data,
* $p\_{x}(\mathbf{x})=p\_{x}(x\_1, x\_2,..., x\_D) \sim \mathbf{x}\in\mathbb{R}^{D}$, model distribution of data,
* $p\_{u}(\mathbf{u})=p\_{u}(u\_1, u\_2,..., u\_D) \sim \mathbf{u}\in\mathbb{R}^{D}$, simple (normal) distribution,
* $T(\mathbf{u})=\mathbf{x}\in\mathbb{R}^{D}$, transformation function,
* $T^{-1}(\mathbf{x})=\mathbf{u}\in\mathbb{R}^{D}$, inverse transformation function,
* $J\_{T}(\mathbf{u})=\frac{\partial}{\partial \mathbf{u}}T(\mathbf{u})=\frac{\partial \mathbf{x}}{\partial \mathbf{u}}\in\mathbb{R}^{D\times D}$, Jacobian matrix of transformation function,
* $J\_{T^{-1}}(\mathbf{x})=\frac{\partial}{\partial \mathbf{x}}T^{-1}(\mathbf{x})=\frac{\partial \mathbf{u}}{\partial \mathbf{x}}\in\mathbb{R}^{D\times D}$, Jacobian matrix of inverse transformation function,

{{< figure src="./normalizing_flows_2.svg" caption="<b>Figure 1.</b> A differentiable transformation $T$ maps a D-dimentional vector $\mathbf{u}\in\mathbb{R}^{D}$ to a D-dimentional vector $\mathbf{x}\in\mathbb{R}^{D}$ via yellow arrow. This transformation has a differentiable inverse denoted by $T^{-1}$ that maps $\mathbf{x}$ to $\mathbf{u}$ via purple arrow. Jacobian matrices for these functions are depicted as squares, $J\_{T}(\mathbf{u})\in\mathbb{R}^{D\times D}$ and $J\_{T^{-1}}(\mathbf{x})\in\mathbb{R}^{D\times D}$." width="450">}}

**Change of variables**

We can express probability density $p\_{x}$ in terms of $p\_{u}$ using change of variables:

* $p\_{x}(\mathbf{x})=p\_{u}(\mathbf{u})\left|\frac{\partial\mathbf{u}}{\partial\mathbf{x}}\right|=p\_{u}(\mathbf{u})\left|\frac{\partial}{\partial\mathbf{x}} T^{-1}(\mathbf{x})\right|=p\_{u}(T^{-1}(\mathbf{x}))\left|\det{J\_{T^{-1}}(\mathbf{x})}\right|$
* $p\_{x}(\mathbf{x})=p\_{u}(\mathbf{u})\left|\frac{\partial\mathbf{x}}{\partial\mathbf{u}}\right|^{-1}=p\_{u}(\mathbf{u})\left|\frac{\partial}{\partial\mathbf{u}}T(\mathbf{u})\right|^{-1}=p\_{u}(\mathbf{u})\left|\det{J\_{T}(\mathbf{u})}\right|^{-1}$

given that the transformation $T$ is invertible and both $T$ and $T^{-1}$ are differentiable.

**Applications**

* Sample from $p\_{x}(\mathbf{x})$ by sampling points from $p\_{u}(\mathbf{u})$, i.e. $\mathbf{x}=T(\mathbf{u})$ where $\mathbf{u} \sim p\_{u}(\mathbf{u})$. This requires the ability to sample from $p\_{u}(\mathbf{u})$ and to compute the transformation $T$.
* Evaluate model's density using $p\_{x}(\mathbf{x})=p\_{u}(T^{-1}(\mathbf{x}))\left|\det{J\_{T^{-1}}(\mathbf{x})}\right|$. This requires computing the inverse transformation $T^{-1}$ and its Jacobian determinant, and evaluating the density $p\_{u}(\mathbf{u})$.

**Function composition**

{{< figure src="./nf_3.svg" caption="<b>Figure 2.</b> A differentiable transformation $T=T\_3\circ T\_2\circ T\_1$ which is a compostion of three functions $T\_1, T\_2, T\_3$ maps a vector $\mathbf{u}\in\mathbb{R}^{D}$ to a vector $\mathbf{x}\in\mathbb{R}^{D}$ via yellow arrow. The inverse transformation $T^{-1}=T\_{1}^{-1}\circ T\_{2}^{-1}\circ T\_{3}^{-1}$ maps $\mathbf{u}$ to $\mathbf{x}$ via purple arrow. $\mathbf{z}\_{i}$ vectors denote in between states with $\mathbf{u}=\mathbf{z}\_{0}$ and $\mathbf{x}=\mathbf{z}\_{3}$." width="650">}}

Given three invertible and differentiable transformations $T\_1, T\_2$ and $T\_3$ their composition $T=T\_3 \circ T\_2 \circ T\_1$ is also invertible and differentiable:

\begin{align}
T(\mathbf{u})&=T\_3 \circ T\_2 \circ T\_1 (\mathbf{u}),\\\\\\
T^{-1}(\mathbf{x})&=(T\_3 \circ T\_2 \circ T\_1)^{-1}(\mathbf{x}) = T\_1^{-1} \circ T\_2^{-1} \circ T\_3^{-1}(\mathbf{x}),\\\\\\
\frac{\partial}{\partial \mathbf{u}}T(\mathbf{u})&=\frac{\partial}{\partial \mathbf{u}}T\_3 \circ T\_2 \circ T\_1 (\mathbf{u})=\frac{\partial T\_1(\mathbf{u})}{\partial \mathbf{u}}\frac{\partial T\_2(T\_1(\mathbf{u}))}{\partial T\_1(\mathbf{u})}\frac{\partial T\_3(T\_2(T\_1(\mathbf{u})))}{\partial T\_2(T\_1(\mathbf{u}))}=\frac{\partial T\_1}{\partial \mathbf{u}}\frac{\partial T\_2}{\partial T\_1}\frac{\partial T\_3}{\partial T\_2},\\\\\\
\frac{\partial}{\partial \mathbf{x}}T^{-1}(\mathbf{x})&=\frac{\partial}{\partial \mathbf{x}}T\_1^{-1} \circ T\_2^{-1} \circ T\_3^{-1} (\mathbf{x})=\frac{\partial T\_3^{-1}(\mathbf{x})}{\partial \mathbf{x}}\frac{\partial T\_2^{-1}(T\_3^{-1}(\mathbf{x}))}{\partial T\_3^{-1}(\mathbf{x})}\frac{\partial T\_1^{-1}(T\_2^{-1}(T\_3^{-1}(\mathbf{x})))}{\partial T\_2^{-1}(T\_3^{-1}(\mathbf{x}))}=\frac{\partial T\_3^{-1}}{\partial \mathbf{x}}\frac{\partial T\_2^{-1}}{\partial T\_3^{-1}}\frac{\partial T\_1^{-1}}{\partial T\_2^{-1}},
\end{align}
where for differentiation the chain rule was applied. Now to calculate the Jacobian matrix of this transformation we can use the fact that the determinant of a matrix product of square matrices equals the product of their determinants, i.e. $\det{AB}=\det{A}\cdot\det{B}$ where $A, B\in\mathbb{R}^{D\times D}$.

\begin{align}
\det{\frac{\partial}{\partial \mathbf{u}}T(\mathbf{u})}=&\det{J\_{T\_3\circ T\_2 \circ T\_1}(\mathbf{u})}=\det{\frac{\partial T\_1}{\partial \mathbf{u}}\frac{\partial T\_2}{\partial T\_1}\frac{\partial T\_3}{\partial T\_2}}=\det{J\_{T\_{1}}(\mathbf{u})}\cdot\det{J\_{T\_2}(T\_{1}(\mathbf{u}))}\cdot\det{J\_{T\_3}(T\_{2}(T\_{1}(\mathbf{u})))},\\\\\\
\det{\frac{\partial}{\partial \mathbf{x}}T^{-1}(\mathbf{x})}&=\det{J\_{T\_1^{-1} \circ T\_2^{-1}\circ T\_3^{-1}}(\mathbf{x})}=\det{\frac{\partial T\_3^{-1}}{\partial \mathbf{x}}\frac{\partial T\_2^{-1}}{\partial T\_3^{-1}}\frac{\partial T\_1^{-1}}{\partial T\_2^{-1}}}=\det{J\_{T\_{3}^{-1}}(\mathbf{x})}\cdot\det{J\_{T\_2^{-1}}(T\_{3}^{-1}(\mathbf{x}))}\cdot\det{J\_{T\_1^{-1}}(T\_2^{-1}(T\_{3}^{-1}(\mathbf{x})))}.
\end{align}

**Minimizing loss of log likelihood**
\begin{align}
\mathcal{L}(\boldsymbol{\theta})&=-\mathbb{E}\_{p\_{x}^{\*}(\mathbf{x})}\left\[\log{p\_{x}(\mathbf{x};\boldsymbol{\theta})}\right\]\\\\\\
&=-\mathbb{E}\_{p\_{x}^{\*}(\mathbf{x})}\left\[\log{p\_{u}(T^{-1}(\mathbf{x}; \boldsymbol{\phi});\boldsymbol{\psi})}+\log{\left\|\det{J\_{T^{-1}}(\mathbf{x}; \boldsymbol{\phi})}\right\|}\right\]\\\\\\
&\approx-\frac{1}{N}\sum\_{n=1}^{N}\log{p\_{u}(T^{-1}(\mathbf{x}\_{n}; \boldsymbol{\phi});\boldsymbol{\psi})}+\log{\left\|\det{J\_{T^{-1}}(\mathbf{x}\_{n}; \boldsymbol{\phi})}\right\|}
\end{align}


<!-- **Appendix**


* $p\_{u}(\mathbf{u})=p\_{x}(\mathbf{x})\left|\frac{\partial\mathbf{x}}{\partial\mathbf{u}}\right|=p\_{x}(\mathbf{x})\left|\frac{\partial}{\partial\mathbf{u}} T(\mathbf{u})\right|=p\_{x}(T(\mathbf{u}))\left|\det{J\_{T}(\mathbf{u})}\right|$
* $p\_{u}(\mathbf{u})=p\_{x}(\mathbf{x})\left|\frac{\partial\mathbf{u}}{\partial\mathbf{x}}\right|^{-1}=p\_{x}(\mathbf{x})\left|\frac{\partial}{\partial\mathbf{x}}T^{-1}(\mathbf{x})\right|^{-1}=p\_{x}(\mathbf{x})\left|\det{J\_{T^{-1}}(\mathbf{x})}\right|^{-1}$

**Function composition**

Given two invertible and differentiable transformations $T\_1$ and $T\_2$ their composition $T=T\_2 \circ T\_1$ is also invertible and differentiable:

\begin{align}
\label{eq:sample}\tag{1}
T^{-1}&=(T\_2 \circ T\_1)^{-1} = T\_1^{-1} \circ T\_2^{-1},\\\\\\
\tag{2}
\det{J\_{T\_2 \circ T\_1}(\mathbf{u})}&=\det{\frac{\partial}{\partial \mathbf{u}}{T\_2 \circ T\_1}(\mathbf{u})}=\det{\frac{\partial T\_{1}(\mathbf{u})}{\partial \mathbf{u}}\frac{\partial}{\partial T\_{1}(\mathbf{u})}{T\_2 \circ T\_1}(\mathbf{u})}=\det{J\_{T\_{1}}(\mathbf{u})}\cdot\det{J\_{T\_2}(T\_{1}(\mathbf{u}))},\\\\\\
\tag{3}
\det{J\_{T\_1^{-1} \circ T\_2^{-1}}(\mathbf{x})}&=\det{\frac{\partial}{\partial \mathbf{x}}{T\_1^{-1} \circ T\_2^{-1}}(\mathbf{u})}=\det{\frac{\partial T\_{2}^{-1}(\mathbf{x})}{\partial \mathbf{x}}\frac{\partial}{\partial T\_{2}^{-1}(\mathbf{x})}{T\_1^{-1} \circ T\_2^{-1}}(\mathbf{x})}=\det{J\_{T\_{2}^{-1}}(\mathbf{x})}\cdot\det{J\_{T\_1^{-1}}(T\_{2}^{-1}(\mathbf{x}))}
\end{align} -->
