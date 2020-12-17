+++
title = "AlphaFold 2 & Equivariance"
subtitle = ""

# Add a summary to display on homepage (optional).
summary = "A friendly introduction to protein geometry, equivariance, and AlphaFold 2."

date = 2020-12-17T06:44:46-04:00
draft = false

# Authors. Comma separated list, e.g. `["Bob Smith", "David Jones"]`.
authors = []

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
[Fabian Fuchs](https://twitter.com/fabianfuchsml) & [Justas Dauparas](https://twitter.com/JustasDauparas)

A few weeks ago, in the latest CASP competition for protein structure prediction ([CASP14](https://predictioncenter.org/casp14/index.cgi)), DeepMind's AlphaFold 2[^3] outperformed all its competitors with an unprecedented margin. In this blog post, we aim to shed light on one of the important building blocks that distinguishes AlphaFold 2 from the other approaches and likely contributed to their success: an equivariant structure prediction module.

In short: this module is a neural network that iteratively refines the structure predictions while respecting and leveraging an important symmetry of the problem, namely that of roto-translations. At this point, DeepMind has not yet published a paper so we do not know how exactly they address this. However, from their CASP14 presentation, it seems possible that their model is similar to the [SE(3)-Transformer](https://arxiv.org/abs/2006.10503). Most of this blog post is written irrespectively of the exact implementation of their SE(3)[^4]-equivariant transformer module. At some points, particularly when we go into depth, we need to make some assumptions, but we will state those explicitly. We assume some basic understanding of deep learning as a prerequisite for reading this post, but not much more. We hope this blog post is valuable for both machine learners and biologists/chemists.

[^3]: We suggest to read DeepMind's blog posts for more details: [AlphaFold 1](https://deepmind.com/blog/article/AlphaFold-Using-AI-for-scientific-discovery), [AlphaFold 2](https://deepmind.com/blog/article/alphafold-a-solution-to-a-50-year-old-grand-challenge-in-biology). Slides from the CASP14 conference are publicly available [here](https://predictioncenter.org/casp14/doc/presentations/2020_12_01_TS_predictor_AlphaFold2.pdf).

[^4]: SE(3) is the group of rotations and translations in 3D. SE is short for *special euclidean*. DeepMind says '3D equivariant transformer' in their presentation. Most likely, they chose *3D* just because the term is a lot more intuitive.


## **What is the Protein Structure Prediction Problem and Why is it Symmetric?**

In the protein structure prediction problem the rules of the game are that given a sequence of [amino acids](https://en.wikipedia.org/wiki/Amino_acid) (alphabet = "ARNDCQEGHILKMFPSTWYV-") you have to return XYZ coordinates of all atoms in some frame of reference. The simplified version of this problem is to return XYZ coordinates of the protein backbone atoms only, ignoring side chain atoms.

What does *some frame of reference* mean? It means that the model is expected to choose an *overall orientation* of the protein arbitrarily. This can be broken down into the position of the centre of mass as well as the angular orientation. Assuming the protein floats freely in a solution, both of these choices do not affect the energy of the system[^5]. Leveraging this property of the prediction task could prove very beneficial for the performance of the model. We will explore this later in this blog post.



[^5]: This is true because the gravitational forces are irrelevant compared to the electrostatic forces that govern the folding of a protein. The process of experimental measuring itself does actually introduce a frame of reference --- as any measuring procedure does.

Traditionally, this symmetry has been dealt with in a fairly straightforward way. The first generation of AlphaFold, for example, predicted distance distributions between atoms and converted those into a potential (which is easy to make symmetric). A gradient descent algorithm was then used to find coordinates for the protein which minimise the potential. AlphaFold 2, on the other hand, is doing something different. It predicts the coordinates directly, in an end-to-end fashion. This end-to-end regression to 3D coordinates is what makes it more difficult to deal with the symmetry correctly.


## **Protein Backbone Geometry**

As we mentioned earlier, the easier (but still pretty hard) version of the protein structure prediction problem is to determine the protein backbone geometry. Let's have a look at what a protein backbone is and how it can be represented.

A protein backbone is a repeating sequence (linear chain) of 3 atoms: nitrogen, carbon, and another carbon, namely 

$$\underbrace{N^{(1)}, C\_{\alpha}^{(1)}, C^{(1)}}, \underbrace{N^{(2)}, C\_{\alpha}^{(2)}, C^{(2)}},...,\underbrace{N^{(L)}, C\_{\alpha}^{(L)}, C^{(L)}}$$

for the protein of length $L$. The middle carbon has a special name. It is called "C alpha" because that is where the side chain is connected to. The first three atoms belong to the first amino acid (first residue), the next three to the next amino acid (next residue) etc. Below we depict the protein backbone geometry of two residues.

![](https://i.imgur.com/fZ0Sx3V.png)
In the above illustration of the protein backbone, the atoms would be represented as: $N^{(1)}, C\_{\alpha}^{(1)}, C^{(1)}, N^{(2)}, C\_{\alpha}^{(2)},C^{(2)},N^{(3)}.$ Bond lengths are shown in angstroms and angles in degrees. For example the distance between $N^{(i)}$ and $C^{(i)}$ is about $1.47 \unicode{x212B}$ (in SI units $1.47\cdot 10^{-10}$ meters). Notice that the bond lengths and angles between neighboring backbone atoms are fixed. The only remaining degrees of freedom are the so-called torsion (dihedral) angles. Those are shown as $\psi^{(1)}, \omega^{(1)}, \phi^{(2)}, \psi^{(2)}, \omega^{(2)}$ in the diagram. A red triangle shows a plane connecting 3 atoms from one amino acid. All red triangles are of the same size except that they have different positions and different orientations. Now let's have a look at a real protein structure visualised in PyMOL where each amino acid is only depicted by its $C_{\alpha}$ because other backbone atoms are rigidly connected to it.

![](https://i.imgur.com/uiW9ESH.jpg)
This example protein, [1QYS](https://www.rcsb.org/structure/1qys), demonstrates a relatively simple backbone configuration. On the left, adjacent $C_{\alpha}$ atoms (black dots) are connected by straight lines ($N, C$ are left out for clarity). On the right, the cartoon structure shows subsets of residues as [alpha helices](https://en.wikipedia.org/wiki/Alpha_helix) and [beta sheets](https://en.wikipedia.org/wiki/Beta_sheet) which are [secondary structure](https://en.wikipedia.org/wiki/Protein_secondary_structure) representations. The colour changes from blue at the start to red at the end of the backbone. This protein is 92 amino acid residues long ($L=92$).

Proteins come in various lengths. For example, in the CASP14 competition, the shortest target protein had 32 amino acids, whereas the longest one had 2180. This means that the computational structure prediction pipeline needs to handle variable-length inputs/outputs as well as long sequences. Furthermore, proteins can assemble into [protein complexes](https://en.wikipedia.org/wiki/Protein_complex) to form larger structures which are more difficult to predict.


<!-- **Fabian:** *I think, after the figure and before the next headline it would be nice to have a paragraph giving a little background about the relevance of this backbone representation. Is there some upper limit on how heavy a residue can be? How heavy is the overall protein? How long can the backbone be?* -->


### Ways to Represent a Protein Backbone

Predicting backbone configurations in 3D space may seem to be straightforward, but is in fact challenging because atoms that are far in the sequence space ([primary protein structure](https://en.wikipedia.org/wiki/Protein_structure#Primary_structure)) can be close in 3D space and they can interact. This suggests that non-local modelling is needed to accurately predict [tertiary structure](https://en.wikipedia.org/wiki/Protein_structure#Tertiary_structure). At the same time, protein backbones have a clearly defined local structure (bond lengths and angles are fixed). Choosing to focus on local and/or non-local interactions leads to different backbone representations. In the following, we will describe four common ways of representing the protein backbone. Finally, we will explain how AlphaFold 2 combined some of these and why.

<!-- 
We are going to describe protein backbone in four different ways using XYZ coordinates of all atoms, XYZ coordinates of C alpha + orientation, torsion angles, and relative distances/orientations. -->


<!-- **Fabian:** *Let's add a paragraph motivating why knowing about the different representations is important? Motivating here + summarise in the end* -->

#### 1. XYZ Coordinates of Atoms

Protein backbone atoms can be described using XYZ coordinates. The first residue is composed of $N^{(1)}, C_{\alpha}^{(1)}$, and $C^{(1)}$ each of which has an X, Y, and Z coordinate. This results in a 3 by 3 matrix that represents the entire residue. When you stack these together for the whole backbone of length $L$ you generate a tensor $X$: 

$$X\in \mathbb{R}^{3\times 3 \times L},$$

Remember that some distances and angles between backbone atoms (within and between residues) are fixed, so these coordinates will have to satisfy those constraints to result in a valid protein structure.

#### 2. XYZ Coordinates of $C_\alpha$ + Orientation

This representation is based on the premise that distances and angles between $C\_{\alpha}^{(i)}$ and $N^{(i)}$ and $C^{(i)}$ are fixed. Therefore it is enough to represent the XYZ coordinates of  $C\_{\alpha}^{(i)}$ and the orientation of these atoms relative to $C\_{\alpha}^{(i)}$. There will still be constraints on the distance and angle between adjacent residues that need to be satisfied for the local geometry to be feasible, but otherwise this representation automatically preserves intrinsic residue geometry. AlphaFold 2 used this representation in their structure module.


#### 3. Protein Torsion (Dihedral) Angles
Since bond lengths and angles between neighbouring backbone atoms are fixed, the only remaining degrees of freedom are the torsion (dihedral) angles.

<!-- ![](https://i.imgur.com/HWuiR3Z.png) -->
![](https://i.imgur.com/53c5aWm.png)

A torsion (dihedral) angle is the angle between two intersecting planes, in this case it is the angle between the green and the red planes. Mathematically we define the function called $\text{Torsion}$ which takes in 4 points in a chain ($C^{(1)}, N^{(2)}, C\_{\alpha}^{(2)}, C^{(2)}$) and outputs the angle between the planes created by $C^{(1)}, N^{(2)}, C\_{\alpha}^{(2)}$ and $N^{(2)}, C\_{\alpha}^{(2)}, C^{(2)}$ as a value between $-\pi$ and $\pi$. We write this as

$$\phi^{(2)}=\text{Torsion}(C^{(1)}, N^{(2)}, C\_{\alpha}^{(2)}, C^{(2)})\in [-\pi, \pi].$$
![](https://i.imgur.com/fZ0Sx3V.png)
Demonstrated in the picture above, each torsion angle has a specific name in protein literature. They are defined as

$$
\begin{align}
\phi^{(i)}&=\text{Torsion}(C^{(i-1)}, N^{(i)}, C\_{\alpha}^{(i)}, C^{(i)}),\\\\\\
\psi^{(i)}&=\text{Torsion}(N^{(i)}, C\_{\alpha}^{(i)}, C^{(i)}, N^{(i+1)}),\\\\\\
\omega^{(i)}&=\text{Torsion}(C\_{\alpha}^{(i)}, C^{(i)}, N^{(i+1)}, C\_{\alpha}^{(i+1)}),
\end{align}
$$

where $i = 1, 2, 3...,L$. Notice that $\phi^{(1)}$ and $\psi^{(L)}, \omega^{(L)}$ are not defined because there are no $C^{(0)}$ and $N^{(L+1)}$ atoms. Therefore a protein backbone can be represented as a sequence of torsion angles: $$\psi^{(1)}, \omega^{(1)}, \phi^{(2)}, \psi^{(2)}, \omega^{(2)},...,\phi^{(L)}.$$This representation is independent of the frame of reference and it does not have any local bond length/angle constraints, but it suffers from the lever arm effect meaning that small errors propagate along the backbone. Interestingly, AlphaFold 1 predicted torsion angles to initialise the gradient descent algorithm to optimize the relative distance potentials to obtain the protein structure. It is possible that AlphaFold 2 also predicted torsion angles to obtain initial coordinates of the structure.

#### 4. Relative Distances and Angles between Residues

Another way to represent backbone atoms without a frame of reference is to use the pairwise distance and angle representations. One choice could be to represent relative distances between $C_{\alpha}$ coordinates and relative orientations (e.g. [Euler angles](https://en.wikipedia.org/wiki/Euler_angles)) between red triangles. Denote the Euclidean distance between $C\_{\alpha}^{(i)}$ and $C\_{\alpha}^{(j)}$ as the distance matrix $D^{(ij)}\_{\alpha}$:

$$D^{(ij)}\_{\alpha}=\sqrt{(X\_{\alpha}^{(i)}-X\_{\alpha}^{(j)})\cdot(X_{\alpha}^{(i)}-X\_{\alpha}^{(j)})}=\left\lVert(X\_{\alpha}^{(i)}-X\_{\alpha}^{(j)})\right \rVert_2.$$

The $(D^{(ij)}\_{\alpha})^2$ matrix has some special properties. If we write out the dot product we get 

\begin{align}
(D^{(ij)}\_{\alpha})^2=&(X\_{\alpha}^{(i)}\cdot X\_{\alpha}^{(i)}+X\_{\alpha}^{(j)}X\_{\alpha}^{(j)}-2X\_{\alpha}^{(i)}X\_{\alpha}^{(j)}),\\\\\\
(D^{(ij)}\_{\alpha})^2=&(G\_{\alpha}^{(ii)}+G\_{\alpha}^{(jj)}-2G\_{\alpha}^{(ij)}),\\\\\\
G\_{\alpha}^{(ij)} :=& X\_{\alpha}^{(i)}X\_{\alpha}^{(j)},
\end{align}

where $G\_{\alpha}^{(ij)}$ is known as a [Gram matrix](https://en.wikipedia.org/wiki/Gramian_matrix). The Gram matrix has rank 3 because it is a product of two 3-dimensional vectors $X\_{\alpha}^{(i)}$ and $X\_{\alpha}^{(j)}$ and therefore the square of the distance matrix has rank $\leq 1+1+3=5$. There are requirements for the geometrically centred distance matrix to be positive semi-definite (meaning all eigenvalues are greater or equal to zero). Read more about Euclidean Distance Matrices [here](https://arxiv.org/abs/1502.07541.pdf). It is a global representation of the structure.  

If one has a distance matrix, there is a simple algorithm to obtain coordinates that satisfy those distances. It is called [Multidimensional scaling (MDS)](https://en.wikipedia.org/wiki/Multidimensional_scaling). Here is how it works.

The squared distance matrix $D\_{\alpha}^2$ is centred by the matrix $J$ to recover the Gram matrix $G\_{\alpha}$ and then the Gram matrix is decomposed using eigenvalue decomposition into the diagonal matrix of eigenvalues $\Lambda$ and orthonormal matrix $U$. The obtained coordinates $X\_{\alpha}$ are correct up to orthogonal transformation (rotation or reflection).

\begin{align}
J =& I-\frac{1}{L} 11^{T},\\\\\\
G\_{\alpha} =& -\frac{1}{2}JD\_{\alpha}^2J,\\\\\\
G\_{\alpha} =& U\Lambda U^{T}=X\_{\alpha}X\_{\alpha}^{T},\\\\\\
X\_{\alpha} =& U\sqrt{\Lambda}.
\end{align}

There are many different representations for 3D [relative angles](https://en.wikipedia.org/wiki/Orientation_(geometry)) (change of frame). We are not going to discuss them here.

#### Summary

Even though the final outputs need to be XYZ coordinates, it can be beneficial to use various representations in different parts of the pipeline. Most of the information for protein structure prediction comes from the inverse covariance matrix which is estimated using homologous sequences based on the premise of [coevolution](https://en.wikipedia.org/wiki/Direct_coupling_analysis). This information comes in a pairwise fashion (because it is a covariance matrix) and is used to predict the relative distances and angles (see method 4 above). Previously, AlphaFold 1 used the [ResNet](https://en.wikipedia.org/wiki/Residual_neural_network) architecture to map coevolution features to binned distance probabilities. 

A protein can be represented as a graph where nodes are residues and edges are the connections between them. These edges include information about the relative distances and angles, but the graph is not embedded in 3D space. This is the 'trunk' part of the AlphaFold 2 network, as shown later. To begin representing this information in 3D space, and obtain intitial XYZ coordinates, one could potentially use torsion angles (see method 3), but this might be too constraining. AlphaFold 2 probably used some network/algorithm to map graph features to obtain the initial XYZ coordinates of $C_\alpha$ + orientation (see method 2 above). Later in the pipeline, they improved their initial prediction by iteratively running their structure module. This is called the refinement step. Now we are going to look at the AlphaFold 2 architecture in more detail.

## **The AlphaFold 2 Architecture**

Having introduced the problem as well as different ways to represent a protein backbone, let's now examine what AlphaFold 2 is doing. The following slide is taken from the CASP14 conference [presentation](https://predictioncenter.org/casp14/doc/presentations/2020_12_01_TS_predictor_AlphaFold2.pdf):

![AlphaFold2 model](https://i.imgur.com/uhRTxUk.png)

As we can see, the AlphaFold 2 architecture consists of three parts:

**The Embedding.** This is used to encode the target sequence and related sequences (MSA - [multiple sequence alignment](https://en.wikipedia.org/wiki/Multiple_sequence_alignment)) as well as related protein structures called [templates](https://en.wikipedia.org/wiki/Homology_modeling).

**The Trunk.** This part learns the residue-residue graph edges and the sequence-residue graph edges. The residue-residue edges represent pairwise information between all residues similar to relative distances in 3D space and relative angles. The sequence-residue edges might have sequence evolutionary information. This information can be used to predict pairwise distances as shown in the slide, but more importantly, it is passed to the structure module to build XYZ coordinates of the structure.


**The Structure module.** This module uses a 3D equivariant transformer architecture to refine backbone coordinates and predict side chains. The backbone is represented as oriented red triangles, and the task of this network is to predict new positions and orientations of red triangles as well as the confidence score:

![](https://i.imgur.com/ZeeFc3k.png)


From here on, we will focus on the structure module as this is where the symmetry is broken (initial 3D coordinates obtained). The 'Embedding' and the 'Trunk' take strings of amino acids and create matrix descriptions about potential interactions and relations. None of this is embedded in 3D space; there are no coordinates attached to any of this information. In the structure module, this bit becomes tricky. Suddenly, there are 3D coordinates. Ordinary neural networks do not know what coordinates are. By default, coordinates are just numbers. If we rotate the entire backbone, these numbers change a lot, even though the energy stays the same. This could, in principle, be learned by a neural network, but dealing with global rotations correctly in itself imposes a learning problem that is far beyond trivial. AlphaFold 2's structure module does not have to learn this. It is baked into its design. To that end, it combines two concepts: self-attention (aka the transformer mechanism) and equivariance.

## **What is a Transformer?**



The words *Transformer* and *self-attention* are often used interchangeably and describe a mechanism in neural networks which operates on a set of objects (an object could, for example, be an atom or an amino acid) that allows for querying specific information. A self-attention layer maps from set to set or --- in our case --- graph to graph updating the features of the nodes. It focuses on one object at a time, let's say a carbon atom, and queries the surrounding objects *conditioned* on the information/features attached to this carbon atom. For example, given what we know already about the location of the carbon atom, it might be particularly useful to query for nitrogen atoms in its surrounding. This is in contrast to ordinary convolutions, which combine features in a weighted sum depending on their relative distance but not depending on the query point.

We will first go through the attention mechanism in a general setting and then move to a graph context. If you are very familiar with graphs, but you find the first part confusing, stick with us until the end of this section before re-reading, the paragraph on graphs might make it clear for you.

The following diagram gives a detailed description of what's happening in a general non-graph context: 

![](https://i.imgur.com/KZYyQ5S.png)


At the beginning of the layer, each object has features $f\_{in}$ attached to them. The output of the layer will be updated features $f\_{out}$ for each object. Linear maps project the input features to **q**ueries, **k**eys, and **v**alues. The query from one object is compared to the keys of all other points using a scalar product and resulting in the attention weights. These are then used to get a weighted sum of the values.

Moving to a graph context, we can think of it as follows. At the beginning of a layer, we have a feature vector attached to each node. Each feature is then transformed (via a learnable, linear function) into a key, a value and a query vector. The keys and values are then propagated to all the (directed) edges going away from the node. The queries are propagated to all the incoming edges. Next, queries and keys are multiplied to get weights. For each node, a softmax over all the weights on the incoming edges is applied to normalise the attention weights. Finally, the values are multiplied with the attention weights and propagated to the nodes.

The self-attention mechanism seems like a set of arbitrary choices, so why should we use this? In short, because it is known to work really well. It 'transformed' (sorry) the field of [natural language processing](https://arxiv.org/abs/1706.03762) and also had major successes in the fields of graph learning, image processing and relational reasoning.


## **What is Equivariance?**
The second machine learning concept we will take a look at is equivariance. It is explained easiest by referring to CNNs (convolutional neural networks). Convolutional layers are translation equivariant, meaning that if the input image is shifted by 3 pixels to the right, the output is also shifted by 3 pixels to the right (assuming a stride of 1). Shifting the input by a few pixels to the right does not pose an entirely new problem. Making use of this *symmetry* and treating the two inputs similarly is important: it saves parameters, reduces overfitting and speeds up learning. 

The following video by Daniel Worrall visualises nicely how this plays out in a CNN (full video [here](https://youtu.be/qoWAFBYOtoU?t=34)):

<!-- <iframe width="700" height="400" src="http://edwag.github.io/video/translation_equivariance.mp4" frameborder="0" allowfullscreen></iframe><a href="/" target="_blank"></a> -->

<!-- <video width="100%" autoplay loop playsinline muted poster="http://edwag.github.io/img/translation_equivariance.jpg">
<source src="http://edwag.github.io/video/translation_equivariance.mp4" type="video/mp4"/> -->

<!-- ![](http://edwag.github.io/img/translation_equivariance.jpg) -->
![](https://i.imgur.com/YMCBT26.jpg)

<!-- <p align="center"> -->

Formally, a function $h(x)$ being equivariant can be written as follows[^1]:

[^1]: This equation is actually stricter than it needs to be. The transformation $\sigma$ does not have to be the same on both sides of the equation. It just needs to be a representation of the same group.

$$h\big(\sigma (x)\big) = \sigma \big(h(x)\big) \quad \quad \forall \sigma, x$$

Applying a transformation $\sigma$ on the input has the same effect as applying it to the output. For ordinary convolutions $\sigma$ is a translation of all pixels. For 2D images, this is often all we need. However, when we move to proteins (or other graphs / point clouds in 3D), translations alone really do not capture all the relevant transformations. One crucial symmetry group apart from translations is the special orthogonal group SO(3). This is the group which describes rotation in 3D space. Equivariance for rotations reads as follows:

$$h\big(\mathbf{R} (x)\big) = \mathbf{R} \big(h(x)\big) \quad\quad \forall \,\mathbf{R} \in SO(3)$$

Let's go back to Deepmind's slide on the structure module in AlphaFold 2. In each iteration, the structure module takes in a spatial configuration (the current best guess of what the protein looks like) and predicts corrections, i.e. local shifts and rotations of individual parts of the chain:

![](https://i.imgur.com/vbxEcls.png)

The key here is: the orientation of the current protein configuration (i.e. the input to each iteration) is completely arbitrary and to some degree random. In other words, there is a symmetry we should leverage. When rotating the input protein, the corrections (which need to be expressed as vectors and/or matrices) should rotate as well. Any type of network could theoretically *learn* this, but it would be much more elegant to bake this into the model directly --- with a rotation equivariant neural network. And to capture both translation *and* rotation, we extend the requirement to roto-translation equivariance.



## **How to build a 3D Transformer / SE(3)-Transformer**

So far, we established the usefulness of transformers and of roto-translation equivariance. The question is, how to actually build a roto-translation equivariant transformer network. 

To clean up nomenclature: the group of roto-translations in 3D is called the SE(3) group. We will assume that DeepMind uses *3D* instead of *SE(3)* in their slides simply because not everyone knows what SE(3) is.

There are multiple possible ways of constructing an SE(3)-equivariant transformer. Currently, the only paper that we are aware of that describes this, is ours: [SE(3)-Transformers: 3D Roto-Translation Equivariant Attention Networks](https://arxiv.org/abs/2006.10503.pdf).  We can only speculate whether DeepMind uses a similar approach. So at this point, a big fat **disclaimer**: For the sake of this blog post (and because we are biased), we will assume that they use an approach similar to the SE(3)-Transformer, or at least an approach using irreducible representations[^2].

[^2]: Irreducible representations are the basis of multiple works in this area, particularly of [3D Steerable CNNs](https://arxiv.org/abs/1807.02547) and [Tensor Field Networks](https://arxiv.org/abs/1802.08219). The [SE(3)-Transformer](https://arxiv.org/abs/2006.10503) is heavily based on both of these. Another set of works uses regular representations. If you want to learn about these, you could read [this blog post](https://fabianfuchsml.github.io/equivariance1of2/) about Taco Cohen's seminal work from 2016, or [this 2020 paper](https://arxiv.org/abs/2002.12880) from Marc Finzi.

One instrumental truth in equivariance is the following: stacking multiple layers (transformations) which are equivariant with respect to the same group (e.g. SE(3)) will result in a transformation that is also equivariant with respect to that group. To start simple, let's build a layer which takes in a vector and changes its length:

$$h(\vec{x}) = \alpha \cdot \vec{x}$$

This is equivariant with respect to rotations:
$$\mathbf{R} \cdot h(\vec{x}) = \mathbf{R} \cdot \alpha \cdot \vec{x} = \alpha \cdot \mathbf{R} \cdot \vec{x} = h(\mathbf{R} \cdot \vec{x})$$

Clearly, we can stack many of these operations, and equivariance will still be preserved. However, that's not very exciting. Let's get a little bit more creative: we know that the norm of $\vec{x}$ does not change under rotation, so we can actually make $\alpha$ a function depending on the norm of $\vec{x}$ without breaking equivariance:

$$h(\vec{x}) = \alpha(\left\lVert \vec{x} \right \rVert_2) \cdot \vec{x}$$

where the function $\alpha$ can be quite complicated, e.g. a trainable neural network. This actually already gives us a valid non-linearity for equivariant neural networks.


So far, $\alpha$ was a scalar. What if we tried to make $\alpha$ a rotation matrix? If we look at the second last equation above, there is a place where we rely on the commuting of $\alpha$ and $\mathbf{R}$:

$$\mathbf{R} \cdot \alpha \cdot \vec{x} = \alpha \cdot \mathbf{R} \cdot \vec{x}$$

Again, this has to hold *for all* $\vec{x}$. In 2D, this would be fine for any rotation matrix as 2D rotation matrices commute. In 3D however, that is not the case. It turns out that this massively restricts the computations we can do. However, there is a way around it. If we *condition* $\alpha$ on $\vec{x}$, there are non-trivial functions which fulfill the equivariance constraint. In the literature, $\alpha$ conditioned on $\vec{x}$, i.e. $\alpha(\vec{x})$, is often refered to as the kernel and denoted as $\mathbf{W}(\vec{x})$. And by choosing this kernel correctly, we can ensure that it commutes with rotations:

$$\mathbf{R} \cdot \mathbf{W}(\vec{x}) \cdot \vec{x} = \mathbf{W}(\vec{x}) \cdot \mathbf{R} \cdot \vec{x}$$


There are some simplifications we made so far, which would again make the types of functions we can learn overly restrictive. In the above, we assumed that the input to the kernel and the feature that is transformed are the same vector $\vec{x}$. This does not have to be the case, so let's relax this: 

$$h(\vec{x}, \vec{f})=   \mathbf{W}(\vec{x}) \cdot \vec{f}$$

Furthermore, we implicitly assumed that $\vec{f}$ is a 3D vector which is rotated by 3x3 rotation matrix. We want to extend this for two reasons: (1) The inputs and outputs of our neural network in most cases include information which is not best represented as 3D vector. (2) Even if we only dealt with 3D vectors in input and output space, it turns out that it is helpful to go to other representations in intermediate layers. The later has again to do with the equivariance constrains --- we can simply learn a more complex set of functions.

This brings us to the concept of irreducible representations. We might have different types of information attached to the nodes (amino acids) in our graph. Often, we have so-called scalar information, e.g. which atoms the amino acid is composed of. Scalar information does not rotate --- or in other words, it is rotated by the identity matrix. We speak of information of different *types*. 3D vectors are referred to as type 1; scalar information is referred to as type 0. There is also type 2, type 3, and so on. The theory of irreducible representations tells us that we can represent *any* information as a concatenation of different types, the so-called irreducible representations. Moreover, we know how to rotate vectors of any type, namely by the Wigner-D matrices. The type-0 Wigner D matrix is the identity. The type one Wigner D matrices are the 3x3 rotation matrices we are familiar with. In general, type $\ell$ Wigner D matrices are of dimension $(2\ell + 1) \times  (2\ell + 1)$.

Expressing everything in vectors of types $\ell_1, \ell_2, ...$ allows us to write down and solve the linear equivariance constraint for a transformation of point $\vec{x}$ with a feature vector $f$ attached to it. How to derive this is described in Appendix A and B of the SE(3)-Transformer [paper](https://arxiv.org/abs/2006.10503.pdf). To cut it short, it turns out that the spherical harmonics together with the Clebsch-Gordan coefficients form basis vectors for solving this constraint[^6]. [3D Steerable CNNs](https://arxiv.org/abs/1807.02547) and [Tensor Field Networks](https://arxiv.org/abs/1802.08219) use these results to construct SE(3)-equivariant kernels for building convolutional networks. The [SE(3)-Transformer](https://arxiv.org/abs/2006.10503.pdf) uses the same principles to build an equivariant attention mechanism.

[^6]: Knowing about spherical harmonics and Clebsch-Gordan coefficients is not important for understanding the rest of the blog post. If you are still curious: the [spherical harmonics](https://en.wikipedia.org/wiki/Spherical_harmonics) are a set of functions defined on the surface of a sphere. In fact, they form an orthonormal basis for functions on the sphere, so any function on the sphere can be expressed as a linear combination of spherical harmonics. The [Clebsch-Gordan](https://en.wikipedia.org/wiki/Clebsch%E2%80%93Gordan_coefficients) coefficients serve as a change-of-basis matrix and are part of a particular identity when working with irreducible representations (see Eqn. 26 in the [SE(3)-Transformer](https://arxiv.org/abs/2006.10503.pdf)).

### Building an Equivariant Transformer

<!-- There are obviously mutiple potential ways to build an SE(3)-equivariant transformer and we do not know how exactly DeepMind did it and whether they deviated from the SE(3)-Transformer. Time will show, but for now, here is how it's done in the SE(3)-Transformer: -->

First, we will deal with translations. By only considering relative positions between building blocks of the protein chain, the entire network, from beginning to end, is already translation invariant. This reduces the challenge to being SO(3)-equivariant, where SO is the special orthogonal group --- in other words, the group of rotations. Therefore, the theory above, which provides equivariance with respect to rotations, suffices.

Next, we make a choice to make our lives simpler. Above, we showed that multiplying an equivariant feature with an invariant scalar results in a new equivariant feature. For the attention mechanism, this means we can (and will) choose equivariant values and invariant weights, preserving overall equivariance.

We also established that we need to condition our transformations $\alpha$ on a vector to get non-trivial solutions to the equivariance constraint. For each edge in the graph, we choose this to be the relative position vector between two nodes.

For each of keys, queries, and values, we can use the theory described above to build an equivariant transformation. E.g., to obtain a key for an edge going from node $j$ to node $i$, the feature $f\_i$ is mapped to a key $k\_{ij}$:
$$k\_{ij} = W\_k(x\_{i} - x\_{j})f\_j$$
and analogously for queries and values.
$$q\_{ij} = W\_q(x\_{i} - x\_{j})f\_i$$
$$v\_{ij} = W\_v(x\_{i} - x\_{j})f\_j$$
where the weight matrices $W$ will be constructed from spherical harmonics, Clebsch-Gordan coefficients, and learnable radial basis functions.

The values are equivariant, just as we wanted them to be. The keys and the queries now have to be combined to create invariant weights. We make use of the fact that scalar products of features of the same irreducible representation are invariant. Hence, if $k\_{ij}$ and $q\_{ij}$ have the same representation, $w\_{ij} = k\_{ij}\cdot q\_{ij}$ will be invariant. The weights for node $i$ are then normalised via a softmax over all $j$.

To make everything scale better, we introduce neighbourhoods. In the SE(3)-Transformer experiment on the QM9 dataset, for each atom in the molecule, those neighbourhoods were chosen to be all other atoms the atom shares a bond with. However, using the $k$ nearest neighbours is an equally valid approach.

The theory described in the above paragraphs is summarised in figure 2 of the SE(3)-Transformer paper:
![](https://i.imgur.com/6GNsG5N.png)


### What about Edge Information?

The vigilant reader might have noticed that we have only been talking about node information but have ignored edge information. An example of edge information on the input level could be the bond type between two atoms. How to incorporate this into the model depends critically on the *type* of this information. If it is a scalar (that is the usual case), then the edge information can just be concatenated with the norm of the relative position and fed as input to the radial neural network in step 2 the figure above. If it was not a scalar but, e.g., a type-1 vector, then this procedure would break equivariance. In this case, the edge feature can be concatenated to the node features at the exact point where they are propagated to the edges. They can hence serve as input to the calculations of keys, queries, and/or values.

## **Conclusion**

That's it! That was our take on AlphaFold 2 with a special focus on equivariance. AlphaFold 2 is fascinating for all the right reasons. It is an impressive, interdisciplinary piece of intellectual work and will clearly have an impact beyond the scientific community. Beyond that, it might also do a great service to the equivariance community. By no means is it the first time that equivariant neural networks were used to tackle problems in the natural sciences, but it might already be the most prominent instance. We are curious where people will take this next. For more reading around equivariance and AlphaFold, we provided some references in the footnotes. If you want to play around with the code of the SE(3)-Transformer, click [here](https://github.com/FabianFuchsML/se3-transformer-public). 


**Credit**: *A big thank you to Adam Kosiorek, Bradley Gram-Hansen, Coral Bays-Muchmore, Haobo Wang, and Adam Golinski for helpful discussions and feedback. Fabian is part of the A2I lab at Oxford and funded by the EPSRC Centre for Doctoral Training in Autonomous Intelligent Machines and Systems. Justas is at the Baker Lab which is part of the University of Washington Institute for Protein Design and he is supported by The Open Philanthropy Project Improving Protein Design.*




























