# QKP_Rollout
## Introduction
This repository presents a rollout method for constrained dynamic programming, applied to the 0-1 Quadratic Knapsack Problem (QKP):

$$ 
\begin{alignat}{1}
\\text{maximize }\ & \sum_{i=1}^{n}\sum_{j=1}^{n}p_{ij}x_{i}x_{j}, \\\\
\\text{subject to }\ & \sum_{i=1}^{n}w_{i}x_{i} \leq C, \\\\
& \mathbf{x}\in \\{0,1\\}^{n} =: \mathbb{B}^{n}.
\end{alignat}
$$

### Method

The proposed method begins by first considering $$r \in [C]$$, $$k\in [n]$$, so that the original problem is restricted and written as:

$$
\max\left\\{\sum_{i=1}^{k}\sum_{j=1}^{k}p_{ij}x_{i}x_{j} : \sum_{i=1}^{k}w_{i}x_{i} = r,\ \mathbf{x}\in\mathbb{B}^{k}\right\\}, 
$$

where $$k$$ denotes the current item's index and $$r$$ denotes the current amount of remaining space in the knapsack when considering the $`k`$th item. Then, a subgradient approach is considered, with the restricted problem having restricted Lagrangian relaxation subproblems 

$$
\max\left\\{\sum_{i=1}^{k}\sum_{j=1}^{k}p_{ij}x_{i}x_{j} + \lambda\left(r - \sum_{i=1}^{k}w_{i}x_{i}\right) : \mathbf{x}\in\mathbb{B}^{k},\ \lambda\in \mathbb{R}\right\\}.
$$

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Let the triple $$\mathbf{y} = (k,r,S)$$ denote the current state at the $`k`$th item with capacity used, $$r$$, and define the set of indices of currently included knapsack items as $$S$$. An immediate profit earned by considering $$\mathbf{y}$$ and multiplier $$\lambda$$ is defined using 

$$
g(\mathbf{y},u) = p_{kk} + 2\sum_{j\in S\setminus \{k\}}p_{kj},
$$

which is the profit of including item $$k$$ with capacity used $$r$$. A viable rollout approach then introduces approximate costs-to-go function 

$$
\tilde{J}(\mathbf{y}) = \max\left\\{\sum_{i=1}^{k}\sum_{j=1}^{k}p_{ij}x_{i}x_{j} + \lambda\\left(r - \sum_{i=1}^{k}w_{i}x_{i}\\right) : \mathbf{x}\in\mathbb{B}^{k},\ \lambda\in \mathbb{R}\right\\}
$$

as an upper bound on the restricted problem, so that approximate $`Q-`$factors are computed according to

$$
\tilde{Q}(\mathbf{y},u) = g(\mathbf{y},u) + \tilde{J}(\mathbf{y}),
$$

with $$u \in \mathcal{U}(\mathbf{y})=:\\{0,1\\}$$ such that $$u = 1$$ if item $$k$$ is included in the knapsack while $$w_{k}\leq r$$, and $$u = 0$$ otherwise. 

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; An alternative of the presented method is also introduced using the well-known exact McCormick reformulation of 0-1 QKP using McCormick envelopes 

$$
\begin{alignat}{1}
\\text{maximize }\ & \sum_{i=1}^{n}\sum_{j=1}^{n}p_{ij}u_{ij}, \\\\
\\text{subject to }\ & u_{ij} \geq x_{j}+x_{i}-1,\text{ for all $i\in [n]$, $j\in [n]$}, \\\\
& u_{ij} \leq x_{i},\text{ for all $i\in [n]$, $j\in [n]$},\\\\
& u_{ij} \leq x_{j},\text{ for all $i\in [n]$, $j\in [n]$},\\\\
& \sum_{i=1}^{n}w_{i}x_{i}\leq C, \\\\
& \\mathbf{x} \in  \mathbb{B}^{n},\ \\mathbf{u}\in\mathbb{R}_{\geq0}^{n\times n}
\end{alignat}
$$

as a variant of the rollout base policy previously described using Lagrangian relaxations. By instead only relaxing the restriction on $`x`$, the approximate cost-to-go function uses a base policy defined as 

$$
\tilde{J}(\mathbf{y}) = \begin{cases}
\\text{maximize }\ & \sum_{i=1}^{k}\sum_{j=1}^{n}p_{ij}u_{ij}, \\\\
\\text{subject to }\ & u_{ij} \geq x_{j}+x_{i}-1,\text{ for all $i\in [k]$, $j\in [k]$}, \\\\
& u_{ij} \leq x_{i},\text{ for all $i\in [k]$, $j\in [k]$},\\\\
& u_{ij} \leq x_{j},\text{ for all $i\in [k]$, $j\in [k]$},\\\\
& \sum_{i=1}^{n}w_{i}x_{i}\leq r, \\\\
& \\mathbf{x} \in  \mathbb{R}^{k},\ \\mathbf{u}\in\mathbb{R}_{\geq0}^{k\times k}
\end{cases}
$$

in the McCormick reformulation variant.

### Solution Quality

Performance of QKP_Rollout is assessed using the approximate gap 

$$
"\\texttt{Gap}" = \frac{|z^{r}-z^{c}|}{z^{c}},
$$

where $`z^{r}`$ denotes the objective value for rollout, and $`z^{c}`$ the objective value for CPLEX.

## Data
Data for this project is generated using the standard scheme for testing algorithms designed for solving the 0-1 QKP. Particularly, for the profits associated with pairing $i$ with $j$, 

$$p_{ij}\sim \begin{cases}0 & \\text{with probability } 1-\Delta,  \\\\ \\text{Uniform}\\{1,\ldots,100\\} & \\text{with probability } \Delta.\end{cases}$$

where is $$\Delta$$ referred to as the *density* for the problem. The density, $$\Delta$$, is particularly important for determining the difficulty of the problem instance in consideration.
For larger values of $$\Delta$$, the impact of its effects is observed through the objective function, in which a larger $$\Delta$$ may yield an objective function with greatly many more terms. Consequently,
this entails that there more likely will be many interactions that will need to be considered when optimizing, therein resulting in a significantly more challenging problem. On the other
hand, the remaining data $$w_{i}\sim \\text{Uniform}\\{1,\ldots,n\\}$$ for each $$i$$, whereas $$C\sim\\{n,\ldots,\sum_{i=1}^{n}w_{i}\\}$$.
