+++
title = "Differential Geometry"
subtitle = "by Justas Dauparas"

# Add a summary to display on homepage (optional).
summary = "Introduction to differential geometry"

date = 2020-04-25T06:44:46-04:00
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
In progress...

**Definitions**

* A topological space $M$ is a set of points, endowed with a topology $\mathcal{T}$. This is a collection of open subsets $\\{\mathcal{O}\_{\alpha}\subset M\\}$ which obey:
\begin{align}
&M\in\mathcal{T}, \emptyset\in\mathcal{T},\\\\\\
&\mathcal{O}\_1\in\mathcal{T}, \mathcal{O}\_2\in\mathcal{T}\implies \mathcal{O}\_1\cap\mathcal{O}\_2\in\mathcal{T},\\\\\\
&\mathcal{O}\_{\gamma}\in\mathcal{T}\implies \cup_{\gamma}\mathcal{O}\_{\gamma}\in\mathcal{T}.
\end{align}

* A homeomorphism between topological spaces $(M, \mathcal{T})$ and $(\tilde{M}, \tilde{\mathcal{T}})$ is a map $f:M\mapsto\tilde{M}$ which is
 * Bijective
 * The function and its inverse are continuous. We say that $f$ is continuous if, for all $\tilde{\mathcal{O}}\in\tilde{\mathcal{T}}, f^{-1}(\tilde{\mathcal{O}})\in\mathcal{T}$.


* An n-dimensional differentiable manifold is a Hausdorff topological space $M$ such that
  * $M$ is locally homeomorphic to $\mathbf{R}^{n}$.
  * Take two open subsets $\mathcal{O}\_{\alpha}$ and $\mathcal{O}\_{\beta}$ that overlap, so that $\mathcal{O}\_{\alpha}\cap \mathcal{O}\_{\beta}\neq\emptyset$. We require that the corresponding maps $\phi\_{\alpha}:\mathcal{O}\_{\alpha}\rightarrow U\_{\alpha}$ and $\phi\_{\beta}:\mathcal{O}\_{\beta}\rightarrow U\_{\beta}$ are compatible, meaning that the map $\phi\_{\alpha}\circ \phi\_{\beta}^{-1}: \phi\_{\beta}(\mathcal{O}\_{\alpha}\cap \mathcal{O}\_{\beta})\rightarrow \phi\_{\alpha}(\mathcal{O}\_{\alpha}\cap \mathcal{O}\_{\beta})$ is infinitely differentiable.

The maps $\phi\_{\alpha}$ are called charts and the collection of charts is called an atlas. You can think of each chart as providing a coordinate system to label the region $\mathcal{O}\_{\alpha}$ of $M$. The coordinate associated to $p\in\mathcal{O}\_{\alpha}$ is
\begin{align}
\phi\_{\alpha}(p)=(x^{1}(p),...,x^{n}(p))
\end{align}
We write the coordinate is shorthand as simply $x^{\mu}(p)$, with $\mu=1,...,n$. The maps $\phi\_{\alpha}\circ \phi\_{\beta}^{-1}$ take us between different coordinate systems and are called <i>transition functions</i>. The compatibility condition is there to ensure that there is no
inconsistency between these different coordinate systems.

The advantage of locally mapping a manifold to $\mathbf{R}^n$ is that we can now import our
knowledge of how to do maths on $\mathbf{R}^n$.

We say that a function $f:M\rightarrow\mathbf{R}$ is smooth, if the map $f\circ \phi^{-1}: U\rightarrow \mathbf{R}$ is smooth for all charts $\phi$.

Similarly, we say that a map $f:M\rightarrow N$ between two manifolds $M$ and $N$ is smooth if the map $\phi\circ f \circ \phi^{-1}:U\rightarrow V$ is smooth for all charts $\phi: M\rightarrow U\subset\mathbf{R}^{dim(M)}$ and $\psi: N\rightarrow V\subset\mathbf{R}^{dim(N)}$

A <i>diffeomorphism</i> is defined to be a smooth homeomorphism $f:M\rightarrow N$. In other
words it is an invertible, smooth map between manifolds $M$ and $N$ that has a smooth inverse. If such a diffeomorphism exists then the manifolds $M$ and $N$ are said to be diffeomorphic. The existence of an inverse means $M$ and $N$ necessarily have the same dimension.

**Tangent Spaces**

Consider a function $f:M\rightarrow\mathbf{R}$. To differentiate the function at some point $p$, we introduce a chart $\phi=(x^{1},...,x^{n})$ in a neighbourhood of $p$. We can then construct the
map $f\circ \phi^{-1}:U\rightarrow\mathbf{R}$ with $U\subset\mathbf{R}^{n}$.  But we know how to differentiate functions on $\mathbf{R}^{n}$ and this gives us a way to differentiate functions on $M$, namely

\begin{align}
\left.\frac{\partial f}{\partial x^{\mu}}\right\|\_{p}:=\left.\frac{\partial\left(f \circ \phi^{-1}\right)}{\partial x^{\mu}}\right\|\_{\phi(p)}
\end{align}

Clearly this depends on the choice of chart $\phi$ and coordinates $x^{\mu}$. We would like to
give a coordinate independent definition of differentiation, and then understand what
happens when we choose to describe this object using different coordinates.

**Tangent Vectors**

We will consider smooth functions over a manifold $M$. We denote the set of all smooth
functions as $C^{\infty}(M)$.

A <i>tangent vector</i> $X\_{p}$ is an object that differentiates functions at a point $p\in M$. Specifically, $X\_p:C^{\infty}(M)\rightarrow \mathbf{R}$ satisfying

  * Linearity: $X\_{p}(f+g)=X\_{p}(f)+X\_{p}(g)$ for all $f,g\in C^{\infty}(M)$.
  * $X\_{p}(f)=0$ when $f$ is the constant function.
  * Leibnizarity: $X\_{p}(fg)=f(p)X\_{p}(g)+X\_{p}(f)g(p)$ for all $f,g\in C^{\infty}(M)$. This is a product rule.

  Theorem:

  The set of all tangent vectors at point $p$ forms an n-dimensional vector space. We call this space the <i>tangent space</i> $T\_{p}(M)$. The tangent vectors $\left.\partial\_{\mu}\right\|\_{p}$ provide a basis for $T\_{p}(M)$. This means that we can write any tangent vector as 

  \begin{align}
X\_{p}=X^{\mu}\left.\partial\_{\mu}\right\|\_{p}
\end{align}

with $X^{\mu}=X\_{p}(x^{\mu})$ the components of the tangent vector in this basis.